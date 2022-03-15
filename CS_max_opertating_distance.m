%% Distance calculation over which channel sounder can operate
clear;
clc;
c = 3e8; 
% p_exp is path loss exponent. Select based on environment.
% Ex: InH 142GHz LOS - 2.05 NLOS - 4.60 (picked from papers)  
p_exp = 2.05;
P_tx = 0.61;% mW (Tx power used during measurements)
P_tx_dbm = 10*log10(P_tx); % dBm
f = 142*10^9; % Fc
d = 2500; % max distance (in meters) channel sounder can measure in InH LOS.
G_tx = 27; % Gain of Tx and Rx horn antenna @ 142GHz
G_rx = 27;
FSPL = 20*log10(4*pi*f/c);
PL = FSPL + 10*p_exp*log10(d);
P_rx = P_tx + G_rx + G_tx - PL;
% From dynamic range of channel sounder find the min_Rx_power the
% channel sounder can rcv. @142 GHz we found this to be -91.00 dBm 
% (code: Dynamic_range_CS.m). 