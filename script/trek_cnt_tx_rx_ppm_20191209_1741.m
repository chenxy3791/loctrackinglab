% chenxy, 2019-11-30

close all; clear all; clc
format long;

%global SYSCNT_PERIOD

SYSCNT_PERIOD = 2^40;
run('trek_cnt_tx_rx_ppm_20191209_1741_dataread.m');

sync_period = x(2) - x(1);

%%1. Original data statistics
rxperiod_err = diff(y) - sync_period;
movmean_size = 127;
rxperiod_err_movmean = movmean(rxperiod_err, movmean_size);
rxperiod_err_norm    = rxperiod_err - rxperiod_err_movmean;

figure; plot(rxperiod_err/sync_period*1e6); title('rx interval deviation'); ylabel('ppm');

figure; hist(rxperiod_err_norm,200); title('rx interval deviation histogram');
disp('std of rx interval deviation is: ')
disp(std(rxperiod_err_norm))


%% Recursive weighted least square estimation.
%  System Model: txintv(k) = beta(k) * rxintv(k);
mu = 0.01;
lambda = 0.01; % 0.01, 0.005, 0.001 don't make significant difference for std(err_ns).
txintv = diff(x)/sync_period; % Tx interval between consecutive sync packets, after normalization. Constant 1.
rxintv = diff(y)/sync_period; % Rx interval between consecutive sync packets, after normalization.

u_sig2 = std(rxintv); % 
w0     = 1; % Assuming 0-ppm.
[beta, err, kgain] = recursivels(rxintv,txintv,lambda, w0, u_sig2, mu);

beta_ppm = (beta(100:end)-1)*1e6;
err_ns   = err(100:end)*sync_period*1e9;
figure; 
    plot(beta_ppm); 
    title('RLS Estimation: Clock frequency between TX-RX, ppm'); grid; ylabel('ppm');
figure; 
    plot(err_ns);   
    title('RLS Estimation: Residual error'); grid; ylabel('ns');
figure; 
    plot(kgain(100:end));   
    title('gain k'); grid;

disp('RLS: std of beta_ppm = ')
disp(std(beta_ppm))
disp('RLS: std of err_ns = ')
disp(std(err_ns))

%% Least mean square estimation.
%  System Model: txintv(k) = beta(k) * rxintv(k);
mu = 0.01;
w0 = 1;
[beta_lms, err_lms] = lms(rxintv,txintv,mu, w0);
beta_lms_ppm = (beta_lms(100:end)-1)*1e6;
err_lms_ns   = err_lms(100:end)*sync_period*1e9;
figure; 
    plot(beta_lms_ppm); 
    title('LMS Estimation: Clock frequency between TX-RX, ppm'); grid; ylabel('ppm');
figure; 
    plot(err_lms_ns);   
    title('LMS Estimation: Residual error'); grid; ylabel('ns');

disp('LMS: std of beta_ppm = ')
disp(std(beta_lms_ppm))
disp('LMS: std of err_ns = ')
disp(std(err_lms_ns))

%% Naive estimation based on moving averging.
%  System Model: txintv(k) = beta(k) * rxintv(k);
ma_len = 127;
rxintv_movmean = movmean(rxintv, ma_len);

beta_ma = rxintv_movmean;
%beta_ma_ppm = (beta_ma(100:end)-1)*1e6;
beta_ma_ppm = (beta_ma-1)*1e6;
err_ma      = beta_ma - rxintv;

%err_ma_ns   = err_ma(100:end)*sync_period*1e9;
err_ma_ns   = err_ma*sync_period*1e9;
figure; 
    plot(beta_ma_ppm); 
    title('MA Estimation: Clock frequency between TX-RX, ppm'); grid; ylabel('ppm');
figure; 
    plot(err_ma_ns);   
    title('MA Estimation: Residual error'); grid; ylabel('ns');

disp('MA: std of beta_ppm = ')
disp(std(beta_ma_ppm))
disp('MA: std of err_ns = ')
disp(std(err_ma_ns))

%% %%3. LMS1: rx_intv_norm = (beta * sync_period)/sync_period = beta;
%% sync_period  = x(2)-x(1);
%% rx_intv_norm = diff(y)/sync_period;
%% 
%% mu    = 0.5;
%% beta  = zeros(length(rx_intv_norm),1);
%% init_blksize = 20;
%% beta(1:init_blksize) = mean(rx_intv_norm(1:init_blksize));
%% 
%% for k = init_blksize : 1 : length(y)-1
%%     d          = rx_intv_norm(k);
%%     x_norm     = 1;
%%     err(k)     = d - beta(k);
%%     beta(k+1)  = beta(k)  + 2*mu*err(k)*x_norm;    
%%     
%%     if k == 10000
%%         mu = 0.1;
%%     elseif k == 20000
%%         mu = 0.01;
%%     else
%%         mu = 0.001;
%%     end    
%% end
%% 
%% figure;
%% plot((beta-1)*1e6); title('Beta estimation'); ylabel('ppm');
%% title(['mu = ', num2str(mu)]);
%% grid on;
%% 
%% %3.1 rx timestamp prediction
%% %    How to handle error accumulation problem in this LMS scheme?
%% y_pred    = zeros(size(y));
%% y_pred(1) = y(1);
%% for k = 2: length(y)
%%     y_pred(k) = y_pred(k-1) + beta(k) * sync_period;
%% end
%% y_pred_err = y_pred - y;
%% 
%% figure;
%% plot(y_pred_err*1e9); title('residual error'); ylabel('ns');
%% title(['mu = ', num2str(mu)]);
%% grid on;
%% 
%% 
%% %% figure;
%% %% plot(err*sync_period*1e9); title('residual error. Normalized data'); ylabel('ns');
%% %% ylim([-20,20]); grid on;
%% 
%% %%3. Least Mean Square after data normalization.
%% mu      = 0.000000001;
%% [beta3, err3] = lms3(x,y,mu);
%% figure;
%% plot(err3*sync_period*1e9); title('residual error. Normalized data'); ylabel('ns');
%% ylim([-20,20]); grid on;
%% 
%% figure;
%% plot((beta3-1)*1e6); title('Estimated ppm');
%% ylabel('ppm');
%% 
%% %%2. Least Mean Square.
%% %  Assuming y(k) = alpha0 + beta * x(k)
%% %  'beta' represents clock skew between rx clock and tx clock, parameter to be estimated.
%% %  'alpha0' represents the intercept term or offset, constant.
%% %  Too time consuming for convergence.
%% alpha0  = y(1) - x(1);
%% beta    = zeros(length(y),1);
%% % beta(1) = 1 - 2e-6; % Initilize beta based on prior information, for example, DW1000 output ttcko/ttcki.
%% beta(1) = (rxstamp(100)-rxstamp(1))/(txstamp(100)-txstamp(1));
%% 
%% mu     = 0.00005; % 0.005 will cause diverge.
%% 
%% for k = 1:1:length(y)-1
%%     err(k)     = y(k) - (alpha0 + x(k)*beta(k));    
%%     beta(k+1)  = beta(k)  + 2*mu*err(k)*x(k);
%% end
%% 
%% figure;
%% plot(err*1e9); title('residual error. Estimate both alpha and beta'); ylabel('ns');
%% ylim([-10,10]);
%% figure;
%% plot((beta-1)*1e6); title('Estimated clock frequency error'); ylabel('ppm');
