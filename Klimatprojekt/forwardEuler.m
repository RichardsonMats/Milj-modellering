function [B, t] = forwardEuler (dBdT, t)
% N = number of time steps = legnth of CO2 emissions
parameters


B = zeros (numel(B0) , length(t)); % Initialize the B matrix .
B(:, 1) = B0(:); % Start B at the initial value .
    for i = 1:(length(t) -1)
        B(:, i +1) = B(:, i) + dBdT(i, B(:, i)); % Update approximation B at t+h
    end
end
