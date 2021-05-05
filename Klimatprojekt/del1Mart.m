%{
Uppgift 1: Konstruera en modell för kolcykeln (i atmo- och biosfären) med hjälp av beskrivningen
ovan. Undersk sedan hur flödena mellan de olika boxarna påverkas av CO2 utsläppsscenariot i filen
utslappRCP45.m som finns bland filerna på CANVAS. För att beräkna koldioxidkoncentrationen
mste den atmosfäriska kolstocken multipliceras med en omvandlingsfaktor för massa till
volymsandelar. Omvandlingsfaktorn ges av 0.469 ppm CO2/Gton C. Jämför er beräknande
koldioxidkoncentration med koncentrationen given i koncentrationerRCP45.m. Varför tror ni era
berknande koncentrationer skiljer sig från den som anges i filen koncentrationerRCP45.m?
%}

clc
clf
utslappRCP45
koncentrationerRCP45

% omvandling ppmCO2/Gton C
omvandling = 0.469;

%Flödeskoefficienter 
F = [0 60 0
     15 0 45
     45 0 0];

alpha = [0 60/600 0
          15/600 0 45/600
         45/1500 0 0];
     
beta = 0.35;
NPP0=60;
h=1;
stop=length(CO2Emissions);
% Startvärden boxar
B=zeros(3, stop+1);
B(1,1)=600;
B(2,1)=600;
B(3,1)=1500;

% Euler yn = yn+1 + h*yn'
for n = 1:stop
    B(1, n+1) = B(1,n) + h * (alpha(3,1)*B(3,n)+alpha(2,1)*B(2,n) - mats(NPP0,beta,B(1,n), B(1)) + CO2Emissions(n));
    B(2, n+1) = B(2,n) + h * (mats(NPP0,beta, B(2,n), B(2))- alpha(2,3)*B(2,n) - alpha(2,1)*B(2,n));
    B(3, n+1) = B(3,n) + h * (alpha(2,3)*B(2,n)-alpha(3,1)*B(3,n));
end


x = linspace(1725,2500,stop+1);

hold on

plot(x, B(1,:))
plot(x, B(2,:))
plot(x, B(3,:))
axis([1750 2500 -500 2000])

legend('B1','B2','B3');


 