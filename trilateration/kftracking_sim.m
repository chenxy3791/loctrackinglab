%2019-12-21 chenxy
%   Demonstration program for kalman filter tacking simulation.
%   

%Reference: 

close all; clear; clc

%generating the true data:
Ts      = 0.3; %define the sample time
vRadial = 0.20;
vAngle  = 5*pi/180;
t       = [0:Ts:100];
angle0  = 0;
r0      = 0;

[xtrue, ytrue] = spiralline2d(vRadial,vAngle,t,angle0,r0);

%defining V: measurement noise variances
sig_meas = 0.5; % 20cm of measurement error
V   = [sig_meas.^2 0; 0 sig_meas.^2;];

%generating measurment data by adding noise to the true data:
xm  = xtrue  + normrnd(0,sig_meas,length(xtrue),1);
ym  = ytrue  + normrnd(0,sig_meas,length(ytrue),1);

figure; 
plot(xtrue,ytrue); grid; hold on;
scatter(xm, ym);      
legend('ground truth', 'measured');
title('trajectory');

%initializing the matricies for the for loop (this will make the matlab run
%the for loop faster.
Xest     = zeros(4,length(t));
Xest(:,1)= [xm(1); ym(1); 0; 0];

A=[1 0 Ts 0  ; ...
   0 1 0  Ts ; ...
   0 0 1  0  ; ...
   0 0 0  1  ]; %define the state matrix
C=[1 0 0  0  ; ...
   0 1 0  0  ]; %define the output matrix -- Only [x,y] are measured. 'H' in some paper
   
%defining R and Q
%R: measurement covariance matrix
%Q: system state transition covariance matrix
sigma_x = 0.1;
sigma_y = 0.1;

%R  = V*C*C';
% Qb = [sigma_x.^2 0 ; 0 sigma_y.^2]; 
% Q  = B*Qb*B';
%Initializing P 
%P  = Q; 

%% Kalman filtering for tracking based on instantaneous estimated position.
state  = [0,0,0,0]';
last_t = -1;
N      = length(t);

param = {};
for i=1:N
    [ px, py, state, param ] = kalmanFilter( t(i), xm(i), ym(i), state, param, last_t);
    if numel(state)~=4
        error('Your state should be four dimensions.');
    end
    last_t = t(i);
    Xest(1,i) = state(1);
    Xest(2,i) = state(2);    
    Xest(3,i) = state(3);
    Xest(4,i) = state(4);        
end
clear px py;

%%Visualization of result.
figure
subplot(211)
    plot(t,Xest(1,:),'r',t,xm,'g',t,xtrue,'b')
    xlabel('time [sec]');
    ylabel('displacementx [m]');
    title('displacementx');
    legend('estimated displacementx','measured displacementx','true displacementx');
subplot(212)
    plot(t,Xest(2,:),'r',t,ym,'g',t,ytrue,'b')
    xlabel('time [sec]');
    ylabel('displacementy [m]');
    title('displacementy');
    legend('estimated displacementy','measured displacementy','true displacementy');

figure; hold on;
plot(xtrue,ytrue,'b.-');
plot(Xest(1,:),Xest(2,:),'ro');
plot(xm,ym,'k+:');
legend('True trajectory', 'Estimated trajectory', 'Measured trajectory');

%% figure
%% hold on 
%% %simple animation:
%% for i=1:1:length(t)
%%     axis([min(xtrue)*1.1 max(xtrue)*1.1 min(ytrue)*1.1 max(ytrue)*1.1]);
%%     %viscircles([xtrue(i) ytrue(i)],20,'color','b')
%%     %viscircles([Xest(1,i) Xest(2,i)],20,'color','r')
%%     plot(xtrue(i),ytrue(i),'b.-');
%%     plot(Xest(1,i),Xest(2,i),'ro');
%%     plot(xm(i),ym(i),'k+:');
%%     pause(Ts);
%% end
%% legend('True trajectory', 'Estimated trajectory', 'Measured trajectory');
