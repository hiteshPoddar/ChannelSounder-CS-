******************** Dynamic Range of CS/ Max operating distance for CS ********************************************************************************
1. Dynamic_range_CS.m --- Code for calculating the dynamic range of CS @142GHz. Calculates Min_Rx_Power and the PL.
2. CS_max_operating_distance.m --- based on the p_exp (path loss exponent) depending on the fc (center frequency) and environment calculate the Rxd power over a distance 'd'. If Rxd power at 'd' is == Min_Rx_Power (obtained from dynamic range) then 'd' is the maximum distance between Tx and Rx. For a larger 'd' the Rxd pwr < Min_Rx_Power and the receiver will not be able to detect.

******************** System Gain Calculation from Calibration Data during Measurement Campaign*********************************************************
Method 1 :
********************************************************************************************************************************************************
system_gain_cal_from_cal_data_HP.m -- Code to calculate system gain from calibration data obtained during each day of measurement during the campaign.

File Path for calibration data : .....\142 GHz\Calibration Area\Calibration 1\.....

  ------- Extracted Files for this code ----------------------------------------------------------------------
  1. IQSqaured - 80 samples under peak power added. From peak 40 samples on right and 40 samples on left
  2. pdpLogFile - Contains system information: Gain of Tx,Rx, Freq, Distance, Date, etc.
 
  ------- Implementation Details summary --------------------------------------------------------------------
  1. IQ sqaured values are extracted from IQSqaure.txt file from each calibration folder i.e from Attenuation 0 dB,10dB,..90dB and stored in a Matlab Cell
  2. pdpLogFile values are stored in matlab cell. Necessary values like Date, Freq, Distance, Gain of Tx and Rx and True Tx power (which measured from power meter) is        extracted.
  3. For each attenuation the area under the PDP is taken i.e 80 samples under peak. Max peak power is found and from the we get the sample number for the max peak            power. From that we sum max_peak_sample_num - 39 to max_peak_sample_num + 40 in linear scale.
  4. MMSE best line is found using atleast 20 dB range. 0-20,0-30,0-40,10-30,10-40,20-40,etc... all possible combinations are covered. Slope cloeset to -1 is selected.
  5. System Gain calculation - found at 0dB attenuation use the intercept of best fit line, using the formula System_Gain = Pr - PTx - GTx - GRx + PL + Attnuation (0dB)
  
