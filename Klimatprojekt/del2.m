%% Uppgift 8
% parametrar
% Konstruera en radiative forcing modul med hj�lp av beskrivningen ovan. ???2(dvs det
%partiella trycket eller koncentrationen) kan erh�llas fr�n er kolcykelmodell eller fr�n koncentration i
%koncentrationerRCP45.m. Berkna och visa i en figur RF f�r CO2, j�mf�r dessa v�rden med radiative
%forcing f�r CO2 i radiativeForcingRCP45.m.
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
%% Uppgift 9: Summera RF f�r andra klimatp�verkande �mnen och RF f�r aerosoler, dessa finner du i
%filen radiativeForcingRCP45.m. Multiplicera RF f�r aerosoler med en skalfaktor, s, med
%standardv�rde lika med 1. I denna laboration kommer vi l�ta s vara 1, men i det avslutande
%klimatprojektet ska detta v�rde varieras. Anledningen till skalfaktorn anv�nds �r att os�kerheten �r stor
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
    % fr�ga om 5.35 ska anv�ndas f�r formeln �ven till andra gaser �n CO2?
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
Diskretisera ekvationerna 10& 11, anv�ndf�rslagsvis en Euler fram�t metod 
med �rligt tidssteg.Anv�nd de diskretiserade versionerna av ekvationerna 
10&11tillsammans med parameterv�rden nedan f�r att simulera energibalansmodellen. 
a)Testa modellen genom att analysera temperatursvaret baserat p� ett radiative
forcing steg p� 1 W/m2. Vad blir den simulerade j�mviktstemperaturen? 
Verifiera numeriskt genom att g�ra modellens tidshorisont tillr�cklig l�ng 
(j�mviktstemperatur �r ??1=??2=????, det �r bra om ni inser detta fr�n 
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

%% b) Analysera vilken effekt klimatk�nslighetsparameter ? och ? har p� tiden det tar att uppn� 
%j�mviktstemperatur. Den transienta fasen, dvs fram till systemet n�r j�mvikt, kan analyseras 
%med hj�lp av att ber�kna "e-folding time", dvs tiden det tar det innan temperatursvaret svaret 
%n�r 1-e
%-1
%av sin j�mviktsniv�, f�r olika v�rden p� klimatk�nslighetsparameter ? och ?. 
%Rimliga v�rden f�r ? �r mellan 0.5 och 1.3 K/(W/m2
%) och f�r ? mellan 0.2 och 1 [W?K -1
%?m-2
%]. 
%F�rs�k att intuitivt f�rst� resultaten. F�rs�k att f�rst� varf�r ??1 och ??2 utvecklas som de g�r 
%och hur de beror p� valet av ? och ?.

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
%Lambda �r vilken temperatur och kappa �r hur fort vi kommer dit
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
C: Analysera energifl�dena (radiative forcing, energiupptag i havet och 
utg�ende v�rmestr�lning till rymden) f�r steget och de parameterval som ni
anv�nde i uppgift 10b. Hur beror havets v�rmeupptag och v�rmestr�lningen 
till rymden p� ? och och ?? Analysera fl�dena f�r tidshorisont p� 200 �r och 
f�rs�k f�rst� resultaten intuitivt. 
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

