function taui = taufunc(tau, CO2, t, k)
    Utslapp = 0;
    for i = 1:1:t-1
        Utslapp = Utslapp + CO2(i);
    end
    
    taui = tau .*(1+k*Utslapp);