function dB = dBdT(i, B, beta, U, B0, NPP0)

alpha = [0,       60/600, 0     ;
         15/600,  0,      45/600;
         45/1500, 0,      0      ];
dB = [0; 0; 0];
dB(1) = alpha(3,1)*B(3) + alpha(2,1)*B(2) - NPP(B(1), beta, B0, NPP0) + U(i);
dB(2) = NPP(B(1), beta, B0, NPP0) - alpha(2,3)*B(2) - alpha(2,1)*B(2);
dB(3) = alpha(2,3)*B(2) - alpha(3,1)*B(3);
end

function netProd = NPP(B1, beta, B0, NPP0)
netProd = NPP0 * (1 + beta*log(B1/B0(1)));
end