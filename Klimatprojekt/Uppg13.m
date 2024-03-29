%% 

clear
clc
clf
parameters

NPP = NPP0;
kappa = 0.6;
s =1.2;
N = length(CO2Emissions);

alpha = zeros(3,3);
alpha(3,1)=45/1500;
alpha(2,3)=45/600;
alpha(2,1)=15/600;

B(1,1) = B0(1);
B(2,1) = B0(2);
B(3,1) = B0(3);
dBdt1 = zeros(1,length(CO2Emissions));
dBdt2 = zeros(1,length(CO2Emissions));
dBdt3 = zeros(1,length(CO2Emissions));
kParam = k;
dT1 = zeros(1,N);
dT2 = zeros(1,N);
T1 = zeros(1,N);
T2 = zeros(1,N);

yr = 1/(3600*24*365);
C1 = c*h*rho*yr;
C2 = c*d*rho*yr;

CO2UpTo2019 = CO2Emissions(1:255);
CO2Increase = CO2UpTo2019;
linearIncrease = 0.5*CO2UpTo2019(end)/81;
for n = 1:81
    CO2Increase(255+n) = (CO2Increase(254+n) + linearIncrease);
end
    
CO2Increase(1,337:436) = 1.5*CO2UpTo2019(end);
CO2Increase(1,337:736) = 1.5*CO2UpTo2019(end);

for k = 1:length(CO2Emissions)
    dBdt1(k+1) = (alpha(3,1)*B(3,k) + alpha(2,1)*B(2,k)- NPP(k)+CO2Increase(k));
    B(1, k+1) = mFunc(k+1, dBdt1, kParam);
    dBdt2(k+1) = NPP(k) - alpha(2,3)*B(2,k) - alpha(2,1)*B(2,k);
    dBdt3(k+1) =  alpha(2,3)*B(2,k)-alpha(3,1)*B(3,k);
    B(2, k+1)=B(2,k) + dBdt2(k);
    B(3, k+1)= B(3,k) + dBdt3(k);
    
    NPP(k+1) = NPP0 * (1+ beta * log(B(1, k+1)/B0(1)));
end

RFCO2 = zeros(1, length(CO2ConcRCP45));
RFtot = zeros(1, length(CH4Conc));
pCO0 = B0(1)/CO2toPPM;
for g = 1:length(CO2ConcRCP45)
       
    CO2_change = (B(1,g))/CO2toPPM;
    RFCO2(g) = 5.35*log(CO2_change/pCO0);
    RFtot(g) = RFCO2(g) + s*totRadForcAerosols(g) + totRadForcExclCO2AndAerosols(g);
end

for i=1:N-1
    % C1 * dT1dt = RF - dT2 / lambda - kappa*(dT1 - dT2)
    % C2 * dT2dt = kappa*(dT1 - dT2)
    deltaT1 = T1(i) -T1(1);
    deltaT2 = T2(i) - T2(1);
    
    % minska solstr�lning med 4 W/m2 2050-2100
    % 2050 -1765 = 285, 285+50 =335
    if i > 285 && i < 335
        RFtot(i) = RFtot(i)-4;
    end
    
    
    dT1(i+1) = (RFtot(i) - deltaT1/lambda - kappa*(deltaT1-deltaT2))/C1;
    dT2(i+1) = (kappa*(deltaT1-deltaT2))/C2;
    T1(i+1) = T1(i) + dT1(i);
    T2(i+1) = T2(i) + dT2(i);
end

mean = sum(T1(71:100))/30;
T1 = T1-mean;

plot(1800:2200, T1(35:435))

xlabel('�r')
ylabel('Temperatur')
