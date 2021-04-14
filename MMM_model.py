from pyomo.environ import *
import pandas as pd
import matplotlib.pyplot as plt

model = ConcreteModel()


# DATA
countries = ['DE', 'DK', 'SE']
techs = ['Wind', 'PV', 'Gas', 'Hydro', 'Battery']
IC = {'Wind' : 1100, 'PV' : 600, 'Gas' : 550, 'Hydro' : 0, 'Battery' : 150} # €/kW
RC = {'Wind' : 0.1, 'PV' : 0.1, 'Gas' : 2, 'Hydro' : 0.1, 'Battery' : 0.1} # €/MWh_elec
FC = {'Wind' : 0, 'PV' : 0, 'Gas' : 22, 'Hydro' : 0, 'Battery' : 0} # €/MWh_fuel
lt = {'Wind' : 25, 'PV' : 25, 'Gas' : 30, 'Hydro' : 80, 'Battery' : 10} # years
mu = {'Wind' : 1, 'PV' : 1, 'Gas' : 0.4, 'Hydro' : 1, 'Battery' : 0.9} # conversion efficiency factor
co2 = {'Wind' : 0, 'PV' : 0, 'Gas' : 0.202, 'Hydro' : 0, 'Battery' : 0} # ton CO2/MWh_fuel
inf = -1
status = 0
maxPot = { 'DE' : {'Wind' : 180, 'PV' : 460, 'Gas' : inf, 'Hydro' : 0,  'Battery' : status}, 
           'DK' : {'Wind' : 90,  'PV' : 60,  'Gas' : inf, 'Hydro' : 0,  'Battery' : status},
           'SE' : {'Wind' : 280, 'PV' : 75,  'Gas' : inf, 'Hydro' : 14, 'Battery' : status}} # GW 


discountrate = 0.05

input_data = pd.read_csv('TimeSeries.csv', header=[0], index_col=[0])


#TIME SERIES HANDLING
def extractData(prefix):
    data = {}
    for n in model.nodes: # ['DE', 'DK', 'SE']
        countryKey = prefix + n
        for t in model.hours: # 1:8760
            data[n,t] = float(input_data.at[t,countryKey])
    return data


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
model.demand =   Param(model.nodes, model.hours, initialize=extractData("Load_"))
model.wind =     Param(model.nodes, model.hours, initialize=extractData("Wind_"))
model.sun =      Param(model.nodes, model.hours, initialize=extractData("PV_"))
model.inflow =   Param(model.hours, initialize=getInflow())
model.IC =       Param(model.techs, initialize=IC, doc='investment costs')
model.RC =       Param(model.techs, initialize=RC, doc='running costs')
model.FC =       Param(model.techs, initialize=FC, doc='fuel costs')
model.lifetime = Param(model.techs, initialize=lt, doc='lifetimes')
model.mu =       Param(model.techs, initialize=mu, doc='Conversion efficiency')
model.co2 =      Param(model.techs, initialize=co2, doc='emissions')

#model.maxPot =   Param(model.nodes, model.techs, initialize=maxPot, doc='max investment cap') # MIGHT BE WRONGLY FORMATTED


#VARIABLES
capMaxdata = pd.read_csv('data/capMax.csv', index_col=[0])

""" original untouched method
def capacity_max(model, n, g):
    capMax = {}
    if g in capMaxdata.columns:
        capMax[n, g] = float(capMaxdata[g].loc[capMaxdata.index == n])
        return 0.0, capMax[n,g]
    elif g == 'Battery' and not batteryOn:
        return 0.0, 0.0
    else:
        return 0.0, None
"""

def max_cap(model, n, b):
    cap = maxPot[n][b]
    if cap == -1:
        return 0.0, None
    else:
        return 0.0, cap


def prod_cap(model, n, b, h):
    

#model.capa = Var(model.nodes, model.gens, bounds=capacity_max, doc='Generator cap')
model.capa = Var(model.nodes, model.techs, bounds=max_cap, doc='Generator cap')
model.prod = Var(model.nodes, model.techs, model.hours, bounds=prod_cap, doc='Generator cap')


#CONSTRAINTS
def prodcapa_rule(model, nodes, gens, time):
    return model.prod[nodes, gens, time] <= model.capa[nodes, gens]

model.prodCapa = Constraint(model.nodes, model.gens, model.time, rule=prodcapa_rule)


#OBJECTIVE FUNCTION
def objective_rule(model):
    return sum(#Add equation for the sum of all system costs.
    )

model.objective = Objective(rule=objective_rule, sense=minimize, doc='Objective function')


if __name__ == '__main__':
    from pyomo.opt import SolverFactory
    import pyomo.environ
    import pandas as pd

    opt = SolverFactory("gurobi_direct")
    opt.options["threads"] = 4
    print('Solving')
    results = opt.solve(model, tee=True)

    results.write()

    #Reading output - example
    capTot = {}
    for n in model.nodes:
        for g in model.gens:
            capTot[n, g] = model.capa[n, g].value/1e3 #GW


    costTot = value(model.objective) / 1e6 #Million EUR
