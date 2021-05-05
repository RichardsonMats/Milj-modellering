function I = ifunc(t,t2, A, tau)
    I =0;
    for i = 1:length(A)
        I=I + A(i) * exp((-(t-t2))/tau(i));
    end