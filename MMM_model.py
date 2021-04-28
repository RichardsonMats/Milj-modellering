from pyomo.environ import *
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import gurobipy
import csv
import matplotlib


model = ConcreteModel()

# DATA
countries = ['DE', 'DK', 'SE']
techs = ['Wind', 'PV', 'Gas', 'Hydro', 'Battery']
IC  = {'Wind' : 1100000, 'PV' : 600000, 'Gas' : 550000, 'Hydro' : 0, 'Battery' : 150000} # €/kW -> €/MW 
RC  = {'Wind' : 0.1, 'PV' : 0.1, 'Gas' : 2, 'Hydro' : 0.1, 'Battery' : 0.1} # €/MWh_elec
FC  = {'Wind' : 0, 'PV' : 0, 'Gas' : 22, 'Hydro' : 0, 'Battery' : 0} # €/MWh_fuel
lt  = {'Wind' : 25, 'PV' : 25, 'Gas' : 30, 'Hydro' : 80, 'Battery' : 10} # years
mu  = {'Wind' : 1, 'PV' : 1, 'Gas' : 0.4, 'Hydro' : 1, 'Battery' : 0.9} # conversion efficiency factor
co2 = {'Wind' : 0, 'PV' : 0, 'Gas' : 0.202, 'Hydro' : 0, 'Battery' : 0} # ton CO2/MWh_fuel
inf = -1
maxPot = { 'DE' : {'Wind' : 180000, 'PV' : 460000, 'Gas' : inf, 'Hydro' : 0,      'Battery' : inf}, 
           'DK' : {'Wind' : 90000,  'PV' : 60000,  'Gas' : inf, 'Hydro' : 0,      'Battery' : inf},
           'SE' : {'Wind' : 280000, 'PV' : 75000,  'Gas' : inf, 'Hydro' : 14*1e3, 'Battery' : inf}} # GW -> MW


discountrate = 0.05

input_data = pd.read_csv('TimeSeries.csv', header=[0], index_col=[0])


#TIME SERIES HANDLING
def extractData(prefix):
    info = {}
    for n in model.nodes: # ['DE', 'DK', 'SE']
        countryKey = prefix + n
        for t in model.hours: # 1:8760
            info[n,t] = float(input_data.at[t,countryKey])
    return info


def getInflow():
    inflow = {}
    for t in model.hours: # 1:8760
        inflow[t] = float(input_data.at[t,'Hydro_inflow'])
    return inflow


#SETS
model.nodes = Set(initialize=countries, doc='countries')
model.hours = Set(initialize=input_data.index, doc='hours')
model.techs = Set(initialize=techs, doc='techs')


#PARAMETERS
wind_data = extractData("Wind_")
pv_data = extractData("PV_") 
inflow_data = getInflow() # MWh for each hour

model.demand =   Param(model.nodes, model.hours, initialize=extractData("Load_"))
model.inflow =   Param(model.hours, initialize=getInflow())
model.IC =       Param(model.techs, initialize=IC, doc='investment costs')
model.RC =       Param(model.techs, initialize=RC, doc='running costs')
model.FC =       Param(model.techs, initialize=FC, doc='fuel costs')
model.lt =       Param(model.techs, initialize=lt, doc='lifetimes')
model.mu =       Param(model.techs, initialize=mu, doc='Conversion efficiency')
model.co2 =      Param(model.techs, initialize=co2, doc='emissions')



#VARIABLES

def max_cap(model, n, b):
    cap = maxPot[n][b]
    if cap == -1:
        return 0.0, None
    else:
        return 0.0, cap

def hydro_bounds(model, h):
    return 0.0, 33.0*1e6 # TWh -> MWh 

model.prod =         Var(model.nodes, model.techs, model.hours, bounds= (0.0, None), doc='tech cap')
model.capa =         Var(model.nodes, model.techs,              bounds= max_cap, doc='Generator cap')
model.waterLevel =   Var(model.hours,                           bounds= hydro_bounds, doc='reservoir water level')
model.batteryLevel = Var(model.nodes, model.hours,              bounds= (0.0, None), doc='saved battery level')
model.batterySavings = Var(model.nodes, model.hours,            bounds= (0.0, None), doc="How much energy into Battery")
model.transmission = Var(model.nodes, model.nodes, model.hours, bounds= (0.0, None), doc='transmission one-way')
model.transmissionCap = Var(model.nodes, model.nodes,           bounds= (0.0, None), doc="Transmission capacity")




# CONSTRAINTS
# 1 decision variables should be bigger than 0 (fixed with bounds)
# 2 the installed electricity production shouldn't exceed the maximum capacities (fixed with bounds)
# 3 The countries' electricity demand should be met at all hours
# 4 The production should always be lower or equal than installed
# 5 water level in reservoir is only changed by water inflow and outflow (y_hydro)
# 6 CO_2 cap
# 7 Produced electricity that isn't used by demand is stored in batteries
# 8 Transmission cap is the same in both 
# 9 transmission is limited by installed capacity
# 10 No self transmission



# 3 The countries' electricity demand should be met at all hours:
# def demand_rule(model, nodes, hours):
#     totProd = sum([model.prod[nodes, t, hours] for t in model.techs])
#     return model.demand[nodes, hours] + model.batterySavings[nodes, hours] <= totProd

# model.demandCon = Constraint(model.nodes, model.hours, rule=demand_rule)

def deman2(model, nodes, hours):
    totalProd=0
    transmissionIn = 0
    transmissionOut = 0

    for n in model.nodes:
        transmissionIn = transmissionIn + model.transmission[n, nodes, hours]*0.98
        transmissionOut = transmissionOut + model.transmission[n, nodes, hours]

    for tech in model.techs:
        totalProd = totalProd + model.prod[nodes, tech, hours]*model.mu[tech]

    return totalProd - transmissionOut >=model.demand[nodes, hours] + model.batterySavings[nodes, hours] - transmissionIn
model.demandConstraint  = Constraint(model.nodes, model.hours, rule=deman2)


#4 The production should always be lower or equal than installed
def prod_rule(model, nodes, techs, hours):
    upperLimit={
            'Wind':  wind_data[nodes,hours]*model.capa[nodes, 'Wind'], 
            'PV':        pv_data[nodes,hours]*model.capa[nodes, 'PV'],
            'Gas':                           model.capa[nodes, 'Gas'],
            'Hydro':                       model.capa[nodes, 'Hydro'],
            'Battery':               model.capa[nodes, 'Battery']}
    return model.prod[nodes, techs, hours] <= upperLimit.get(techs)

model.prodCon = Constraint(model.nodes, model.techs, model.hours, rule=prod_rule)


# 5 water level in reservoir is only changed by water inflow and outflow (y_hydro)
def reservoir_rule(model,hours):
    if hours == 8759:
        return model.waterLevel[0] == model.waterLevel[hours] + model.inflow[hours] - model.prod['SE', 'Hydro', hours]
    else:
        return model.waterLevel[hours+1] == model.waterLevel[hours] + model.inflow[hours] - model.prod['SE', 'Hydro', hours]
        
model.reservoirCon = Constraint(model.hours, rule=reservoir_rule)


# 6 CO_2 cap
def emissions(country):
         totProd = sum([model.prod[country, 'Gas', h] for h in model.hours]) # MWh_elec
         burnedGas = totProd/model.mu['Gas'] # MWh_fuel
         emissions = burnedGas*model.co2['Gas'] # ton CO_2
         return emissions

def co2cap(model):
     old_emissions = sum([125243664.86937965, 8552556.240328295, 4978228.17498443])
     target = old_emissions*0.1 # will give an infeasible solution
     return sum([emissions(c) for c in model.nodes]) <= target

model.co2Con = Constraint(rule=co2cap)

# def co2CapV2(model):
#      old_emissions = sum([125243664.86937965, 8552556.240328295, 4978228.17498443])
#      newEmission = 0
#      for country in model.nodes:
#          for h in model.hours:
#              newEmission = newEmission + model.prod[country, "Gas", h]*co2["Gas"]/0.9
#      return newEmission <= old_emissions*0.1
# model.co2Constraint = Constraint(rule=co2CapV2)






# 7 Produced electricity that isn't used by demand is stored in batteries, battery not over capacity

# Saves into battery
def batteryConstraint(model, nodes, hours):
    if hours == 0:
        return model.batteryLevel[nodes, 0] == model.batteryLevel[nodes, 8759] - model.prod[nodes, 'Battery', 0] + model.batterySavings[nodes, hours]
    elif hours >0:
        return model.batteryLevel[nodes, hours] == model.batteryLevel[nodes, hours-1] + model.batterySavings[nodes, hours]  - model.prod[nodes, 'Battery', hours]
model.batteryCon = Constraint(model.nodes, model.hours, rule=batteryConstraint)

# # Checks battery is not over capcaity
# def batteryLessThanCap(model, nodes, hours):
#     return model.batterySavings[nodes, hours] <= model.capa[nodes, "Battery"]
# model.batteryCapCon=Constraint(model.nodes, model.hours, rule=batteryLessThanCap)

# def batteryLessThanCap2(model, nodes, hours):
#     return model.batteryLevel[nodes, hours] <=model.capa[nodes, "Battery"]
# model.batteryCapCon2=Constraint(model.nodes, model.hours, rule=batteryLessThanCap2)

def batteryEnd(model, nodes):
    return model.batteryLevel[nodes, model.hours[8759]] == model.batteryLevel[nodes, 0]
model.batteryEndConst = Constraint(model.nodes, rule=batteryEnd)



# 8 Transmission cap is the same in both directions
def biDirectional(model, country1, country2):
    return model.transmissionCap[country1, country2] == model.transmissionCap[country2, country1]

model.transBiCap = Constraint(model.nodes, model.nodes, rule=biDirectional)


# 9 transmission is limited by installed capacity
def transmissionConstraint(model, country1, country2, hour):
    return model.transmission[country1, country2, hour] <= model.transmissionCap[country1, country2]

model.transmissionCont = Constraint(model.nodes, model.nodes, model.hours, rule=transmissionConstraint)


# 10 No self transmission
def selfTransmissionConstraint(model, node, hours):
    return model.transmission[node, node, hours] == 0

model.selfTransmission = Constraint(model.nodes, model.hours, rule= selfTransmissionConstraint)



# Manually calculate TransCost
def transmissionCost():
    annualTrans = discountrate/(1-1/(1 + discountrate)**50)
    totalTransmissionCost=0
    for n in model.nodes:
        for n2 in model.nodes:
            totalTransmissionCost = totalTransmissionCost + 2500*1e3 * annualTrans* model.transmissionCap[n, n2]
    return totalTransmissionCost /2


#OBJECTIVE FUNCTION
def get_AC(b):
    return model.IC[b]*discountrate/(1-1/(1+discountrate)**model.lt[b])
    

def objective_rule(model):
    summ = 0
    for i in model.nodes:
        for b in model.techs:
            summ = summ + model.capa[i,b]*get_AC(b)
            for h in model.hours:
                summ = summ + model.prod[i,b,h]*(model.RC[b]+model.FC[b]/model.mu[b])
    return summ + transmissionCost()

model.objective = Objective(rule=objective_rule, sense=minimize, doc='Objective function')



def totDemand(country):
    return sum([model.demand[country, h] for h in model.hours])

def totProd(country):
    return sum([model.prod[country, b, h].value for h in model.hours for b in model.techs])

def totProdTech(country, tech):
    return sum([model.prod[country, tech, h].value for h in model.hours])

##Plots and plotfunctions

def netTransmissions(country, hour):
    transIn = sum([model.transmission[n, country, hour].value for n in model.nodes])
    transOut = sum([model.transmission[country, n, hour].value for n in model.nodes])
    return transIn - transOut

# Plot First German Week
def plotWeek1(country):
    w1 = range(168)
    week1_hours = [n for n in w1]
    energy_produced = {
        'PV'          : [model.prod[country, 'PV', h].value/1e3 for h in w1],
        'Wind'        : [model.prod[country, 'Wind', h].value/1e3 for h in w1],
        'Gas'         : [model.prod[country, 'Gas', h].value/1e3 for h in w1],
        'Hydro'       : [model.prod[country, 'Hydro', h].value/1e3 for h in w1],
        'Battery'     : [model.prod[country, 'Battery', h].value/1e3 for h in w1],
        'Transmission': [model.transmission['SE', 'DE', h].value/1e3 for h in w1]
    }

    fig, ax = plt.subplots()
    ax.stackplot(week1_hours, energy_produced.values(),
             labels=energy_produced.keys())
    ax.plot(week1_hours, [model.demand[country, h]/1e3 for h in w1])
    ax.legend(loc='upper left')
    ax.set_title('Energy produced 1st week in ' + country)
    ax.set_xlabel('Hour')
    ax.set_ylabel('Produced energy in GWh')
    plt.show()

# plot installed capacities
def plotInstalledCapacities():
    labels = ['DE', 'DK', 'SE']
    x = np.arange(len(labels))  # the label locations
    width = 0.15  # the width of the bars

    fig, ax = plt.subplots()
    rects5 = ax.bar(x - 2*width, [model.capa[i, 'Hydro'].value for i in model.nodes], width, label='hydro')
    rects1 = ax.bar(x - 1*width, [model.capa[i, 'Gas'].value for i in model.nodes], width, label='gas')
    rects2 = ax.bar(x + 0*width, [model.capa[i, 'PV'].value for i in model.nodes], width, label='PV')
    rects3 = ax.bar(x + 1*width, [model.capa[i, 'Wind'].value for i in model.nodes], width, label='wind')
    rects4 = ax.bar(x + 2*width, [model.capa[i, 'Battery'].value for i in model.nodes], width, label='battery')
    rects8 = ax.bar(x + 5*width, [model.transmissionCap['SE', i].value for i in model.nodes], width, label='trans from SE')
    rects6 = ax.bar(x + 3*width, [model.transmissionCap['DE', i].value for i in model.nodes], width, label='trans from DE')    
    rects7 = ax.bar(x + 4*width, [model.transmissionCap['DK', i].value for i in model.nodes], width, label='trans from DK')

    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel("installed capacity [MW]")
    ax.set_title("installed capacities for each country")
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()
    fig.tight_layout()
    plt.show()
    # Plot installed capacities:


# plot anual productions
def plotAnualProd():
    labels = ['DE', 'DK', 'SE']
    x = np.arange(len(labels))  # the label locations
    width = 0.2  # the width of the bars

    gas_prod = [sum([model.prod[i, 'Gas', h].value for h in model.hours]) for i in model.nodes]
    solar_prod = [sum([model.prod[i, 'PV', h].value for h in model.hours]) for i in model.nodes]
    wind_prod = [sum([model.prod[i, 'Wind', h].value for h in model.hours]) for i in model.nodes]
    battery_prod = [sum([model.prod[i, 'Battery', h].value for h in model.hours]) for i in model.nodes]
    hydro_prod = [sum([model.prod[i, 'Hydro', h].value for h in model.hours]) for i in model.nodes]
    transmission_prod = [sum([netTransmissions(i, h) for h in model.hours]) for i in model.nodes]

    fig, ax = plt.subplots()
    rects5 = ax.bar(x - 2*width, hydro_prod, width, label='hydro')
    rects1 = ax.bar(x - 1*width, gas_prod, width, label='gas')
    rects2 = ax.bar(x - 0*width,   solar_prod, width, label='PV')
    rects3 = ax.bar(x + 1*width,           wind_prod, width, label='wind')
    rects4 = ax.bar(x + 2*width,   battery_prod, width, label='battery')
    rects6 = ax.bar(x + 3*width, transmission_prod, width, label='transmission')

    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel("Produced energy [MWh]")
    ax.set_title("Anual energy production")
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()
    fig.tight_layout()
    plt.show()
    # Plot installed capacities:



def plotTransmissions():
    labels = ['from DE', 'from DK', 'from SE']
    x = np.arange(len(labels))  # the label locations
    width = 0.2  # the width of the bars


    to_DE = [sum([model.transmission[i, 'DE', h].value for h in model.hours]) for i in model.nodes]
    to_DK = [sum([model.transmission[i, 'DK', h].value for h in model.hours]) for i in model.nodes]
    to_SE = [sum([model.transmission[i, 'SE', h].value for h in model.hours]) for i in model.nodes]


    fig, ax = plt.subplots()
    rects1 = ax.bar(x - width, to_DE, width, label='to DE')
    rects2 = ax.bar(x,         to_DK, width, label='to DK')
    rects3 = ax.bar(x + width, to_SE, width, label='to SE')
 
    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel("Transmitted energy [MWh]")
    ax.set_title("Annual accumulated transmissions")
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()
    fig.tight_layout()
    plt.show()
    # Plot installed capacities:


#plot battery levels
def plotBatteryLevel():
    fig, axs = plt.subplots(2, 2)
    q = [[0,0], [0,1], [1,0], [1,1]]
    for i,c in enumerate(model.nodes):
        hours = range(8759)
        bat_lvl = [model.batteryLevel[c, h].value for h in hours]
        axs[q[i][0], q[i][1]].plot(hours, bat_lvl)
        axs[q[i][0], q[i][1]].set_title(c)
    plt.show()


#plot transmission between DE and SE
def plotTransW1():
    hours = range(168)    
    #hours = range(1000, 1168)
    fig, ax = plt.subplots()
    DESE = [model.transmission['DE', 'SE', h].value for h in hours]
    SEDE = [model.transmission['SE', 'DE', h].value for h in hours]
    plt.plot(hours,DESE, label='DE -> SE')
    plt.plot(hours,SEDE, label='SE -> DE')
    ax.legend()
    plt.show()

#plot prod['SV', 'Hydro']
def plotWaterProd():
    hours = range(8759)
    waterProd = [model.prod['SE', 'Hydro', h].value for h in hours]
    plt.plot(hours,waterProd)
    plt.show()


def printTransCaps():
    for sender in model.nodes:
        for reciever in model.nodes:
            print("cap " + sender + " -> " + reciever + ": ")
            print(model.transmissionCap[sender, reciever].value)
    return

if __name__ == '__main__':
    from pyomo.opt import SolverFactory
    import pyomo.environ
    import pandas as pd

    opt = SolverFactory("gurobi_direct")
    #opt = SolverFactory("gurobi_direct", solver_io="python")
    opt.options["threads"] = 4
    print('Solving')
    results = opt.solve(model, tee=True)
    model.capa.pprint() 

    results.write()

    #Reading output - example
    capTot = {}
    for n in model.nodes:
        for g in model.techs:
            print(model.capa[n, g])
            print(model.capa[n, g].value)
            
            #capTot[n, g] = model.capa[n, g].value/1e3 #GW

    def emissions(country):
        totProd = sum([model.prod[country, 'Gas', h].value for h in model.hours]) # MWh_elec
        burnedGas = totProd/model.mu['Gas'] # MWh_fuel
        emissions = burnedGas*model.co2['Gas'] # ton CO_2
        return emissions

    emission_data = [emissions(c) for c in model.nodes]
    print(emission_data)


    costTot = value(model.objective) / 1e6 #Million EUR

    for i in model.nodes:
        print("country: " + i)
        print("demand: " + str(totDemand(i)))
        print("produced: " + str(totProd(i)))
        for t in model.techs:
            print(str(t)+"produced: " + str(totProdTech(i,t)))
    

    plotTransW1()
    plotWeek1('DE')
    plotInstalledCapacities()
    plotAnualProd()
    plotWeek1('SE')
    plotBatteryLevel()
    plotTransmissions()
    printTransCaps()