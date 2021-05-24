%% 11 a)
%{
Hur mycket p�verkar valet av referensperiod resultaten? Vad vore en l�mplig 
referensperiod givet att syftet �r att beskriva temperaturf�r�ndringen 
j�mf�rt med f�rindustriell tid? 

Valet av referensperiod p�verkar resultatets f�rskjutning i y-led. Det 
b�sta hade varit att ta ett genomsnitt av temperaturen innan
industrialiseringen, men eftersom vi inte har den datan vore det b�sta att 
ta ett genomsnitt s� tidigt som m�jligt n�r vi har data.  
%}

%% 11 b)
%{
b) Testa med olika v�rden p� klimatk�nslighetsparametern ?(0.5, 0.8 och 1.3 KW-1m2), 
vad h�nder? Skruva p� parametern f�r v�rmeutbytet mellan ytboxen och 
djuphavet ? och skalfaktorn s(f�r aerosol forcing) f�r att hitta ett 
modellsvar som st�mmer v�l �verens med den observerade temperaturanomalin 
enligt NASA. Hitta l�mpliga v�rden p� ? och s f�r de tre olika fallen p� 
klimatk�nslighetsparametern. Vilka v�rden p� ?och stycker ni ger en bra 
anpassning till NASAs temperaturserie f�r de olika antagandena p� 
klimatk�nslighetsparametern?
%}
clc
clf
parameters

subplot(1,2,1)
beta = 0.3;
lambda = 0.5;  % 0.5 - 1.3
kappa  = 0.8;  % 0.2 - 1.0
s      = 0.5;  % ??? - ???
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
lambda = 0.5;  % 0.5 - 1.3
kappa  = 0.5;  % 0.2 - 1.0
s      = 1.0;  % ??? - ???
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
c)?,?, och s �r alla os�kra. Spekulera i m�jligheten att f�rs�ka statistiskt 
skatta dessa v�rden fr�n tidserier p� den globala medeltemperaturen och 
d�rigenom minska os�kerhetsintervallen.
%}

%% 12 
clear
clf
clc
parameters
CO2UpTo2019 = CO2Emissions(1:255);
linearDecline = CO2UpTo2019(end)/51;
CO2Decline = CO2UpTo2019;
for n = 1:51
    CO2Decline(255+n) = (CO2Decline(254+n) - linearDecline);
end
CO2Decline(1, 307:436) = 0;


CO2Constant = CO2UpTo2019;
CO2Constant(1,255:436) = CO2UpTo2019(end);

CO2Increase = CO2UpTo2019;
linearIncrease = 0.5*CO2UpTo2019(end)/81;
for n = 1:81
    CO2Increase(255+n) = (CO2Increase(254+n) + linearIncrease);
end
    
CO2Increase(1,337:436) = 1.5*CO2UpTo2019(end);

plot(CO2Decline)
hold on 
plot(CO2Constant)
hold on 
plot(CO2Increase)

