function summa = mFunc(t,U,k)
    M0 = 600;
    summa = M0;
    for tPrim = 1:t
        summa = summa + innerSum(t-tPrim, t, U,k) *U(tPrim);
    end