# ChannelSounder(CS)- Dynamic Range and Max operating distance Calculation
Dynamic Range of CS/ Max operating distance for CS
1. Dynamic_range_CS.m --- Code for calculating the dynamic range of CS @142GHz. Calculates Min_Rx_Power and the PL.
2. CS_max_operating_distance.m --- based on the p_exp (path loss exponent) depending on the fc (center frequency) and environment calculate the Rxd power over a distance 'd'. If Rxd power at 'd' is == Min_Rx_Power (obtained from dynamic range) then 'd' is the maximum distance between Tx and Rx. For a larger 'd' the Rxd pwr < Min_Rx_Power and the receiver will not be able to detect.
