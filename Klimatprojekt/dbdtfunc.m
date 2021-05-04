function dbdt = dbdtfunc(alpha, NPP, utslapp)
    dbdt = [alpha(3,1)*B(3)+ alpha(2,1)* B(2) - NPP + utslapp;
            NPP - alpha(2,3)*B(2)-alpha(2,1)*B(2);
            alpha(2,3)*B(2)-alpha(3,1)*B(3)];
       
end