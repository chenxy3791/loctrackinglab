% chenxy, 2019-11-30

close all; clear all; clc

global filename0 SYSCNT_PERIOD
SYSCNT_PERIOD = 2^40;
filename0 = 'trek_cnt_tx_rx_ppm_err_20191211_1802';
%filename0 = 'cnt_tx_rx_ppm_err_20191211_1858';
%filename0 = 'cnt_tx_rx_ttcko_ttcki_20191203_1011';

data_mat = [filename0 '.mat'];
    
if( 2 ~= exist(data_mat,'file'))
    run('dataread_preproc.m');
else
    load(data_mat);
end

pkt_cnt = dat2(:,1);
txstamp = dat2(:,2);
rxstamp = dat2(:,3);

figure; plot(diff(pkt_cnt)); title('difference of pkt count after unwrapping');

% Remove the extra error -- temporarily solution, as counter-measure to the new problem in this data.
% sync_period   = txstamp(2) - txstamp(1);
txstamp_intv     = diff(txstamp)/64;  % Convert to ns unit.
txstamp_intv     = txstamp_intv(txstamp_intv < 1e7); % Only for cnt_tx_rx_ttcko_ttcki_20191203_1011.txt abnormal handling
rxstamp_intv     = diff(rxstamp)/64;  % Convert to ns unit.
rxstamp_intv     = rxstamp_intv(rxstamp_intv < 1e7); % Only for cnt_tx_rx_ttcko_ttcki_20191203_1011.txt abnormal handling

figure; plot(txstamp_intv); title('tx timestamp interval'); ylabel('ns');
figure; plot(rxstamp_intv); title('rx timestamp interval'); ylabel('ns');

%% % Only for trek_cnt_tx_rx_ppm_err_20191211_1802
%% a = rxstamp_intv - mean(rxstamp_intv);
%% figure; plot(rxstamp_intv(abs(a)<10)); title('rx timestamp interval after removing abnormal'); ylabel('ns');

rxstamp_intv_ma  = movmean(rxstamp_intv,127);
rxstamp_intv_dev = rxstamp_intv - rxstamp_intv_ma; % Deviation from the moving average.
rxstamp_intv_remove_abnormal = rxstamp_intv(abs(rxstamp_intv_dev) < 6); % Remove the abnormal points with great deviation.
rxstamp_intv_normalized = rxstamp_intv_remove_abnormal - movmean(rxstamp_intv_remove_abnormal,127);

figure;
plot(rxstamp_intv_dev); title('rxstamp interval deviation from moving average: ns');
figure;
plot(rxstamp_intv_normalized); title('rxstamp interval after normalization and removing abnormal points: ns');

hist(rxstamp_intv_normalized,100); title('Histogram of rxstamp interval deviation'); xlabel('ns');

disp('std(rxstamp_intv_normalized) = ')
disp(std(rxstamp_intv_normalized))

%% In the original data, there is severe discontinuity in around 73000~74000.
%% the first half and the second half cannot be used together.
x = dat2(1:end,2)/64e9; % txstamp, in unit of second.
y = dat2(1:end,3)/64e9; % rxstamp, in unit of second.

%% x = dat2(75000:end,2)/64e9; % txstamp, in unit of second.
%% y = dat2(75000:end,3)/64e9; % rxstamp, in unit of second.
