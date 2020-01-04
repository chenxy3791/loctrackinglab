% chenxy, 2020-01-02
close all; clear; clc

load('normal_CIR_dump_20200103_0945.mat');
%load('cir_dat_20200103_0945.mat');

%% CIR smoothing
%% disp('Question1: The max postions from CIR amplitude are not the same as the reported LDE_PPINDX, why?');
cir_mag    = abs(cir);
cir_mag_smooth = zeros(size(cir_mag));
for k=1:size(cir_mag,2)
    cir_mag_smooth(:,k) = smooth(cir_mag(:,k),3,'moving');
end    

cir_smooth = zeros(size(cir));

for k =1:size(cir_smooth,2)
    %cir_smooth(:,k) = smooth(cir(1:992,k), 'loess');
    %cir_smooth(:,k) = smooth(cir(1:992,k), 'sgolay');
    cir_smooth(:,k) = smooth(cir(1:992,k), 3, 'moving');
    %cir_smooth_mag(:,k) = hybrid1_mag(cir_smooth(:,k));
    cir_smooth_mag(:,k) = hybrid2_mag(cir_smooth(:,k));
end
%cir_smooth_mag = abs(cir_smooth);

% LDE_PPINDX is 0-indexed, Matlab is 1-indexed
% Here add 1 to LDE_PPINDX for comparison with the evaluated value here.
LDE_PPINDX = LDE_PPINDX + 1;

[cirMax, cirMaxPos] = max(cir_mag);
[cirMax2, cirMaxPos2] = max(cir_mag_smooth);
[cirMax3, cirMaxPos3] = max(cir_smooth_mag);

disp(['cirMaxPos = ', num2str(cirMaxPos)]);
disp(['cirMaxPos2 = ', num2str(cirMaxPos2)]);
disp(['cirMaxPos3 = ', num2str(cirMaxPos3)]);
disp(['LDE_PPINDX  = ', num2str(LDE_PPINDX )]);
disp(['FP_INDEX  = ', num2str(FP_INDEX )]);

disp(['cirMax    = ', num2str(cirMax)]);
disp(['cirMax2    = ', num2str(cirMax2)]);
disp(['cirMax3    = ', num2str(cirMax3)]);
disp(['LDE_PPAMPL   = ', num2str(LDE_PPAMPL )]);

err1 = (cirMaxPos -  LDE_PPINDX); 
err2 = (cirMaxPos2 - LDE_PPINDX);
err3 = (cirMaxPos3 - LDE_PPINDX);
disp(['rmse1 = ', num2str(sqrt(mean(err1.*err1)))]);
disp(['rmse2 = ', num2str(sqrt(mean(err2.*err2)))]);
disp(['rmse3 = ', num2str(sqrt(mean(err3.*err3)))]);

figure; hist(err1,20); title('err1: original CIR magnitude');
figure; hist(err2,20); title('err2: CIR smoothing, then magnitude');
figure; hist(err3,20); title('err3: CIR magnitude, then smoothing');

[maxTmp,k] = max(err3);
figure;  hold on; grid on;
plot(cir_mag(:,k));
plot(cir_mag_smooth(:,k));
plot(cir_smooth_mag(:,k));
legend('Original cir mag', 'mag --> smoothing', 'smoothing --> mag');
hold off;


