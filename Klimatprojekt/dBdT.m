function dB = dBdT(i, B)
global U;

alpha = [0,       60/600, 0     ;
         15/600,  0,      45/600;
         45/1500, 0,      0      ];
dB = [0; 0; 0];
dB(1) = alpha(3,1)*B(3) + alpha(2,1)*B(2) - NPP(B(1)) + U(i);
dB(2) = NPP(B(1)) - alpha(2,3)*B(2) - alpha(2,1)*B(2);
dB(3) = alpha(2,3)*B(2) - alpha(3,1)*B(3);
end

function netProd = NPP(B1)
global NPP0; % nettoprimärproduktion förindustriell
global beta; % koldioxidfertiliseringen
global B0;
netProd = NPP0 * (1 + beta*log(B1/B0(1)));
end