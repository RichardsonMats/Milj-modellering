%{
Uppgift 1: Konstruera en modell f�r kolcykeln (i atmo- och biosf�ren) med hj�lp av beskrivningen
ovan. Undersk sedan hur fl�dena mellan de olika boxarna p�verkas av CO2 utsl�ppsscenariot i filen
utslappRCP45.m som finns bland filerna p� CANVAS. F�r att ber�kna koldioxidkoncentrationen
mste den atmosf�riska kolstocken multipliceras med en omvandlingsfaktor f�r massa till
volymsandelar. Omvandlingsfaktorn ges av 0.469 ppm CO2/Gton C. J�mf�r er ber�knande
koldioxidkoncentration med koncentrationen given i koncentrationerRCP45.m. Varf�r tror ni era
berknande koncentrationer skiljer sig fr�n den som anges i filen koncentrationerRCP45.m?
%}
utslappRCP45


global NPP0; % nettoprim�rproduktion f�rindustriell
global beta; % koldioxidfertiliseringen
global B0; % boxarnas begynnelsev�rden
global U; % utsl�pp
NPP0 = 60; 
beta = 0.35; 
B0 = [600, 600, 1500];
U = CO2Emissions;

CO2toPPM = 0.469; % (ppm CO2)/Gton C
t0 = 1765;
T = 2500; 
N = length(U);
t = linspace(t0 ,T , N ); % A vector to store the time values .

[B, t] = forwardEuler (@dBdT, t);


hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])

legend('B1: Atmosf�r','B2: Biomassa ovan mark','B3: under marken');

