%% Dynamic range calcuation for channel sounder
clear; 
close all;
T = 298; %Noise tempearature (K)
k = physconst('Boltzmann');
B = 2*2.5e6; % Oscilloscope sampling rate - 2.5 Msps @ 1 GHz Null - Null BW 
G_Tx = 27; % Gain of Tx Horn Antenna @ 142 GHz
G_RX =27;  % Gain of Rx Horn Antenna @ 142 GHz
NF = 10; %dB
SNR_min = 5; % Detect 5dB SNR above noise threshold
% SNR(dB) = Prx (dB) - NF(dB) - 10log(KTB) (dB)
P_RX_min_140 = SNR_min + NF + 10*log10(k*T*B) + 30; % Rx power in dBm
% Prx (dB) = Ptx (dBm) + G_Tx + G_Rx - PL(dB)  
PL_max_th_140 = 0 + G_Tx + G_RX - P_RX_min_140; % PL in DB