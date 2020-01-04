% Trajectory generation experiment.
% 2019-12-20 Initial Creation. The result is not satisfactory.
close all; clear; 
echo on;

x_anchor = [0 10 10 0 0];
vx_anchor= [0 0  0  0 0];
nPoints  = 100;
t0       = linspace(0, 10, nPoints)';

x   = zeros(length(x_anchor),1);
xD  = zeros(length(x_anchor),1);
xDD = zeros(length(x_anchor),1);

for k = 1:1:length(x_anchor)-1
    x0  = x_anchor(k);
    x1  = x_anchor(k+1);
    vx0 = vx_anchor(k);
    vx1 = vx_anchor(k+1);    
    [x_tmp,xD_tmp,xDD_tmp] = tpoly(x0, x1, t0, vx0, vx1);
    x((k-1)*nPoints+1 : k*nPoints)   = x_tmp;
    xD((k-1)*nPoints+1 : k*nPoints)  = xD_tmp;
    xDD((k-1)*nPoints+1 : k*nPoints) = xDD_tmp;    
end    

figure; 
subplot(3,1,1); plot(x);   title('x axis, Postion');
subplot(3,1,2); plot(xD);  title('x axis, Velocity');
subplot(3,1,3); plot(xDD); title('x axis, Acceleration');

y_anchor = [0 0 10 10 0];
vy_anchor= [0 0  0  0 0];
nPoints  = 100;
t0       = linspace(0, 10, nPoints)';

y   = zeros(length(y_anchor),1);
yD  = zeros(length(y_anchor),1);
yDD = zeros(length(y_anchor),1);

for k = 1:1:length(y_anchor)-1
    y0  = y_anchor(k);
    y1  = y_anchor(k+1);
    vy0 = vy_anchor(k);
    vy1 = vy_anchor(k+1);    
    [y_tmp,yD_tmp,yDD_tmp] = tpoly(y0, y1, t0, vy0, vy1);
    y((k-1)*nPoints+1 : k*nPoints)   = y_tmp;
    yD((k-1)*nPoints+1 : k*nPoints)  = yD_tmp;
    yDD((k-1)*nPoints+1 : k*nPoints) = yDD_tmp;    
end    

figure; 
subplot(3,1,1); plot(y);   title('y axis, Postion');
subplot(3,1,2); plot(yD);  title('y axis, Velocity');
subplot(3,1,3); plot(yDD); title('y axis, Acceleration');

figure;
plot(x,y); title('x-y trajectory');

% Reference: https://www.mathworks.com/matlabcentral/answers/482810-cubic-smoothing-sline-for-trajectory-approximation?s_tid=answers_rc1-2_p2_MLT
% Lets assume we have 7 trajectories with 100 datapoints each. 
% For example datapoints can be generated using randn
trajectories = randn(100,7);
% Taking mean across the trajectories (that is 2nd dimension) will give a single trajectory
trajectory = mean(trajectories,2);
p = 0.1; % define the error measure weightage (Give path matching closely with datapoint for high value of p)
% p must be between 0 and 1.
x_data = linspace(1,100,100); % Just to have 2D sense of trajectories
path = csaps(x_data,trajectory,p);
fnplt(path); % show the path
% Here path is a structure which contains the polynomial coefficient between each successive pair of datapoint.