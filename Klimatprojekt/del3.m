clear 
clc 
clf
parameters

alpha = zeros(3,3);
alpha(3,1)=45/1500;
alpha(2,3)=45/600;
alpha(2,1)=15/600;

NPP = zeros(1,length(CO2Emissions));
NPP(1) = NPP0;
B(1,1) = B0(1);
B(2,1) = B0(2);
B(3,1) = B0(3);
dBdt1 = zeros(1,length(CO2Emissions));
dBdt2 = zeros(1,length(CO2Emissions));
dBdt3 = zeros(1,length(CO2Emissions));
kParam = k;
beta = 0.28;


for k = 1:length(CO2Emissions)
    dBdt1(k+1) = (alpha(3,1)*B(3,k) + alpha(2,1)*B(2,k)- NPP(k)+CO2Emissions(k));
    B(1, k+1) = mFunc(k+1, dBdt1, kParam);
    dBdt2(k+1) = NPP(k) - alpha(2,3)*B(2,k) - alpha(2,1)*B(2,k);
    dBdt3(k+1) =  alpha(2,3)*B(2,k)-alpha(3,1)*B(3,k);
    B(2, k+1)=B(2,k) + dBdt2(k);
    B(3, k+1)= B(3,k) + dBdt3(k);
    
    NPP(k+1) = NPP0 * (1+ beta * log(B(1, k+1)/B0(1)));
end

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

disp("kolstockar år 2500 med k = " + kParam + ", beta = " + beta)
disp("atm: " + B(1,(2100-1765)))
disp("bio: " + B(2,(2100-1765)))
disp("ber: " + B(3,(2100-1765)))
disp("hav: " + Bsea(2100-1765))


%%%%%%%%%%%%%%%%%%%%%% beräkna Radiative Forcing %%%%%%%%%%%%%%%%%%%%%%%%%%

RFCO2 = zeros(1, length(CO2ConcRCP45));
RFCH4 = zeros(1, length(CH4Conc));
RFN2H = zeros(1, length(N2OConc));
RFtot = zeros(1, length(CH4Conc));

pCO0 = B0(1)/CO2toPPM;
pCH40 = CH4Conc(1);
pN20 = N2OConc(1);
s = 1.2;


for g = 1:length(CO2ConcRCP45)
    % fråga om 5.35 ska användas för formeln även till andra gaser än CO2?
    CO2_change = (B(1,g))/CO2toPPM;
    RFCO2(g) = 5.35*log(CO2_change/pCO0);
    RFtot(g) = RFCO2(g)+ s*totRadForcAerosols(g) + totRadForcExclCO2AndAerosols(g);
end

rfTot2 = 5.35*log(B(1,:)/B(1,1));
rfTot2 = rfTot2(1:(length(rfTot2)-1)) + s*totRadForcAerosols + totRadForcExclCO2AndAerosols;

%{
t = linspace(t0,T,736);
hold on
plot (t, RFCO2, 'yellow');
plot(t, CO2RadForc, 'm');
plot (t, RFtot, 'blue');
legend('vår RFCO2', 'RCP RFCO2', 'Sum');
xlabel('year') 
ylabel('change in absorbed effect from sun [W/m^2]')
%}

%%%%%%%%%%%%%%%%%%%%%% beräkna temperaturförändring %%%%%%%%%%%%%%%%%%%%%%%

lambda = 0.8;
kappa = 0.6;
yr = 1/(3600*24*365);
C1 = c*h*rho*yr;
C2 = c*d*rho*yr;

t_start = 1879;
t_stop = 2019;
N = t_stop - t_start;
t = linspace(t_start, t_stop, N);

dT1 = zeros(1,N);
dT2 = zeros(1,N);
T1 = zeros(1,N);
T2 = zeros(1,N);

for i=1:N-1
    % C1 * dT1dt = RF - dT2 / lambda - kappa*(dT1 - dT2)
    % C2 * dT2dt = kappa*(dT1 - dT2)
    deltaT1 = T1(i) -T1(1);
    deltaT2 = T2(i) - T2(1);
    
    dT1(i+1) = (RFtot(i+114) - deltaT1/lambda - kappa*(deltaT1-deltaT2))/C1;
    dT2(i+1) = (kappa*(deltaT1-deltaT2))/C2;
    T1(i+1) =T1(i) + dT1(i);
    T2(i+1) = T2(i) + dT2(i);
end

mean = sum(T1(71:100))/30

T1 = T1-mean;


hold on
plot(t, T1, 'c');
plot(t, T2, 'red');
plot(t, TAnomali, 'black');
legend('ythav','djup', 'NASA');
title('s=1.2, lambda = 0.8, kappa = 0.6');


