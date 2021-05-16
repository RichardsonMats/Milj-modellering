function summa = innerSum(t1, t2, U)
    summa =0;
    A = [0.113 0.213 0.258 0.273 0.1430];
    k = 3.06*10^(-3);
    tau0 = [2.0, 12.2, 50.4, 243.3, Inf];
    tau = ones(length(A));
    
    % the inner sum of Inner sum in exponential
    for i = 1:length(A)
        tau(i) = tau0(i)*(1+k*sum(U(1:t2)));
    end

    for i = 1:length(A)
        summa = summa + A(i)*exp(-t1/tau(i));
    end
end