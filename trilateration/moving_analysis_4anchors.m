% chenxy, 2019-12-06

close all; clear all; clc

addpath('./TestData/');
addpath('./Norrdine/');
addpath('./func/');

filename = '4anchors_antiShake_noObstacle_moving.txt';
%filename = '4anchors_trilateration_noObstacle_moving.txt';
%filename = '6anchors_trilateration_noObstacle_static.txt';
%filename = '6anchors_antiShake_noObstacle_static.txt';
fprintf(1,'%s\n',['data filename : ', filename]);

fid = fopen(filename,'r');
datarray  = [];
totalline = 0;
validline = 0;

%%1. Read data from file
% timestamp, tag_id, 
% tag_x, tag_y,
% anchor0_id,anchor1_id,anchor2_id,anchor3_id,
% range0,range1,range2,range3,
% anchor0_x,anchor0_y,
% anchor1_x,anchor1_y,
% anchor2_x,anchor2_y,
% anchor3_x,anchor3_y

str = fgetl(fid); % Read one line as a string. Skip the first line.
while (~feof(fid))

    totalline = totalline + 1;
    str = fgetl(fid); % Read one line as a string.
    S   = regexp(str, ',', 'split');
        
    tmpdata = zeros(1,size(S,2));
    for k = 1:size(S,2)
        tmpdata(k) = str2num(char(S(k)));
    end
    
    if ~(tmpdata(5)==0 || tmpdata(6)==0 || tmpdata(7)==0 || tmpdata(8)==0)
        validline = validline + 1;
        datarray = [datarray; tmpdata];        
    else
        fprintf(1,'line#%d is invalid with anchor_IDs = %d : %d : %d : %d\n',...
            totalline, tmpdata(5), tmpdata(6), tmpdata(7), tmpdata(8) );
    end    
    
    if mod(totalline ,1000) == 0
        fprintf(1, 'totalline = %d\n', totalline);
    end    
end
fclose(fid);

fprintf(1, 'totalline = %d, validline = %d\n', totalline, validline);

timestamp  = datarray(:, 1);
tag_id     = datarray(:, 2);
tag_x      = datarray(:, 3);
tag_y      = datarray(:, 4);

anchor0_id = datarray(:, 5);
anchor1_id = datarray(:, 6);
anchor2_id = datarray(:, 7);
anchor3_id = datarray(:, 8);

range0     = datarray(:, 9);
range1     = datarray(:,10);
range2     = datarray(:,11);
range3     = datarray(:,12);
           
anchor0_x  = datarray(:,13);
anchor0_y  = datarray(:,14);
anchor1_x  = datarray(:,15);
anchor1_y  = datarray(:,16);
anchor2_x  = datarray(:,17);
anchor2_y  = datarray(:,18);
anchor3_x  = datarray(:,19);
anchor3_y  = datarray(:,20);

%%2. Data exploration

%2.1 In 4-anchors case, anchor information should be kept constant.
assert(length(unique(anchor0_id))==1);
assert(length(unique(anchor1_id))==1);
assert(length(unique(anchor2_id))==1);
assert(length(unique(anchor3_id))==1);

assert(length(unique(anchor0_x))==1 && length(unique(anchor0_y))==1);
assert(length(unique(anchor1_x))==1 && length(unique(anchor1_y))==1);
assert(length(unique(anchor2_x))==1 && length(unique(anchor2_y))==1);
assert(length(unique(anchor3_x))==1 && length(unique(anchor3_y))==1);

%2.2 range* statistics 
%NOTE: For 6anchors data, because the anchor_ids in the same colomn are not always the same,
%      hence the following statistics analysis is meaningless.
figure;
subplot(2,2,1); plot(range0); hold on; plot(smooth(range0)); grid on; title('range0'); legend('orignal data','after smoothing');
subplot(2,2,2); plot(range1); hold on; plot(smooth(range1)); grid on; title('range1'); legend('orignal data','after smoothing');
subplot(2,2,3); plot(range2); hold on; plot(smooth(range2)); grid on; title('range2'); legend('orignal data','after smoothing');
subplot(2,2,4); plot(range3); hold on; plot(smooth(range3)); grid on; title('range3'); legend('orignal data','after smoothing');
hold off;

range0 = smooth(range0);
range1 = smooth(range1);
range2 = smooth(range2);
range3 = smooth(range3);

figure; 
scatter(tag_x, tag_y, [], 'r*'); 
%figure; 
hold on;
plot(tag_x(1), tag_y(1), 'r'); hold on;
xlim([17,21]); ylim([4,13]); 
for k = 2:1:length(tag_x)
    pause(0.01);
    line([tag_x(k-1) tag_x(k)],[tag_y(k-1) tag_y(k)]);    
end    
title('Traceplot output from demo platform'); 

plot(anchor0_x(1),anchor0_y(1),'d','MarkerSize',8);
plot(anchor1_x(1),anchor1_y(1),'d','MarkerSize',8);
plot(anchor2_x(1),anchor2_y(1),'d','MarkerSize',8);
plot(anchor3_x(1),anchor3_y(1),'d','MarkerSize',8);


%% figure;
%% subplot(2,2,1); plot(range0(ok_idxs)); title('range0');
%% subplot(2,2,2); plot(range1(ok_idxs)); title('range1');
%% subplot(2,2,3); plot(range2(ok_idxs)); title('range2');
%% subplot(2,2,4); plot(range3(ok_idxs)); title('range3');
%% 
%% figure;
%% subplot(2,2,1); hist(range0(ok_idxs),20); title('range0');
%% subplot(2,2,2); hist(range1(ok_idxs),20); title('range1');
%% subplot(2,2,3); hist(range2(ok_idxs),20); title('range2');
%% subplot(2,2,4); hist(range3(ok_idxs),20); title('range3');
%% 
%% fprintf(1,'stddev of range0 = %g(cm)\n', std(range0(ok_idxs))*100);
%% fprintf(1,'stddev of range1 = %g(cm)\n', std(range1(ok_idxs))*100);
%% fprintf(1,'stddev of range2 = %g(cm)\n', std(range2(ok_idxs))*100);
%% fprintf(1,'stddev of range3 = %g(cm)\n', std(range3(ok_idxs))*100);

%%3. Instantaneous position estimation.
esti_pos1 = [];
esti_pos2 = [];
esti_pos3 = [];
esti_pos4 = [];

for k = 1: 1: validline
        
    P = [   [anchor0_x(k),anchor0_y(k), 0]'...
            [anchor1_x(k),anchor1_y(k), 0]'...
            [anchor2_x(k),anchor2_y(k), 0]'...
            [anchor3_x(k),anchor3_y(k), 0]'    ];
            
    S = [range0(k) range1(k) range2(k) range3(k) ];    
        
    W = diag(ones(1,length(S)));
    
    % Call Trilateration to use only three anchors(the first three are used)
    [N1 N2]   = Trilateration_Norrdine(P,S,W);
    assert(isequal(N1,N2));
    esti_pos1 = [esti_pos1; [N1(2) N1(3)] ];
    
    % Call RecTrilateration to use all 4 anchors
    Nmat      = RecTrilateration_Norrdine(P,S,W);
    esti_pos2 = [esti_pos2; [Nmat(2) Nmat(3)] ];
        
    AncPos    = P(1:2,:);
    tag_pos   = ls_trilat2d(AncPos, S);    
    esti_pos3 = [esti_pos3; tag_pos' ];
    
    %% [pos_x,pos_y] = trilat(P(:,1), P(:,2), P(:,3), S(1), S(2), S(3));
    %% esti_pos1(k,:) = [pos_x pos_y];    
    tag_pos = trilat2d_geometrical_method(P(:,1), P(:,2), P(:,3), S(1), S(2), S(3));
    esti_pos4 = [esti_pos4; tag_pos' ]; 
end
%assert(isequal(esti_pos1, esti_pos2))

figure; 
subplot(2,2,1);
scatter(esti_pos1(:,1), esti_pos1(:,2),[],'b'); title('Position estimated with Norrdine method, using the first 3 anchors'); 
subplot(2,2,2);
scatter(esti_pos2(:,1), esti_pos2(:,2),[],'b'); title('Position estimated with Norrdine method, using all 4 anchors'); 
subplot(2,2,3);
scatter(esti_pos3(:,1), esti_pos3(:,2),[],'b'); title('Position estimated with ls\_trilat\_2d, using all 4 anchors'); 
subplot(2,2,4);
scatter(esti_pos4(:,1), esti_pos4(:,2),[],'b'); title('Position estimated with trilat2d\_geometrical, using the first 3 anchors'); 

%% Kalman filtering for tracking based on instantaneous estimated position.
state  = [0,0,0,0]';
last_t = -1;
N      = size(esti_pos3,1);
estX   = esti_pos3(:,1);
estY   = esti_pos3(:,2);
t      = (timestamp-timestamp(1))*(1e-3); % The unit of timestamp is ms
%myPredictions = zeros(2, N);
kfEstPos = zeros(N, 2);
param = {};
for i=1:N
    [ px, py, state, param ] = kalmanFilter( t(i), estX(i), estY(i), state, param, last_t);
    if numel(state)~=4
        error('Your state should be four dimensions.');
    end
    last_t = t(i);
    %myPredictions(1, i) = px;
    %myPredictions(2, i) = py;
    kfEstPos(i,1) = state(1);
    kfEstPos(i,2) = state(2);    
end
clear px py;
figure; 
plot(tag_x, tag_y, 'ro-'); title('Traceplot from demo platform vs estimated here'); 
hold on;
plot(kfEstPos(:,1), kfEstPos(:,2), 'k*-');
% End at red
plot(tag_x(end), tag_y(end), 's', ...
    'MarkerSize', 10, 'MarkerEdgeColor', [.5 0 0], 'MarkerFaceColor', 'r');
% start at green
plot(tag_x(1, 1), tag_y(2, 1), 's', ...
    'MarkerSize', 10, 'MarkerEdgeColor', [0 .5 0], 'MarkerFaceColor', 'g');
legend('Traceplot from demo platform', 'Traceplot after kalman filtering','END','STOP');    
hold off;

figure; 
plot(esti_pos3(:,1), esti_pos3(:,2), 'ro-'); title('Traceplot before and after kalman filtering'); 
hold on;
plot(kfEstPos(:,1), kfEstPos(:,2), 'k*-');
% End at red
plot(tag_x(end), tag_y(end), 's', ...
    'MarkerSize', 10, 'MarkerEdgeColor', [.5 0 0], 'MarkerFaceColor', 'r');
% start at green
plot(tag_x(1, 1), tag_y(2, 1), 's', ...
    'MarkerSize', 10, 'MarkerEdgeColor', [0 .5 0], 'MarkerFaceColor', 'g');
legend('Traceplot before kalman filtering', 'Traceplot after kalman filtering','END','STOP');    
hold off;    

%% figure; 
%% scatter(esti_pos1(:,1), esti_pos1(:,2), [],'y');
%% hold on;
%% scatter(esti_pos2(:,1), esti_pos2(:,2), [],'b');
%% legend('Norrdine method, using the first 3 anchors', 'Norrdine method, using all 4 anchors');

% figure; 
% scatter(esti_pos4(:,1), esti_pos4(:,2),[],'r'); title('Position estimated with trilat2d\_geometrical, using the first 3 anchors'); 
% hold on;
% scatter(esti_pos2(:,1), esti_pos2(:,2), [],'b');
% legend('Geometrical method, using the first 3 anchors', 'Norrdine method, using all 4 anchors');

%% Why should the result of trilat2d_geometrical_method is the same as that of RecTrilateration(), instead of Trilateration()?

%% Draw illustration figure for trilateration.
% randomly pick one test samples -- one row of datarray
%% while(1) 
%%     k = randi(totalline,[1,1]);
%%     if ~ismember(k, ng_idxs)
%%         break;
%%     end
%% end
%% 
%% % Draw a circle.    
%% theta = 0:pi/50:2*pi;
%% x0    = anchor0_x(k);
%% y0    = anchor0_y(k);
%% cir0_x     = range0(k) * cos(theta) + x0;
%% cir0_y     = range0(k) * sin(theta) + y0;
%% 
%% x1    = anchor1_x(k);
%% y1    = anchor1_y(k);
%% cir1_x     = range1(k) * cos(theta) + x1;
%% cir1_y     = range1(k) * sin(theta) + y1;
%% 
%% x2    = anchor2_x(k);
%% y2    = anchor2_y(k);
%% cir2_x     = range2(k) * cos(theta) + x2;
%% cir2_y     = range2(k) * sin(theta) + y2;
%% 
%% x3    = anchor3_x(k);
%% y3    = anchor3_y(k);
%% cir3_x     = range3(k) * cos(theta) + x3;
%% cir3_y     = range3(k) * sin(theta) + y3;
%% 
%% figure; 
%% plot(cir0_x, cir0_y); hold on;
%% plot(cir1_x, cir1_y); 
%% plot(cir2_x, cir2_y); 
%% plot(cir3_x, cir3_y); 
%% plot(x0,y0,'d','MarkerSize',5);
%% plot(x1,y1,'d','MarkerSize',5);
%% plot(x2,y2,'d','MarkerSize',5);
%% plot(x3,y3,'d','MarkerSize',5);
%% plot(tag_x(k),tag_y(k),'o','MarkerSize',5);
%% 
%% line([x0 tag_x(k)],[y0 tag_y(k)]);
%% line([x1 tag_x(k)],[y1 tag_y(k)]);
%% line([x2 tag_x(k)],[y2 tag_y(k)]);
%% line([x3 tag_x(k)],[y3 tag_y(k)]);
%% 
%% x_min = min([cir0_x cir1_x cir2_x cir3_x]);
%% x_max = max([cir0_x cir1_x cir2_x cir3_x]);
%% y_min = min([cir0_y cir1_y cir2_y cir3_y]);
%% y_max = max([cir0_y cir1_y cir2_y cir3_y]);
%% width = max((x_max-x_min),(y_max-y_min));
%% xlim([(x_max+x_min)/2-width/2, (x_max+x_min)/2+width/2]);
%% ylim([(y_max+y_min)/2-width/2, (y_max+y_min)/2+width/2]);