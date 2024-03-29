koncentrationerRCP45
radiativeForcingRCP45
utslappRCP45
NASA_GISS


% DEL 1:
% start�r f�r data
t0 = 1765;
% slut�r f�r data(uppskattningar)
T = 2500;
% Startv�rdena f�r kolstockarna: [atmosf�r, biomassa, bundet i marken]
B0 = [600, 600, 1500];
% m�tt p� hur effektivt fotosyntesen omvandlar C02 till biomassa
beta = 0.3; % 0.1 - 0.8
% nettoprim�rproduktion innan industriella revolutionen
NPP0 = 60;
% hur snabbt havet m�ttas p� CO2
k = 3.06*10^(-3);
% omvandligsfaktor fr�n CO2 till kol i atmosf�ren [(ppm CO2)/Gton C]
CO2toPPM = 0.469;


% DEL 2: 
% hur snabbt djuphaven v�rms upp av ythaven
kappa = 0.5; % 0.2 - 1
% klimatk�nslighetsparametern, h�gre lambda => h�gre j�mviktstemp
lambda = 0.8; % 0.5 - 1.3
% Vattnets specifika v�rmekapacitet [(J/kg)/K]
c = 4186;
% Vattnets densitet [kg/m3h]
rho = 1020;
% Ytboxens effektiva djup [m]
h = 50;
% Djuphavsboxens effektiva djup [m]
d = 2000;
% m�tt p� hur mycket aerosoler p�verkar radiative forcing
s = 1; % ?? - ??