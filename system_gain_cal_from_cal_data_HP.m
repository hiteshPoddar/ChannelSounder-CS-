%% Code to Find System Gain of the channel sounder from Calibration.
tic
clear;
clc;
c = 3*10^8; % m/s
% ------- Local Variables ---------------------------------------------
avg_pwr_dbm = zeros(1,10);
max_pwr = zeros(1,10);
max_pwr_idx = zeros(1,10);
attenuations = (0:9)*10;

%% Extracting Data from the folder
% go to 142 GHz -> Calibration Area -> Calibration. Inside calibration
% there is Attenuation 0 dB to Attenuation 90 dB. Go inside each folder and
% fetch IQsqaured.txt file and store it in a calibrtion database.
dir = 'F:\';
folder_name = '142 GHz\';
folder_name = strcat(dir,folder_name);
% calibration database(cali_db) contains all the attenuations imported from IQsquaredfile.
% Ex: cali_db{1,1} ------- has data from Attenuation 0.
% Ex: cali_db{1,1}(:,1) -- fetches the time(ns) from Attenuation 0.The time here is time dilated.
% dB, Attenuations_db{1,1}(:,2) -- fetches the power values(dBm) from Attenuation 0.
cali_db = cell(1,10);
for index = 1:10
    str = strcat('Attenuation'," ",num2str((index-1)*10),' dB');
    path = strcat(folder_name,'Calibration Area\Calibration 1\',str,'\IQsquared.txt');
    cali_db{index} = importdata(path);
end

%% Fetch the True Tx power from pdpLogFile
path1 = strcat(folder_name,'Calibration Area\Calibration 1\Attenuation 0 dB\pdpLogFile.txt');
pdplogfile = importdata(path1);
% pdplogfile{11} has the true Tx power, Gain Tx (GTx), Gain Rx (GRx), freq,
% distance and Date
Ptx = str2double(pdplogfile{11}(23:27));
Gtx = str2double(pdplogfile{12}(18:19));
Grx = str2double(pdplogfile{17}(18:19));
f = str2double(pdplogfile{21}(17:19))*10^9; % in Hz
d = str2double(pdplogfile{6}(37:40));
Date = pdplogfile{1}(16:25);

%% Processing for all attenuations. 
P = cell(9,9);
for l=1:10
    sum_power = 0;
    % Storing all power values and finding max power and its index
    b = cali_db{1,l}(:,2);
    [max_pwr(l),max_pwr_idx(l)] = max(b);
    % Need to sum all powers in 4ns durtion. Peak power at 't sec'. Summation
    % of power happens from t-2 to t+2. Total 4ns duration - 80 samples under
    % peak. 40 on left , 40 on right
    llimit_sample = max_pwr_idx(l) - 39;
    ulimit_sample = max_pwr_idx(l) + 40;
 
    for k=llimit_sample:ulimit_sample
        sum_power = sum_power + 10.^(0.1.*cali_db{1,l}(k,2)); 
    end
    avg_pwr_dbm(l) = 10*log10(sum_power);
end

%% MMSE Best Fit Line
% Rows are attenuation 0 dB - 80dB. Cols are attenuation from 10 dB - 90
% dB. Linear range in taken atleast for 20dB step size or more.
distance = NaN(9);
for index = 1:length(attenuations)-1
    for j=index+2:length(avg_pwr_dbm)
        P{index,j-1} = polyfit(attenuations(index:j),avg_pwr_dbm(index:j),1);
        % P holds the value of slope and intercept. Traverse through P and find the
        % slope closest to -1.
        distance(index,j-1) = abs((P{index,j-1}(1,1)) + 1); 
        [min_val,idx]=min(distance(:));
        [row,col]=ind2sub(size(distance),idx);
    end
end

% Intecept and slope
intercept = round(P{row,col}(1,2),2);
slope = round(P{row,col}(1,1),2);

%% System Gain calculation - at 0 dB attenuation use the intercept of best fit line
% % System_Gain = Pr - PTx - GTx - GRx + PL + Manual attenuation 
n = 2; % PLE
FSPL = 20*log10(4*pi*f/c);
PL = FSPL + 10*n*log10(d);
sys_gain = round(intercept - Ptx - Gtx - Grx + PL ,2);

%% Plot of Rcvd Power and MMSE best fit Line
figure(1);
% clc;
plot(attenuations,avg_pwr_dbm,LineWidth=2,Color='blue');
xlim([0 60]);
grid on;
hold on
y = slope .* attenuations + intercept;
plot(attenuations,y,LineWidth=2,Color='red');
plot((row-1)*10,avg_pwr_dbm(row),'o','Color','red','MarkerSize',15,'MarkerFaceColor','red');
% avg_pwr_dbm is from 0 to 90. whereas col is from 10 - 90.
plot((col)*10,avg_pwr_dbm(col+1),'o','Color','red','MarkerSize',15,'MarkerFaceColor','red');
ylabel('Area Under PDP : Received Power(dBm)',FontSize=15)
xlabel('Attenuation (dB)',FontSize=20);
title(sprintf('System Gain: Date %s',Date),FontSize=15);
lgd_size = legend('Rcvd Pwr vs Atten','MMSE best fit line','linear Range Limits');
lgd_size.FontSize = 20;
text(min(xlim), min(ylim), sprintf('\n Slope %0.2f \n Intercept %0.2f \n Linear Range %d dB to %d dB \n System Gain %0.2f', ...
    slope,intercept,((row-1)*10),(col*10),sys_gain),'Horiz','left', 'Vert','bottom','FontSize',15);
toc
saveas(gcf,strcat(folder_name,'\Calibration Area\myfigure.png'));


