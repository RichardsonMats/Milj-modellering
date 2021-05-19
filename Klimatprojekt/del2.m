%% Uppgift 8
% parametrar
% Konstruera en radiative forcing modul med hj�lp av beskrivningen ovan. ???2(dvs det
%partiella trycket eller koncentrationen) kan erh�llas fr�n er kolcykelmodell eller fr�n koncentration i
%koncentrationerRCP45.m. Berkna och visa i en figur RF f�r CO2, j�mf�r dessa v�rden med radiative
%forcing f�r CO2 i radiativeForcingRCP45.m.
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
%% Uppgift 9: Summera RF f�r andra klimatp�verkande �mnen och RF f�r aerosoler, dessa finner du i
%filen radiativeForcingRCP45.m. Multiplicera RF f�r aerosoler med en skalfaktor, s, med
%standardv�rde lika med 1. I denna laboration kommer vi l�ta s vara 1, men i det avslutande
%klimatprojektet ska detta v�rde varieras. Anledningen till skalfaktorn anv�nds �r att os�kerheten �r stor
%kring hur mycket kylande effekt som aerosolerna har.

clc 
clf
radiativeForcingRCP45

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

t0 = 1765;
T = 2500;
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

% Parameterv�rden:
% ? = klimatk�nslighetsparametern = 0.8 [K?W-1?m2], spann 0.5-1.3 [K?W-1?m2].
% ?= utbyteskoefficienten=0.5 [W?K-1?m-2], spann 0.2-1 [W?K-1?m-2]. 
% RF = radiative forcing [W/m2].
% c = Vattnets specifika v�rmekapacitet = 4186 (J/kg)/K.
% ?= Vattnets densitet =1020 kg/m3
% h = Ytboxens effektiva djup = 50 m.
% C1= c?h??= Ytboxens effektiva v�rmekapacitet. Ni f�r r�kna om s� att parametern har enheten[W?yr?K-1?m-2].
% d= Djuphavsboxens effektiva djup = 2000 m.
% C2= c?d??= Djuphavsboxens effektiva v�rmekapacitet. Ni f�r r�kna om s� att parametern har enheten[W?yr?K-1?m-2].

clc 
clf

lambda = 0.8;
kappa = 0.5;
RF = 1;
c = 4186;
rho = 1020;
h = 50;
d = 2000;
yr = 1/(3600*24*365);
C1 = c*h*rho*yr;
C2 = c*d*rho*yr;

% C1 * dT1dt = RF - dT2 / lambda - kappa*(dT1 - dT2)
% C2 * dT2dt = kappa*(dT1 - dT2)

N = 736;
t0 = 1765;
T = 2500;
t = linspace(t0,T,N);

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



