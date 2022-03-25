clear variables;
close all;
tic
%% Setting the file paths
%Date of the measurement: format (mm.dd.yyyy)
Date="11.04.2021";
Freq_band="142 GHz";
sys.CenterFrequency=sscanf(Freq_band,"%d*");%This is part of system information

SamplesUnderPeak=80; % these represent number of samples that make up the 
% autocorrelation peak for the PN sequence used.
% Here PN rate= 500 Mcps i.e. Chip duration = 2 ns.
% Autocorrelation peak is two chips wide. Peak duration = 4 ns.
% Because of time dilation, the peak is expanded by a factor equal to the 
% "slide factor" (gamma). Here, gamma = 8000.
% Then, 4 ns is equivalent to 32 us.
% Now, Oscilloscope Sampling rate = 2.5 Msps. Samples under the peak = 80


%Generate the path to the calibration folder
%The base path common to all data
Base_path=['C:\Users\Dipankar Shakya\Documents\'... 
        'Desktop Work Station 2020\NYU_Wireless_Lab\Channel sounder\' ...
        'Factory\'];
%The extensions that lead to exact files 
Cal_path_ext='Calibration Area\Calibration 1\*\';
Log_path_ext='pdpLogFile.txt';
IQ_path_ext='IQsquared.txt';

%Get all the pdpLogFile.txt and IQsquared.txt files.
CalFiles=dir(strcat(Base_path,Date,'\',Freq_band,'\',Cal_path_ext,Log_path_ext));
IQ_Files=dir(strcat(Base_path,Date,'\',Freq_band,'\',Cal_path_ext,IQ_path_ext));

%% Extract some system information
rawText=fileread(strcat(CalFiles(1).folder,'\',CalFiles(1).name));
% T-R separation Distance
startIdx=regexp(rawText,'Calibration TR Separation Distance:')+length('Calibration TR Separation Distance:');
sys.CalibrationTRSeparationDistance=cell2mat(textscan(rawText(startIdx:end), '%f %*[^\n]'));

% TX Cal RF True Power
startIdx=regexp(rawText,'TX Cal RF True Power:')+length('TX Cal RF True Power:');
sys.TXCalTrueRFPower=cell2mat(textscan(rawText(startIdx:end), '%f %*[^\n]'));

% TX Antenna Gain
startIdx=regexp(rawText,'TX Antenna Gain:')+length('TX Antenna Gain:');
sys.TXAntennaGain=cell2mat(textscan(rawText(startIdx:end), '%d %*[^\n]'));

% RX Antenna Gain
startIdx=regexp(rawText,'RX Antenna Gain:')+length('RX Antenna Gain:');
sys.RXAntennaGain=cell2mat(textscan(rawText(startIdx:end), '%f %*[^\n]'));



%% Extracting the power under the peak
%Next to extract the peak power from the PDPs
peak_power_intg=zeros(length(IQ_Files),1);
for i=1:length(IQ_Files)
    IQ_values=readmatrix(strcat(IQ_Files(i).folder,'\',IQ_Files(i).name));
    time=IQ_values(:,1);
    power_dB=IQ_values(:,2);
    power_lin= 10.^(0.1.*power_dB);
    %[peaks, peak_loc]=findpeaks(power_dB);
    [main_peak, main_peak_index]=max(power_dB);
    %main_peak_index=peak_loc(main_peak_loc)-1;
    
    
    %The Cal peak index is helpful for verifying peak search. So we will
    %extract only the Cal. peak Index value from each log file
    rawText=fileread(strcat(CalFiles(i).folder,'\',CalFiles(i).name));
    startIdx=regexp(rawText,'Cal. Peak Index')+length('Cal. Peak Index');
    logd_peak_index=cell2mat(textscan(rawText(startIdx:end), '%d %*[^\n]'));
    
    % Checking to see if the peak obtained from the data matches the peak
    % index stored in the log file.
    if(~((logd_peak_index>main_peak_index-2) && (logd_peak_index<main_peak_index+2)))
        fprintf("Warning: peak for Attenuation%d is different. Please check",i);
    end
        
    for k=-(SamplesUnderPeak/2-1):(SamplesUnderPeak/2)
        peak_power_intg(i)=peak_power_intg(i)+power_lin(main_peak_index+k);
    end
end
peak_power_dbm=10.*log10(peak_power_intg);

%% Plot the results indicating the best linear range and best fit line
attn_db=(0:10:90)';
plot(attn_db,peak_power_dbm,'linewidth',4);
hold on;
slope=0;
C=0;
limits=zeros(2,1);
min_lin_range=2; %This has a multipler of 10. Eg. '2' is equivalent to a 
                 %minimum linear range of '20 dB'.
fit_error_tolerance=0.05;
for i=1:(length(attn_db)-min_lin_range)
    for j= (i+min_lin_range):length(attn_db)
        p=mmsefit(attn_db(i:j),peak_power_dbm(i:j)); %Using mmse to get 
                                    %the best linear fit slope and intercept
        if(abs(abs(p(1))-1)<fit_error_tolerance)
            %save only the range that gives the best fit.
            if(abs(abs(slope)-1)>abs(abs(p(1))-1))
                slope=p(1);
                limits(1,1)=i;
                limits(2,1)=j;
                C=p(2);
            end
        end
    end
end
%For system gain. We obtain Free Space Path Loss for 4m distance at 142 GHz
FSPL_cal=20*log10(4*pi*sys.CalibrationTRSeparationDistance*sys.CenterFrequency*10^9/3e8);
%We use the case when attenuation is 0 and the best fit line intercept
%gives the received power
System_Gain=FSPL_cal-sys.TXAntennaGain-sys.RXAntennaGain-sys.TXCalTrueRFPower+C;

y=slope.*attn_db+C;
plot(attn_db,y,'linewidth',4);
plot(attn_db(limits),peak_power_dbm(limits),'og','markersize',9,'linewidth',4);
ylim([-50, 20]);
xlim([0, 70]);
legend('Rec. Power (dBm) vs Atten. (dB)','MMSE Best Fit line','Linear Range Limits','FontSize',12);
str=sprintf("Slope: %.2f\nIntercept: %.2f dB\nSystem Gain: %d dB\n%d dB to %d dB",slope, C, System_Gain,attn_db(limits(1)),attn_db(limits(2)));
annotation('textbox',[.15 .15 .2 .2],'LineStyle','none','String',str,'FontWeight','bold','FontSize',12,'FitBoxToText','on')
%{
Slope: slope
Intercept: C dB
System Gain: System_Gain
attn_db(limits(1)) to attn_db(limits(2))
%}
set(gca,'fontweight','bold');
xlabel('Attenuation (dB)','fontweight','bold','FontSize',12);
ylabel('Area under the PDP- Rec. Power (dBm)','fontweight','bold','FontSize',12);
grid on;
hold off;
toc; 
