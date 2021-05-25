%% 11 a)
%{
Hur mycket påverkar valet av referensperiod resultaten? Vad vore en lämplig 
referensperiod givet att syftet är att beskriva temperaturförändringen 
jämfört med förindustriell tid? 

Valet av referensperiod påverkar resultatets förskjutning i y-led. Det 
bästa hade varit att ta ett genomsnitt av temperaturen innan
industrialiseringen, men eftersom vi inte har den datan vore det bästa att 
ta ett genomsnitt så tidigt som möjligt när vi har data.  
%}

%% 11 b)
%{
b) Testa med olika värden på klimatkänslighetsparametern ?(0.5, 0.8 och 1.3 KW-1m2), 
vad händer? Skruva på parametern för värmeutbytet mellan ytboxen och 
djuphavet ? och skalfaktorn s(för aerosol forcing) för att hitta ett 
modellsvar som stämmer väl överens med den observerade temperaturanomalin 
enligt NASA. Hitta lämpliga värden på ? och s för de tre olika fallen på 
klimatkänslighetsparametern. Vilka värden på ?och stycker ni ger en bra 
anpassning till NASAs temperaturserie för de olika antagandena på 
klimatkänslighetsparametern?
%}
clc
clf
parameters

subplot(1,2,1)
beta = 0.3;
lambda = 1.3;  % 0.5 - 1.3
kappa  = 0.9;  % 0.2 - 1.0
s      = 1.5;  % ??? - ???
start = 1879;
stop = 2019;
[t,data] = del3(beta, lambda, kappa, s, start, stop);
hold on
plot(t, data, 'b');
plot(t, TAnomali, 'black');
title("lambda = " + lambda + ", kappa = " + kappa + ", s = " + s);
legend('modell', 'NASA');
legend('Location','southeast')

subplot(1,2,2)
beta = 0.3;
lambda = 1.3;  % 0.5 - 1.3
kappa  = 0.8;  % 0.2 - 1.0
s      = 1.4;  % ??? - ???
start = 1879;
stop = 2019;
[t,data] = del3(beta, lambda, kappa, s, start, stop);
hold on
plot(t, data, 'b');
plot(t, TAnomali, 'black');
title("lambda = " + lambda + ", kappa = " + kappa + ", s = " + s);
legend('modell', 'NASA');
legend('Location','southeast')

%% 11 c)
%{
c)?, ?, och s är alla osäkra. Spekulera i möjligheten att försöka statistiskt 
skatta dessa värden från tidserier på den globala medeltemperaturen och 
därigenom minska osäkerhetsintervallen.

lambda: beror bla på radiative forcing som beror på CO2-utsläpp. Detta finns
det data på, alltså går parametern att skatta statistiskt.
kappa: mått på hur snabbt djuphaven värms upp av ythaven. detta borde
teoretiskt gå om man har datan?
s: 
%}


%% 12 
clear
clf
clc
parameters

kappa = 0.6;
s =1.2;

N = length(CO2Emissions);


CO2UpTo2019 = CO2Emissions(1:255);
linearDecline = CO2UpTo2019(end)/51;
CO2Decline = CO2UpTo2019;
for n = 1:51
    CO2Decline(255+n) = (CO2Decline(254+n) - linearDecline);
end
CO2Decline(1, 307:736) = 0;



CO2Constant = CO2UpTo2019;
CO2Constant(1,255:736) = CO2UpTo2019(end);

CO2Increase = CO2UpTo2019;
linearIncrease = 0.5*CO2UpTo2019(end)/81;
for n = 1:81
    CO2Increase(255+n) = (CO2Increase(254+n) + linearIncrease);
end
    
CO2Increase(1,337:436) = 1.5*CO2UpTo2019(end);
CO2Increase(1,337:736) = 1.5*CO2UpTo2019(end);


CO2Versions(1,:) = CO2Decline;
CO2Versions(2,:) = CO2Constant;
CO2Versions(3,:) = CO2Increase;

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
dT1 = zeros(1,N);
dT2 = zeros(1,N);
T1 = zeros(1,N);
T2 = zeros(1,N);
kParam = k;
NPP = zeros(1,length(CO2Emissions));
NPP(1) = NPP0;
yr = 1/(3600*24*365);
C1 = c*h*rho*yr;
C2 = c*d*rho*yr;


for y = 1:3
    Utslapp = CO2Versions(y,:);
    for k = 1:length(CO2Emissions)
        dBdt1(k+1) = (alpha(3,1)*B(3,k) + alpha(2,1)*B(2,k)- NPP(k)+CO2Versions(y,k));
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
        deltaT1 = T1(i) -T1(1);
        deltaT2 = T2(i) - T2(1);
    
        dT1(i+1) = (RFtot(i) - deltaT1/lambda - kappa*(deltaT1-deltaT2))/C1;
        dT2(i+1) = (kappa*(deltaT1-deltaT2))/C2;
        T1(i+1) = T1(i) + dT1(i);
        T2(i+1) = T2(i) + dT2(i);
    end
    
    yPlots(y,:) = T1(:);
    
end


plot(1766:2019, yPlots(1, 1:254), 'blue')
hold on
plot(2019:2102,yPlots(1, 254:337),'--g')
hold on
plot(2019:2102,yPlots(2, 254:337),'--y')
hold on
plot(2019:2102,yPlots(3, 254:337),'--r')
title("lambda = " + lambda + ", kappa = " + kappa + ", s = " + s);
legend('modell', 'Decreasing CO2', 'Constant CO2', 'Increasing CO2');
legend('Location','southeast')
