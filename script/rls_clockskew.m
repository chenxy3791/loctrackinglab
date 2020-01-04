% Created by chenxy @ 2019-11-23
% About Least Square and Recursive Least Square, refer to 
%    Gilbert Strang: <<Introduction to Applied mathmatics>> chapter2.

clear all; close all; clc
format long

f1    = 1e6;              % TX frequency.
f2    = f1 * (1 + 100e-6);% RX frequency. Assuming 100ppm frequency difference.
alpha = (f2/f1);          % Frequency ratio.
beta  = randi(100) * (1/f1);       % Initial time offset.
sigma = 0.1 * (1/f1);     % Measurement noise standard deviation, assuming 1/10 of sync period.
N     = 100;              % Number of measurement samples
noise = sigma * randn(N,1);

time_tx = (1/f1) * [1:1:N]';
time_rx = time_tx * alpha + beta + noise;

%%1. Least Sqaure solution.
[P,S] = polyfit(time_tx,time_rx,1);
rxtime_pred = polyval(P,time_tx);
fprintf(1,'polyfit solution:\n');
fprintf(1, 'ref = [beta alpha] = %g %g\n', beta, alpha);
fprintf(1, 'x   = [beta alpha] = %g %g\n', P(2), P(1));

%%2. Least Sqaure solution.
fprintf(1,'Least Square solution:\n');
%Coefficient matrix
A = [ones(N,1) time_tx];    % (N,2)
b = time_rx;

%Least square solution
x = inv(A' * A) * A' * b;

fprintf(1, 'x   = [beta alpha] = %g %g\n', x(1), x(2));

figure;
plot(time_tx, time_rx); title('time\_rx ~ time\_tx');

figure;
plot(time_rx - time_tx); title('time\_rx - time\_tx');

%%3. Recursive Least Square solution.
fprintf(1,'\n\n\n');
fprintf(1,'Recursive Least Square solution\n');
%3.1 First take M samples for an initial Least Square solution.
M  = 3;
A0 = [ones(M,1) time_tx(1:M)];    % (N,2)
b0 = time_rx(1:M);

x0 = inv(A0' * A0) * A0' * b0;
fprintf(1, 'x0   = [beta alpha] = %g %g\n', x0(1), x0(2));

%3.2 Iterate over each of the left samples
sigma2 = sigma * sigma;
P0     = (1/sigma2) * (A0' * A0);
Pnew   = P0;
xnew   = x0;
x      = zeros(N-M,2);
for k = M+1 : N
    Pnew  = inv(inv(Pnew) + (1/sigma2)*[1 time_tx(k); time_tx(k) time_tx(k)*time_tx(k)]);
    Kgain = (1/sigma2) * Pnew * [1 time_tx(k)]';
    xnew  = xnew + Kgain * (time_rx(k) - [1 time_tx(k)]*xnew);
    x(k-M,:)  = xnew;
end

fprintf(1, 'x_last   = [beta alpha] = %g %g\n', x(end,1), x(end,2));

figure;
subplot(2,1,1); plot(x(:,1)); title('beta estimate of RLS'); hold on; grid on;
                line([1 N-M],[beta beta],'Color','red','LineStyle','--');
subplot(2,1,2); plot(x(:,2)); title('alpha estimate of RLS');hold on; grid on;
                line([1 N-M],[alpha alpha],'Color','red','LineStyle','--');