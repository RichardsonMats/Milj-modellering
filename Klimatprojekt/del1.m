%{
Uppgift 1: Konstruera en modell för kolcykeln (i atmo- och biosfären) med hjälp av beskrivningen
ovan. Undersk sedan hur flödena mellan de olika boxarna påverkas av CO2 utsläppsscenariot i filen
utslappRCP45.m som finns bland filerna på CANVAS. För att beräkna koldioxidkoncentrationen
mste den atmosfäriska kolstocken multipliceras med en omvandlingsfaktor för massa till
volymsandelar. Omvandlingsfaktorn ges av 0.469 ppm CO2/Gton C. Jämför er beräknande
koldioxidkoncentration med koncentrationen given i koncentrationerRCP45.m. Varför tror ni era
berknande koncentrationer skiljer sig från den som anges i filen koncentrationerRCP45.m?
%}
utslappRCP45
koncentrationerRCP45


global NPP0; % nettoprimärproduktion förindustriell
global beta; % koldioxidfertiliseringen
global B0; % boxarnas begynnelsevärden
global U; % utsläpp
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



subplot(3,1,1)
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])

legend('B1: Atmosfär','B2: Biomassa ovan mark','B3: under marken');

subplot(3,1,2)
hold on
modelConc = CO2toPPM*B(1,:);
plot(t, modelConc);
plot(t, CO2ConcRCP45);
axis([1750 2500 0 1000])
legend('modellens conc.','RCP4.5 conc.');

subplot(3,1,3)
hold on
plot(t, U);
axis([1750 2500 0 12]);
legend('utsläpp');

%{
Svar: Vår beräknade koldioxidkoncentration blir lägre än den given i 
koncentrationerRCP45. Detta kan bero på att vår modell missar någon viktig
aspekt, som återupptag av CO2. 
Eller kanske för att vi inte modellerar havens upptag av CO2?
%}


%% Uppgift 2
%{
Använda samma utsläppsscenario som i uppgift 2 och testa att variera 
koldioxidfertiliseringen ?. Vad händer med koldioxidkoncentration och 
mängden kol i biomassan och marken? Förklara resultaten!
%}



%% Uppgift 3
%{
Implementera en diskret modell (baserat på ekvation 6) som reproducerar impulssvaren i 
figur 3 med hjälp av parametervärdena i tabell 1 och ekvation 7.
%}
A = [0.113, 0.213, 0.258, 0.273, 0.1430];
tau0 = [2.0, 12.2, 50.4, 243.3, Inf];




%% Uppgift 4 
%{
 Nästa steg är att implementera en modell baserad på ekvation 8 och köra den med 
utsläppen som finns i filen utslappRCP45.m för att beräkna hur koldioxidkoncentrationen hade
utvecklats om kolet endast togs upp i havet. För att beräkna koldioxidkoncentrationen måste den 
atmosfäriska kolstocken (dvs den totala massan C i CO2) multipliceras med en omvandlingsfaktor för 
massa till volymsandelar i atmosfären med ett värde på 0.469 ppmCO2/GtC. Jämför era beräknade 
koncentrationen med koncentrationerna i koncentrationerRCP45.m. 
%}




%% Uppgift 5
%{
Rita en ny boxmodell motsvarande den i figur 2, där ni utöver kolflödena i biosfären och 
atmosfären även inkluderar nettoupptaget av kol i havet i enlighet impulsresponsmodellen. Lägg även 
till de antropogena utsläppen i figuren. Ni behöver inte kvantifiera något utan rita bara hur det ser ut 
rent principiellt. 
%}




%% Uppgift 6 
%{
Koppla samman impulsresponsmodellen för havets upptag av CO2 med boxmodellen för 
biosfärens upptag av CO2. Ni måste här ersätta utsläppen, U(t), i ekvation 8 med högerledet i ekvation 
2, dvs de antropogena utsläppen minus nettoupptaget av CO2 i den markbundna kolcykeln. Tänk på att
M i ekvation 8 är samma variabel som B1 i ekvation 2 (båda är den atmosfäriska kolstocken). Beräkna 
därefter den atmosfäriska koncentrationen av CO2 givet utsläppsdata i utslappRCP45.m och jämför 
modellresultatet med tidsserien för de harmoniserade värdena givna i koncentrationerRCP45.m. 
Anpassa ? så att den modellberäknade koncentrationen stämmer hyffsat väl överens med den 
observerade.
%}




%% Uppgift 7
%{
 Analysera var de antropogena utsläppen av CO2 tar vägen på sikt. Hur mycket ändras de 
olika kol-stockarna (atmosfär, biomassa, mark och hav) år 2100 jämfört med den förindustriella nivån 
och hur beror detta på ? och ?? Försök förklara!
%}