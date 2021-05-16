%% Uppgift 8
% parametrar
% Konstruera en radiative forcing modul med hjälp av beskrivningen ovan. ???2(dvs det
%partiella trycket eller koncentrationen) kan erhållas från er kolcykelmodell eller från koncentration i
%koncentrationerRCP45.m. Berkna och visa i en figur RF för CO2, jämför dessa värden med radiative
%forcing för CO2 i radiativeForcingRCP45.m.
clc
clf
clear
% andra filer
utslappRCP45
NASA_GISS
koncentrationerRCP45
radiativeForcingRCP45

p0 = CO2ConcRCP45(1);

for r = 1:length(CO2ConcRCP45)
    %Ekv 9
    RFCO2(r) = 5.35 * log(CO2ConcRCP45(r)/p0);
end


plot(RFCO2, 'green')
hold on
plot(CO2RadForc, 'blue')
%% Uppgift 9: Summera RF för andra klimatpåverkande ämnen och RF för aerosoler, dessa finner du i
%filen radiativeForcingRCP45.m. Multiplicera RF för aerosoler med en skalfaktor, s, med
%standardvärde lika med 1. I denna laboration kommer vi låta s vara 1, men i det avslutande
%klimatprojektet ska detta värde varieras. Anledningen till skalfaktorn används är att osäkerheten är stor
%kring hur mycket kylande effekt som aerosolerna har.

clc 
clf

RFCO2 = zeros(1, length(CO2ConcRCP45));
RFCH4 = zeros(1, length(CH4Conc));
RFN2H = zeros(1, length(N2OConc));
summa = zeros(1, length(CH4Conc));

pCO0=CO2ConcRCP45(1);
pCH40=CH4Conc(1);
pN20=N2OConc(1);

for g = 1:length(CO2ConcRCP45)
    RFCO2(g)= 5.35 * log(CO2ConcRCP45(g)/pCO0);
    RFCH4(g)=5.35*log(CH4Conc(g)/pCH40);
    RFN2H(g)=5.35*log(N2OConc(g)/pN20);
    summa (g) = RFCO2(g)+ RFCH4(g) + RFN2H(g);
end

plot (summa, 'blue');
hold on
plot (RFCO2, 'yellow');
plot (RFCH4, 'black');
plot(RFN2H, 'red');
legend('Sum', 'RFCO2', 'RFCH4', 'RFN2H');


