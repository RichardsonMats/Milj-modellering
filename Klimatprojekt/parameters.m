koncentrationerRCP45
radiativeForcingRCP45
utslappRCP45
NASA_GISS


% DEL 1:
% startår för data
t0 = 1765;
% slutår för data(uppskattningar)
T = 2500;
% Startvärdena för kolstockarna: [atmosfär, biomassa, bundet i marken]
B0 = [600, 600, 1500];
% mått på hur effektivt fotosyntesen omvandlar C02 till biomassa
beta = 0.3; % 0.1 - 0.8
% nettoprimärproduktion innan industriella revolutionen
NPP0 = 60;
% hur snabbt havet mättas på CO2
k = 3.06*10^(-3);
% omvandligsfaktor från CO2 till kol i atmosfären [(ppm CO2)/Gton C]
CO2toPPM = 0.469;


% DEL 2: 
% hur snabbt djuphaven värms upp av ythaven
kappa = 0.5; % 0.2 - 1
% klimatkänslighetsparametern, högre lambda => högre jämviktstemp
lambda = 0.8; % 0.5 - 1.3
% Vattnets specifika värmekapacitet [(J/kg)/K]
c = 4186;
% Vattnets densitet [kg/m3h]
rho = 1020;
% Ytboxens effektiva djup [m]
h = 50;
% Djuphavsboxens effektiva djup [m]
d = 2000;
% mått på hur mycket aerosoler påverkar radiative forcing
s = 1; 