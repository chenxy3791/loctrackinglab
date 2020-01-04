% chenxy, 2019-12-06

close all; clear all; clc

addpath('./TestData/');
addpath('./Norrdine/');
addpath('./func/');

%filename = '4anchors_antiShake_noObstacle_static.txt';
filename = '4anchors_trilateration_noObstacle_static.txt';
%filename = '6anchors_trilateration_noObstacle_static.txt';
%filename = '6anchors_antiShake_noObstacle_static.txt';
disp(filename);

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
    
    datarray = [datarray; tmpdata];        
    
    if mod(totalline ,1000) == 0
        fprintf(1, 'totalline = %d\n', totalline);    
    end    
end
fclose(fid);
fprintf(1, 'totalline = %d\n', totalline);    

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

%2.1 In some rows, anchor*_id is zero, which means the corresponding anchor is not used.
%    But for the convenience of analysis, such rows are removed here.
ng_idxs_0 = find(anchor0_id == 0); % find(anchor0_id ~= 32768); 
ng_idxs_1 = find(anchor1_id == 0); % find(anchor1_id ~= 32770); 
ng_idxs_2 = find(anchor2_id == 0); % find(anchor2_id ~= 32773); 
ng_idxs_3 = find(anchor3_id == 0); % find(anchor3_id ~= 32772); 
ng_idxs   = union( union( union(ng_idxs_0,ng_idxs_1), ng_idxs_2),ng_idxs_3 ) ;
ok_idxs   = setdiff([1:1:length(range0)], ng_idxs);

fprintf(1, 'NG lines = %d\n', length(ng_idxs));

%2.2 range* statistics 
%NOTE: For 6anchors data, because the anchor_ids in the same colomn are not always the same,
%      hence the following statistics analysis is meaningless.
figure; scatter(tag_x, tag_y, [], 'r'); title('Position output from demo platform');
figure;
subplot(2,2,1); plot(range0(ok_idxs)); title('range0');
subplot(2,2,2); plot(range1(ok_idxs)); title('range1');
subplot(2,2,3); plot(range2(ok_idxs)); title('range2');
subplot(2,2,4); plot(range3(ok_idxs)); title('range3');

figure;
subplot(2,2,1); hist(range0(ok_idxs),20); title('range0');
subplot(2,2,2); hist(range1(ok_idxs),20); title('range1');
subplot(2,2,3); hist(range2(ok_idxs),20); title('range2');
subplot(2,2,4); hist(range3(ok_idxs),20); title('range3');

fprintf(1,'stddev of range0 = %g(cm)\n', std(range0(ok_idxs))*100);
fprintf(1,'stddev of range1 = %g(cm)\n', std(range1(ok_idxs))*100);
fprintf(1,'stddev of range2 = %g(cm)\n', std(range2(ok_idxs))*100);
fprintf(1,'stddev of range3 = %g(cm)\n', std(range3(ok_idxs))*100);

%% %%3. Position estimation.
%% esti_pos1 = [];
%% esti_pos2 = [];
%% esti_pos3 = [];
%% esti_pos4 = [];
%% 
%% for k = 1: 1: totalline
%%     
%%     if ismember(k, ng_idxs)
%%         continue;
%%     end
%%     
%%     P = [   [anchor0_x(k),anchor0_y(k), 0]'...
%%             [anchor1_x(k),anchor1_y(k), 0]'...
%%             [anchor2_x(k),anchor2_y(k), 0]'...
%%             [anchor3_x(k),anchor3_y(k), 0]'    ];
%%             
%%     S = [range0(k) range1(k) range2(k) range3(k) ];    
%%     
%%     %disp(P)
%%     %disp(S)
%%     
%%     W = diag(ones(1,length(S)));
%%     
%%     % Call Trilateration to use only three anchors(the first three are used)
%%     [N1 N2] = Trilateration_Norrdine(P,S,W);
%%     assert(isequal(N1,N2));
%%     esti_pos1 = [esti_pos1; [N1(2) N1(3)] ];
%%     
%%     % Call RecTrilateration to use all 4 anchors
%%     Nmat = RecTrilateration_Norrdine(P,S,W);    
%%     esti_pos2 = [esti_pos2; [Nmat(2) Nmat(3)] ];
%%         
%%     AncPos = P(1:2,:);
%%     tag_pos = ls_trilat2d(AncPos, S);
%%     %tag_pos = ls_trilat_2d(AncPos(:,2:4), S(2:4));
%%     esti_pos3 = [esti_pos3; tag_pos' ];
%%     
%%     %% [pos_x,pos_y] = trilat(P(:,1), P(:,2), P(:,3), S(1), S(2), S(3));
%%     %% esti_pos1(k,:) = [pos_x pos_y];    
%%     tag_pos = trilat2d_geometrical_method(P(:,1), P(:,2), P(:,3), S(1), S(2), S(3));
%%     esti_pos4 = [esti_pos4; tag_pos' ]; 
%% end
%% %assert(isequal(esti_pos1, esti_pos2))
%% 
%% figure; 
%% scatter(esti_pos1(:,1), esti_pos1(:,2),[],'b'); title('Position estimated with Norrdine method, using the first 3 anchors'); 
%% figure; 
%% scatter(esti_pos2(:,1), esti_pos2(:,2),[],'b'); title('Position estimated with Norrdine method, using all 4 anchors'); 
%% figure; 
%% scatter(esti_pos3(:,1), esti_pos3(:,2),[],'b'); title('Position estimated with ls\_trilat\_2d, using all 4 anchors'); 
%% figure; 
%% scatter(esti_pos4(:,1), esti_pos4(:,2),[],'b'); title('Position estimated with trilat2d\_geometrical, using the first 3 anchors'); 
%% 
%% figure; 
%% scatter(tag_x, tag_y, [],'r'); title('Position output from demo platform vs estimated here'); 
%% hold on;
%% scatter(esti_pos3(:,1), esti_pos3(:,2), [],'y');
%% legend('Position output from demo platform', 'Position estimated with ls\_trilat\_2d, using all 4 anchors');
%% 
%% figure; 
%% scatter(esti_pos1(:,1), esti_pos1(:,2), [],'y');
%% hold on;
%% scatter(esti_pos2(:,1), esti_pos2(:,2), [],'b');
%% legend('Norrdine method, using the first 3 anchors', 'Norrdine method, using all 4 anchors');
%% 
%% figure; 
%% scatter(esti_pos4(:,1), esti_pos4(:,2),[],'r'); title('Position estimated with trilat2d\_geometrical, using the first 3 anchors'); 
%% hold on;
%% scatter(esti_pos2(:,1), esti_pos2(:,2), [],'b');
%% legend('Geometrical method, using the first 3 anchors', 'Norrdine method, using all 4 anchors');
%% 
%% %% Why should the result of trilat2d_geometrical_method is the same as that of RecTrilateration(), instead of Trilateration()?

%% Draw illustration figure for trilateration.
% randomly pick one test samples -- one row of datarray
while(1) 
    k = randi(totalline,[1,1]);
    if ~ismember(k, ng_idxs)
        break;
    end
end

% Draw a circle.    
theta = 0:pi/50:2*pi;
x0    = anchor0_x(k);
y0    = anchor0_y(k);
cir0_x     = range0(k) * cos(theta) + x0;
cir0_y     = range0(k) * sin(theta) + y0;

x1    = anchor1_x(k);
y1    = anchor1_y(k);
cir1_x     = range1(k) * cos(theta) + x1;
cir1_y     = range1(k) * sin(theta) + y1;

x2    = anchor2_x(k);
y2    = anchor2_y(k);
cir2_x     = range2(k) * cos(theta) + x2;
cir2_y     = range2(k) * sin(theta) + y2;

x3    = anchor3_x(k);
y3    = anchor3_y(k);
cir3_x     = range3(k) * cos(theta) + x3;
cir3_y     = range3(k) * sin(theta) + y3;

figure; 
plot(cir0_x, cir0_y); hold on;
plot(cir1_x, cir1_y); 
plot(cir2_x, cir2_y); 
plot(cir3_x, cir3_y); 
plot(x0,y0,'d','MarkerSize',5);
plot(x1,y1,'d','MarkerSize',5);
plot(x2,y2,'d','MarkerSize',5);
plot(x3,y3,'d','MarkerSize',5);
plot(tag_x(k),tag_y(k),'o','MarkerSize',5);

line([x0 tag_x(k)],[y0 tag_y(k)]);
line([x1 tag_x(k)],[y1 tag_y(k)]);
line([x2 tag_x(k)],[y2 tag_y(k)]);
line([x3 tag_x(k)],[y3 tag_y(k)]);

x_min = min([cir0_x cir1_x cir2_x cir3_x]);
x_max = max([cir0_x cir1_x cir2_x cir3_x]);
y_min = min([cir0_y cir1_y cir2_y cir3_y]);
y_max = max([cir0_y cir1_y cir2_y cir3_y]);
width = max((x_max-x_min),(y_max-y_min));
xlim([(x_max+x_min)/2-width/2, (x_max+x_min)/2+width/2]);
ylim([(y_max+y_min)/2-width/2, (y_max+y_min)/2+width/2]);