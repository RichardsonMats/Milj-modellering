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
IC  = {'Wind' : 1100*1e3, 'PV' : 600*1e3, 'Gas' : 550*1e3, 'Hydro' : 0*1e3, 'Battery' : 150*1e3} # €/kW -> €/MW 
RC  = {'Wind' : 0.1, 'PV' : 0.1, 'Gas' : 2, 'Hydro' : 0.1, 'Battery' : 0.1} # €/MWh_elec
FC  = {'Wind' : 0, 'PV' : 0, 'Gas' : 22, 'Hydro' : 0, 'Battery' : 0} # €/MWh_fuel
lt  = {'Wind' : 25, 'PV' : 25, 'Gas' : 30, 'Hydro' : 80, 'Battery' : 10} # years
mu  = {'Wind' : 1, 'PV' : 1, 'Gas' : 0.4, 'Hydro' : 1, 'Battery' : 0.9} # conversion efficiency factor
co2 = {'Wind' : 0, 'PV' : 0, 'Gas' : 0.202, 'Hydro' : 0, 'Battery' : 0} # ton CO2/MWh_fuel
inf = -1
status = 0
maxPot = { 'DE' : {'Wind' : 180*1e3, 'PV' : 460*1e3, 'Gas' : inf, 'Hydro' : 0,      'Battery' : status*1e3}, 
           'DK' : {'Wind' : 90*1e3,  'PV' : 60*1e3,  'Gas' : inf, 'Hydro' : 0,      'Battery' : status*1e3},
           'SE' : {'Wind' : 280*1e3, 'PV' : 75*1e3,  'Gas' : inf, 'Hydro' : 14*1e3, 'Battery' : status*1e3}} # GW -> MW


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


"""
model.wind =     Param(model.nodes, model.hours, initialize=extractData("Wind_"))
model.sun =      Param(model.nodes, model.hours, initialize=extractData("PV_"))
"""
model.demand =   Param(model.nodes, model.hours, initialize=extractData("Load_"))
model.inflow =   Param(model.hours, initialize=getInflow())
model.IC =       Param(model.techs, initialize=IC, doc='investment costs')
model.RC =       Param(model.techs, initialize=RC, doc='running costs')
model.FC =       Param(model.techs, initialize=FC, doc='fuel costs')
model.lt =       Param(model.techs, initialize=lt, doc='lifetimes')
model.mu =       Param(model.techs, initialize=mu, doc='Conversion efficiency')
model.co2 =      Param(model.techs, initialize=co2, doc='emissions')

#model.maxPot =   Param(model.nodes, model.techs, initialize=maxPot, doc='max investment cap') # MIGHT BE WRONGLY FORMATTED


#VARIABLES
#capMaxdata = pd.read_csv('data/capMax.csv', index_col=[0])

def max_cap(model, n, b):
    cap = maxPot[n][b]
    if cap == -1:
        return 0.0, None
    else:
        return 0.0, cap


def hydro_bounds(model, h):
    return 0.0, 33.0*1e6 # TWh -> MWh 

def no_bounds(model, n, b, h):
    return 0.0, None
    

#model.capa = Var(model.nodes, model.gens, bounds=capacity_max, doc='Generator cap')
model.prod =       Var(model.nodes, model.techs, model.hours, bounds=no_bounds, doc='tech cap')
model.capa =       Var(model.nodes, model.techs, bounds=max_cap, doc='Generator cap')
model.waterLevel = Var(model.hours, bounds=hydro_bounds, doc='reservoir water level')


# CONSTRAINTS
# 1 decision variables should be bigger than 0 (fixed with bounds)
# 2 the installed electricity production shouldn't exceed the maximum capacities (fixed with bound)
# 3 The countries' electricity demand should be met at all hours
# 4 The production should always be lower or equal than installed
# 5 water level in reservoir is only changed by water inflow and outflow (y_hydro)


# 3 The countries' electricity demand should be met at all hours:
def demand_rule(model, nodes, hours):
    totProd = sum([model.prod[nodes, t, hours] for t in model.techs])
    return model.demand[nodes, hours] <= totProd

model.demandCon = Constraint(model.nodes, model.hours, rule=demand_rule)


#4 The production should always be lower or equal than installed
def prod_rule(model, nodes, techs, hours):
    upperLimit={
            'Wind':  wind_data[nodes,hours]*model.capa[nodes, 'Wind'], 
            'PV':        pv_data[nodes,hours]*model.capa[nodes, 'PV'],
            'Gas':                         1*model.capa[nodes, 'Gas'],
            'Hydro':    inflow_data[hours]*model.capa[nodes, 'Hydro'],
            'Battery':                 1*model.capa[nodes, 'Battery'] # TODO change
             }
    return model.prod[nodes, techs, hours] <= upperLimit.get(techs)

model.prodCon = Constraint(model.nodes, model.techs, model.hours, rule=prod_rule)


# 5 water level in reservoir is only changed by water inflow and outflow (y_hydro)
def reservoir_rule(model,hours):
    #waterLevel(h) = waterLevel(h-1) + inflow(h) - y(h)
    if hours == 8759:
        return model.waterLevel[0] == model.waterLevel[hours] + model.inflow[hours] - model.prod['SE', 'Hydro', hours]
    else:
        return model.waterLevel[hours+1] == model.waterLevel[hours] + model.inflow[hours] - model.prod['SE', 'Hydro', hours]
        
model.reservoirCon = Constraint(model.hours, rule=reservoir_rule)



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
    return summ

model.objective = Objective(rule=objective_rule, sense=minimize, doc='Objective function')


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

    wind_data = extractData('Wind_')
    wind_DE_tot = sum([wind_data['DE',h] for h in model.hours])
    wind_DK_tot = sum([wind_data['DK',h] for h in model.hours])
    wind_SE_tot = sum([wind_data['SE',h] for h in model.hours])

    print(wind_DE_tot)
    print(wind_DK_tot)
    print(wind_SE_tot)

    costTot = value(model.objective) / 1e6 #Million EUR





# Plot First German Week
w1 = range(168)
week1_hours = [n for n in w1]
energy_produced = {
    'Wind' : [model.prod['DE', 'Wind', h].value/1e3 for h in w1],
    'PV'   : [model.prod['DE', 'PV', h].value/1e3 for h in w1],
    'Gas'  : [model.prod['DE', 'Gas', h].value/1e3 for h in w1],
    'Hydro': [model.prod['DE', 'Hydro', h].value/1e3 for h in w1]
    }

fig, ax = plt.subplots()
ax.stackplot(week1_hours, energy_produced.values(),
             labels=energy_produced.keys())
ax.legend(loc='upper left')
ax.set_title('Energy produced 1st week in Germany')
ax.set_xlabel('Hour')
ax.set_ylabel('Produced energy in GWh')

plt.show()

# Plot installed capacities:
labels = ['DE', 'DK', 'SE']
wind_installed = [model.capa['DE', 'Wind'].value, model.capa['DK', 'Wind'].value, model.capa['SE', 'Wind'].value]
solar_installed = [model.capa['DE', 'PV'].value, model.capa['DK', 'PV'].value, model.capa['SE', 'PV'].value]
gas_installed = [model.capa['DE', 'Gas'].value, model.capa['DK', 'Gas'].value, model.capa['SE', 'Gas'].value]
hydro_installed = [model.capa['DE', 'Hydro'].value, model.capa['DK', 'Hydro'].value, model.capa['SE', 'Hydro'].value]
wind_cap = [180, 90, 280]
solar_cap = [460, 60, 75]
gas_cap = [0,0,0]
hydro_cap = [0, 0, 14]



x = np.arange(len(labels))  # the label locations
width = 0.7  # the width of the bars

fig, ax = plt.subplots()
rects1 = ax.bar(x - width/2, wind_installed, width, label='wind')
rects2 = ax.bar(x - width/4, solar_installed, width, label='PV')
rects3 = ax.bar(x + width/2, gas_installed, width, label='gas')
rects4 = ax.bar(x + width/4, hydro_installed, width, label='hydro')

# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel('Scores')
ax.set_title('Scores by group and gender')
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.legend()

# ax.bar_label(rects1, padding=3)
# ax.bar_label(rects2, padding=3)
# ax.bar_label(rects3, padding=3)
# ax.bar_label(rects4, padding=3)

fig.tight_layout()

plt.show()
