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
koncentrationerRCP45


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



subplot(3,1,1)
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])

legend('B1: Atmosf�r','B2: Biomassa ovan mark','B3: under marken');

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
legend('utsl�pp');

%{
Svar: V�r ber�knade koldioxidkoncentration blir l�gre �n den given i 
koncentrationerRCP45. Detta kan bero p� att v�r modell missar n�gon viktig
aspekt, som �terupptag av CO2. 
Eller kanske f�r att vi inte modellerar havens upptag av CO2?
%}


%% Uppgift 2
%{
Anv�nda samma utsl�ppsscenario som i uppgift 2 och testa att variera 
koldioxidfertiliseringen ?. Vad h�nder med koldioxidkoncentration och 
m�ngden kol i biomassan och marken? F�rklara resultaten!
%}
clf
clc

subplot(2,2,1)
beta = 0.1;
[B, t] = forwardEuler (@dBdT, t);
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])
legend('B1: Atmosf�r','B2: Biomassa ovan mark','B3: under marken');
title('beta = 0.1');

subplot(2,2,2)
beta = 0.35;
[B, t] = forwardEuler (@dBdT, t);
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])
legend('B1: Atmosf�r','B2: Biomassa ovan mark','B3: under marken');
title('beta = 0.35');

subplot(2,2,3)
beta = 0.6;
[B, t] = forwardEuler (@dBdT, t);
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])
legend('B1: Atmosf�r','B2: Biomassa ovan mark','B3: under marken');
title('beta = 0.6');

subplot(2,2,4)
beta = 0.8;
[B, t] = forwardEuler (@dBdT, t);
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])
legend('B1: Atmosf�r','B2: Biomassa ovan mark','B3: under marken');
title('beta = 0.8');

%{
N�r Beta �kar s� skapas det mer biomassa samt kol bundet i marken. M�ngden
kol i atmosf�ren minskar dock. Fr�n detta kan vi anta att Beta �r ett m�tt 
p� hur effektivt v�xterna omvandlar CO2 till biomassa. H�gre Beta leder 
d�rmed till att mer luftbunden CO2 anv�nds f�r att skapa mer biomassa, som 
i sin tur binder mer kol i marken.
%}




%% Uppgift 3
%{
Implementera en diskret modell (baserat p� ekvation 6) som reproducerar impulssvaren i 
figur 3 med hj�lp av parameterv�rdena i tabell 1 och ekvation 7.
%}
clc
clf
clear
A = [0.113, 0.213, 0.258, 0.273, 0.1430];
tau0 = [2.0, 12.2, 50.4, 243.3, Inf];
k = 3.06*10^(-3);
kumUtsl = [0, 140, 560, 1680];
tau = @(i,u) tau0(i).*(1+k*kumUtsl(u));

T = 500;
I = zeros(4,T);
for t = 1:T
    for u = 1:4
        for i = 1:length(A)
            I(u,t) = I(u,t) + A(i)*exp(-t/tau(i,u));
        end
    end
end
clf
x = linspace(1,T,T);
hold on
for u = 1:4
    plot(x,I(u,:));
end

%% Uppgift 4 
%{
 N�sta steg �r att implementera en modell baserad p� ekvation 8 och k�ra den med 
utsl�ppen som finns i filen utslappRCP45.m f�r att ber�kna hur koldioxidkoncentrationen hade
utvecklats om kolet endast togs upp i havet. F�r att ber�kna koldioxidkoncentrationen m�ste den 
atmosf�riska kolstocken (dvs den totala massan C i CO2) multipliceras med en omvandlingsfaktor f�r 
massa till volymsandelar i atmosf�ren med ett v�rde p� 0.469 ppmCO2/GtC. J�mf�r era ber�knade 
koncentrationen med koncentrationerna i koncentrationerRCP45.m. 
%}
clc
clf
clear
utslappRCP45
koncentrationerRCP45

CO2toPPM = 0.469; % (ppm CO2)/Gton C
A = [0.113 0.213 0.258 0.273 0.1430];
tau0 = [2.0, 12.2, 50.4, 243.3, Inf];
k = 3.06*10^(-3);
%Utsl = CO2Emissions;
C = CO2ConcRCP45;

tau = @(i,u) tau0(i).*(1+k*CO2Emissions(u));

M = zeros(1, length(CO2Emissions));
M0 = 600;
M(1) = 600;
for t = 2:1:length(CO2Emissions)
    I = 0;
    taui = taufunc(tau0, CO2Emissions, t, k);

    for i = 1:t
        I = I + ifunc(t, i, A, taui)*CO2Emissions(i);
    end
    M(t)=M0 + I;
end

t = linspace(1765, 2500, length(CO2Emissions));
plot(t, CO2toPPM*M)

hold on
plot (t,C)

legend('modell','conc');


%% Uppgift 5
%{
Rita en ny boxmodell motsvarande den i figur 2, d�r ni ut�ver kolfl�dena i biosf�ren och 
atmosf�ren �ven inkluderar nettoupptaget av kol i havet i enlighet impulsresponsmodellen. L�gg �ven 
till de antropogena utsl�ppen i figuren. Ni beh�ver inte kvantifiera n�got utan rita bara hur det ser ut 
rent principiellt. 
%}




%% Uppgift 6 
%{
Koppla samman impulsresponsmodellen f�r havets upptag av CO2 med boxmodellen f�r 
biosf�rens upptag av CO2. Ni m�ste h�r ers�tta utsl�ppen, U(t), i ekvation 8 med h�gerledet i ekvation 
2, dvs de antropogena utsl�ppen minus nettoupptaget av CO2 i den markbundna kolcykeln. T�nk p� att
M i ekvation 8 �r samma variabel som B1 i ekvation 2 (b�da �r den atmosf�riska kolstocken). Ber�kna 
d�refter den atmosf�riska koncentrationen av CO2 givet utsl�ppsdata i utslappRCP45.m och j�mf�r 
modellresultatet med tidsserien f�r de harmoniserade v�rdena givna i koncentrationerRCP45.m. 
Anpassa ? s� att den modellber�knade koncentrationen st�mmer hyffsat v�l �verens med den 
observerade.
%}




%% Uppgift 7
%{
 Analysera var de antropogena utsl�ppen av CO2 tar v�gen p� sikt. Hur mycket �ndras de 
olika kol-stockarna (atmosf�r, biomassa, mark och hav) �r 2100 j�mf�rt med den f�rindustriella niv�n 
och hur beror detta p� ? och ?? F�rs�k f�rklara!
%}