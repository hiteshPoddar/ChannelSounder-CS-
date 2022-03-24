%% Rx power variation on small distance
clear;
clc;
c = 3e8; 
% p_exp is path loss exponent. Select based on environment.
% Ex: InH 142GHz LOS 2.05  
p_exp = 2.05;
P_tx = 0.61;% mW (Tx power used during measurements)
P_tx_dbm = 10*log10(P_tx); % dBm
f = 142*10^9; % Fc
d = 3.9:0.05:4.1; % d from 3.5 m to 4.5 m in steps of 0.1m
G_tx = 27; % Gain of Tx and Rx horn antenna @ 142GHz
G_rx = 27;
FSPL = 20*log10(4*pi*f/c);
for i=1:length(d)
    PL(i) = FSPL + 10*p_exp*log10(d(i));
    P_rx(i) = P_tx + G_rx + G_tx - PL(i); % in dBm
end
plot(d,P_rx);
xlabel('distance (m)');
ylabel('Power rcvd (dBm)');
% @4m Rcvd Pr = -33.219
% @4.05m Rcvd Pr = -33.33
% @4.10m Rcvd Pr = -33.43

