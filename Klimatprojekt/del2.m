%% Uppgift 8
% parametrar
% Konstruera en radiative forcing modul med hjälp av beskrivningen ovan. ???2(dvs det
%partiella trycket eller koncentrationen) kan erhållas från er kolcykelmodell eller från koncentration i
%koncentrationerRCP45.m. Berkna och visa i en figur RF för CO2, jämför dessa värden med radiative
%forcing för CO2 i radiativeForcingRCP45.m.
clc
clf
clear
parameters

p0 = CO2ConcRCP45(1);

for r = 1:length(CO2ConcRCP45)
    %Ekv 9
    RFCO2(r) = 5.35 * log(CO2ConcRCP45(r)/p0);
end


plot(RFCO2, 'green')
hold on
plot(CO2RadForc, 'blue')
legend('calculated RF', 'given RF')
ylabel('W/m^2');
xlabel('years');
title('radiative forcing from CO2 emissions')
%% Uppgift 9: Summera RF för andra klimatpåverkande ämnen och RF för aerosoler, dessa finner du i
%filen radiativeForcingRCP45.m. Multiplicera RF för aerosoler med en skalfaktor, s, med
%standardvärde lika med 1. I denna laboration kommer vi låta s vara 1, men i det avslutande
%klimatprojektet ska detta värde varieras. Anledningen till skalfaktorn används är att osäkerheten är stor
%kring hur mycket kylande effekt som aerosolerna har.

clc 
clf
parameters

RFCO2 = zeros(1, length(CO2ConcRCP45));
RFCH4 = zeros(1, length(CH4Conc));
RFN2H = zeros(1, length(N2OConc));
summa = zeros(1, length(CH4Conc));


pCO0=CO2ConcRCP45(1);
pCH40=CH4Conc(1);
pN20=N2OConc(1);


for g = 1:length(CO2ConcRCP45)
    % fråga om 5.35 ska användas för formeln även till andra gaser än CO2?
    RFCO2(g) = 5.35*log(CO2ConcRCP45(g)/pCO0);
    RFCH4(g) = 5.35*log(CH4Conc(g)/pCH40);
    RFN2H(g) = 5.35*log(N2OConc(g)/pN20);
    summa(g) = RFCO2(g)+ RFCH4(g) + RFN2H(g);
end


t = linspace(t0,T,736);
plot (t, summa, 'blue');
hold on
plot (t, RFCO2, 'yellow');
plot(t, CO2RadForc, 'm');
plot (t, RFCH4, 'black');
plot(t, RFN2H, 'red');
plot(t, totRadForcAerosols, 'green');
plot(t, totRadForcExclCO2AndAerosols, 'c')
legend('Sum', 'RFCO2', 'other RFCO2', 'RFCH4', 'RFN2H', 'Aero', 'tot other');
xlabel('year') 
ylabel('change in absorbed effect from sun [W/m^2]')


%% Uppgift 10 
%{ 
Diskretisera ekvationerna 10& 11, användförslagsvis en Euler framåt metod 
med årligt tidssteg.Använd de diskretiserade versionerna av ekvationerna 
10&11tillsammans med parametervärden nedan för att simulera energibalansmodellen. 
a)Testa modellen genom att analysera temperatursvaret baserat på ett radiative
forcing steg på 1 W/m2. Vad blir den simulerade jämviktstemperaturen? 
Verifiera numeriskt genom att göra modellens tidshorisont tillräcklig lång 
(jämviktstemperatur är ??1=??2=????, det är bra om ni inser detta från 
ekvation 10& 11). 
%} 

clc 
clf
parameters


lambda = 0.8;
kappa = 0.5;
RF = 1;
yr = 1/(3600*24*365);
C1 = c*h*rho*yr;
C2 = c*d*rho*yr;

% C1 * dT1dt = RF - dT2 / lambda - kappa*(dT1 - dT2)
% C2 * dT2dt = kappa*(dT1 - dT2)


t1 = 1965;
N = t1-t0;
t = linspace(t0,t1,N);

dT1 = zeros(1,N);
dT2 = zeros(1,N);

for i=1:N-1
    dT1(i+1) = dT1(i) + (RF - dT1(i)/lambda - kappa*(dT1(i) - dT2(i)))/C1;
    dT2(i+1) = dT2(i) + (kappa*(dT1(i) - dT2(i)))/C2;
end

hold on
plot(t, dT1, 'c');
plot(t, dT2, 'b');
legend('ythav', 'djuphav');

%% b) Analysera vilken effekt klimatkänslighetsparameter ? och ? har på tiden det tar att uppnå 
%jämviktstemperatur. Den transienta fasen, dvs fram till systemet når jämvikt, kan analyseras 
%med hjälp av att beräkna "e-folding time", dvs tiden det tar det innan temperatursvaret svaret 
%når 1-e
%-1
%av sin jämviktsnivå, för olika värden på klimatkänslighetsparameter ? och ?. 
%Rimliga värden för ? är mellan 0.5 och 1.3 K/(W/m2
%) och för ? mellan 0.2 och 1 [W?K -1
%?m-2
%]. 
%Försök att intuitivt förstå resultaten. Försök att förstå varför ??1 och ??2 utvecklas som de gör 
%och hur de beror på valet av ? och ?.

clc
clf

t1 = 5000;
N = t1-t0;
t = linspace(t0,t1,N);
dT1 = zeros(1,N);
dT2 = zeros(1,N);


kappa = 1.0; % 0.2 - 1
lambda = 0.8; % 0.5 - 1.3
RF = 1;

time = 1;
for i=1:N-1
    dT1(i+1) = dT1(i) + (RF - dT1(i)/lambda - kappa*(dT1(i) - dT2(i)))/C1;
    dT2(i+1) = dT2(i) + (kappa*(dT1(i) - dT2(i)))/C2;
    konvT1 = dT1(i+1)/(lambda*RF);
    konvT2 = dT2(i+1)/(lambda*RF);
    if(konvT1 >= (1-exp(-1)) && konvT2 >= (1-exp(-1)))
        break
    end
    time = time+1;
end

% disp("lambda = " + lambda + ", kappa = " + kappa + ": " + time)
disp("   " + lambda + "   " + kappa + "   " + time)

%{
%Lambda är vilken temperatur och kappa är hur fort vi kommer dit
lambda kappa years
   0.5   0.5   680
   0.7   0.5   736
   0.9   0.5   791
   1.1   0.5   847
   1.3   0.5   902

   0.8   0.2   1576
   0.8   0.4   899
   0.8   0.6   673
   0.8   0.8   561
   0.8   1.0   493
%}

%% c)
%{ 
C: Analysera energiflödena (radiative forcing, energiupptag i havet och 
utgående värmestrålning till rymden) för steget och de parameterval som ni
använde i uppgift 10b. Hur beror havets värmeupptag och värmestrålningen 
till rymden på ? och och ?? Analysera flödena för tidshorisont på 200 år och 
försök förstå resultaten intuitivt. 
%}
clc
clf
parameters

% params = [kappa, lambda]
params = [[0.2, 0.8]; [1.0, 0.8]; [0.5, 0.5]; [0.5, 1.3]]
RF = 1;


t1 = 1765+200;
N = t1-t0;
t = linspace(t0,t1,N);
dT1 = zeros(4,N);
dT2 = zeros(4,N);

for p=1:4
    for i=1:N-1
        dT1(p,i+1) = dT1(p,i) + (RF - dT1(p,i)/params(p,2) - params(p,1)*(dT1(p,i) - dT2(p,i)))/C1;
        dT2(p,i+1) = dT2(p,i) + (params(p,1)*(dT1(p,i) - dT2(p,i)))/C2;
    end
end
subplot(2,2,1)
hold on
plot(t, dT1(1,1:200)/lambda, 'r');
plot(t, ones(1,200)*RF, 'g');
plot(t, kappa*(dT1(1,1:200)-dT2(1,1:200)), 'b')
legend('till rymden', 'RF', 'till djup havet')
title('kappa = 0.2, lambda = 0.8');

subplot(2,2,2)
hold on
plot(t, dT1(2,1:200)/lambda, 'r');
plot(t, ones(1,200)*RF, 'g');
plot(t, kappa*(dT1(2,1:200)-dT2(2,1:200)), 'b')
legend('till rymden', 'RF', 'till djup havet')
title('kappa = 1.0, lambda = 0.8');

subplot(2,2,3)
hold on
plot(t, dT1(3,1:200)/lambda, 'r');
plot(t, ones(1,200)*RF, 'g');
plot(t, kappa*(dT1(3,1:200)-dT2(3,1:200)), 'b')
legend('till rymden', 'RF', 'till djup havet')
title('kappa = 0.5, lambda = 0.5');

subplot(2,2,4)
hold on
plot(t, dT1(4,1:200)/lambda, 'r');
plot(t, ones(1,200)*RF, 'g');
plot(t, kappa*(dT1(4,1:200)-dT2(4,1:200)), 'b')
legend('till rymden', 'RF', 'till djup havet')
title('kappa = 0.5, lambda = 1.3');

