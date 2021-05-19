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
legend('B1: Atmosfär','B2: Biomassa ovan mark','B3: under marken');
title('beta = 0.1');

subplot(2,2,2)
beta = 0.35;
[B, t] = forwardEuler (@dBdT, t);
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])
legend('B1: Atmosfär','B2: Biomassa ovan mark','B3: under marken');
title('beta = 0.35');

subplot(2,2,3)
beta = 0.6;
[B, t] = forwardEuler (@dBdT, t);
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])
legend('B1: Atmosfär','B2: Biomassa ovan mark','B3: under marken');
title('beta = 0.6');

subplot(2,2,4)
beta = 0.8;
[B, t] = forwardEuler (@dBdT, t);
hold on
plot(t, B(1,:))
plot(t, B(2,:))
plot(t, B(3,:))
axis([1750 2500 0 2500])
legend('B1: Atmosfär','B2: Biomassa ovan mark','B3: under marken');
title('beta = 0.8');

%{
När Beta ökar så skapas det mer biomassa samt kol bundet i marken. Mängden
kol i atmosfären minskar dock. Från detta kan vi anta att Beta är ett mått 
på hur effektivt växterna omvandlar CO2 till biomassa. Högre Beta leder 
därmed till att mer luftbunden CO2 används för att skapa mer biomassa, som 
i sin tur binder mer kol i marken.
%}




%% Uppgift 3
%{
Implementera en diskret modell (baserat på ekvation 6) som reproducerar impulssvaren i 
figur 3 med hjälp av parametervärdena i tabell 1 och ekvation 7.
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
 Nästa steg är att implementera en modell baserad på ekvation 8 och köra den med 
utsläppen som finns i filen utslappRCP45.m för att beräkna hur koldioxidkoncentrationen hade
utvecklats om kolet endast togs upp i havet. För att beräkna koldioxidkoncentrationen måste den 
atmosfäriska kolstocken (dvs den totala massan C i CO2) multipliceras med en omvandlingsfaktor för 
massa till volymsandelar i atmosfären med ett värde på 0.469 ppmCO2/GtC. Jämför era beräknade 
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

clear
clc
clf
utslappRCP45
koncentrationerRCP45
CO2toPPM = 0.469; % (ppm CO2)/Gton C

alpha = zeros(3,3);
alpha(3,1)=45/1500;
alpha(2,3)=45/600;
alpha(2,1)=15/600;

B0=[600 600 1500];

beta = 0.3;
NPP0=60;
NPP=NPP0;
B(1,1) = B0(1);
B(2,1) = B0(2);
B(3,1) = B0(3);
dBdt1 = 0;
dBdt2 = 0;
dBdt3 = 0;

for k = 1:length(CO2Emissions)
    dBdt1(k+1) = (alpha(3,1)*B(3,k) + alpha(2,1)*B(2,k)-NPP(k)+CO2Emissions(k));
    B(1, k+1) = mFunc(k+1, dBdt1);
    dBdt2(k+1) = NPP(k) - alpha(2,3)*B(2,k) - alpha(2,1)*B(2,k);
    dBdt3(k+1) =  alpha(2,3)*B(2,k)-alpha(3,1)*B(3,k);
    
    B(2, k+1)=B(2,k) + dBdt2(k);
    B(3, k+1)= B(3,k) + dBdt3(k);
    
    NPP(k+1) = NPP0 * (1+ beta * log(B(1, k+1)/B0(1)));
end

t0 = 1765;
T = 2500;
N = length(CO2Emissions);
t = linspace(t0,T,N);

B0tot = sum(B0);
Emtot = zeros(1,length(CO2Emissions));
Emtot(1) = B0tot;
Bsea = zeros(1,length(CO2Emissions));
for i = 1:length(CO2Emissions)-1 
    Emtot(i+1) = Emtot(i) + CO2Emissions(i);
    Bsea(i+1) = Emtot(i+1) - B(1,i+1) - B(2,i+1) - B(3,i+1);
end    

disp("atm: " + B(1,(2100-1765)))
disp("bio: " + B(2,(2100-1765)))
disp("ber: " + B(3,(2100-1765)))
disp("hav: " + Bsea(2100-1765))

plot(t, CO2ConcRCP45);
hold on
t = linspace(t0,T,N+1);
plot(t,B(1,:)*CO2toPPM)

axis([1750 2500 0 1000]);

%% Uppgift 7
% Analysera var de antropogena utsläppen av CO2 tar vägen på sikt. 
% Hur mycket ändras de olika kol-stockarna (atmosfär, biomassa, mark och hav)
% år 2100 jämfört med den förindustriella nivån och hur beror detta på k
% och beta?
% Försök förklara!
%{ 
                          atmosfär  biomassa  underjord  hav
         förindustriellt:     600       600       1500     0
beta=0.1, k=3.06*10^(-3):    1321       647       1601   404
beta=0.3, k=3.06*10^(-3):    1153       717       1753   350
beta=0.7, k=3.06*10^(-3):     965       798       1935   274

beta=0.3, k=1.06*10^(-3):    1085       706       1732   449
beta=0.3, k=3.06*10^(-3):    1153       717       1753   350
beta=0.3, k=6.06*10^(-3):    1204       724       1767   277
%}






