% chenxy, 2019-11-18
% A simple test program for 2D-TDOA with three anchors.

clear all;close all;

testcase = 4;

% Test-case1
if(testcase == 1)
    ANC_POS=[0,0;10,0;5,10*sqrt(3)];
    TAG_POS(1) = rand*10;
    TAG_POS(2) = rand*10;
end

% Test-case2
if(testcase == 2)
    ANC_POS=[0,0;10,0;0,10];
    TAG_POS(1) = rand*10;
    TAG_POS(2) = rand*10;
end

% Test-case3
if(testcase == 3)
    ANC_POS=[0,0;10,0;0,-10];
    TAG_POS(1) = rand*10;
    TAG_POS(2) = rand*(-10);
end

% Test-case4 -- Test data provided by YanChao@2019/11/20.
% NOTE: The reference anchor has to be placed at [0,0].
if(testcase == 4)
    ANC1 = [15.611, 9.453]; % B0
    ANC2 = [15.62,   6.65]; % B1 
    ANC3 = [18.879,  6.65]; % B2
    ANC4 = [18.888,  9.49]; % B3
    
    ANC_POS = [ANC1-ANC1; ANC2-ANC1; ANC3-ANC1; ANC4-ANC1];
    TAG_POS = [16.284, 8.453] - ANC1;
end
    
mu        = 0;    % Measurement error mean, assuming that error is normal distribution
sigma     = 0.05; % Measurement standard deviation

R1_err = normrnd(mu, sigma);
R2_err = normrnd(mu, sigma);
R3_err = normrnd(mu, sigma);
R(1)   = sqrt((ANC_POS(1,1) - TAG_POS(1))^2 + (ANC_POS(1,2) - TAG_POS(2))^2) - R1_err;
R(2)   = sqrt((ANC_POS(2,1) - TAG_POS(1))^2 + (ANC_POS(2,2) - TAG_POS(2))^2) - R2_err;
R(3)   = sqrt((ANC_POS(3,1) - TAG_POS(1))^2 + (ANC_POS(3,2) - TAG_POS(2))^2) - R3_err;
 
dist21 = R(2)-R(1);
dist31 = R(3)-R(1);

[OUT]  = tdoa2d(ANC_POS, dist21, dist31);
 
figure; 
scatter(ANC_POS(:,1),ANC_POS(:,2), 100,'rs','filled');
  
xlabel('X [m]');
ylabel('Y [m]');
box on;   hold all;
scatter(TAG_POS(1), TAG_POS(2),50, 'bo','filled'); hold all;
scatter(OUT(1),    OUT(2),   50, 'kp','filled'); hold all;
legend('Anchor','Tag - actual position','Tag - estimated position');
title('Illustration of 2D TDOA'); grid on;

x_err = TAG_POS(1) - OUT(1);
y_err = TAG_POS(2) - OUT(2);
d_err = sqrt(x_err^2 + y_err^2);
fprintf(1,'R1_err = %g(m), R2_err = %g(m), R3_err = %g(m)\n', R1_err, R2_err, R3_err);
fprintf(1,'x_err = %g(m), y_err = %g(m), d_err = %g(m)\n', x_err, y_err, d_err);
