% chenxy, 2019-11-18
% Demonstration program for 2D-TDOA with three anchors.

clear all;close all;

ANC_POS=[0,0;10,0;5,10*sqrt(3)];
TAG_POS(1) = rand*10;
TAG_POS(2) = rand*10;    
mu        = 0;    
sigma     = 0.05;

% Monte-Carlo simulation to check the dependency of positioning error on the measurement noise.
RMSE  = zeros(1000,10);
mu    = 0; % Measurement error mean, assuming that error is normal distribution
sigma = linspace(0.03, 0.2, 10);  % Measurement standard deviation

for n = 1:1000
    for m = 1:10
        R1_err = normrnd(mu, sigma(m));
        R2_err = normrnd(mu, sigma(m));
        R3_err = normrnd(mu, sigma(m));
        R(1)  = sqrt((ANC_POS(1,1) - TAG_POS(1))^2 + (ANC_POS(1,2) - TAG_POS(2))^2) - R1_err;
        R(2)  = sqrt((ANC_POS(2,1) - TAG_POS(1))^2 + (ANC_POS(2,2) - TAG_POS(2))^2) - R2_err;
        R(3)  = sqrt((ANC_POS(3,1) - TAG_POS(1))^2 + (ANC_POS(3,2) - TAG_POS(2))^2) - R3_err;    
        dist21 = R(2)-R(1);
        dist31 = R(3)-R(1);
        [esti_pos] = tdoa2d(ANC_POS, dist21, dist31);
        RMSE(n,m)  = sqrt( (TAG_POS(1)-esti_pos(1))^2 + (TAG_POS(2)-esti_pos(2))^2 );
    end
end

% S = mean(X) is the mean value of the elements in X if X is a vector. 
%     For matrices, S is a row vector containing the mean value of each 
%     column. 
RMSEaverage = mean(RMSE); % Average across the column.
figure; plot(sigma,RMSEaverage,'-rs'); grid on; title('RMSE vs noise std deviation');