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

%%3. Position estimation.
esti_pos1 = [];
esti_pos2 = [];
esti_pos3 = [];
esti_pos4 = [];

for k = 1: 1: totalline
    
    if ismember(k, ng_idxs)
        continue;
    end
    
    P = [   [anchor0_x(k),anchor0_y(k), 0]'...
            [anchor1_x(k),anchor1_y(k), 0]'...
            [anchor2_x(k),anchor2_y(k), 0]'...
            [anchor3_x(k),anchor3_y(k), 0]'    ];
            
    S = [range0(k) range1(k) range2(k) range3(k) ];    
    
    %disp(P)
    %disp(S)
    
    W = diag(ones(1,length(S)));
    
    % Call Trilateration to use only three anchors(the first three are used)
    [N1 N2] = Trilateration_Norrdine(P,S,W);
    assert(isequal(N1,N2));
    esti_pos1 = [esti_pos1; [N1(2) N1(3)] ];
    
    % Call RecTrilateration to use all 4 anchors
    Nmat = RecTrilateration_Norrdine(P,S,W);    
    esti_pos2 = [esti_pos2; [Nmat(2) Nmat(3)] ];
        
    AncPos = P(1:2,:);
    tag_pos = ls_trilat2d(AncPos, S);
    %tag_pos = ls_trilat_2d(AncPos(:,2:4), S(2:4));
    esti_pos3 = [esti_pos3; tag_pos' ];
    
    %% [pos_x,pos_y] = trilat(P(:,1), P(:,2), P(:,3), S(1), S(2), S(3));
    %% esti_pos1(k,:) = [pos_x pos_y];    
    tag_pos = trilat2d_geometrical_method(P(:,1), P(:,2), P(:,3), S(1), S(2), S(3));
    esti_pos4 = [esti_pos4; tag_pos' ]; 
end
%assert(isequal(esti_pos1, esti_pos2))

figure; 
scatter(esti_pos1(:,1), esti_pos1(:,2),[],'b'); title('Position estimated with Norrdine method, using the first 3 anchors'); 
figure; 
scatter(esti_pos2(:,1), esti_pos2(:,2),[],'b'); title('Position estimated with Norrdine method, using all 4 anchors'); 
figure; 
scatter(esti_pos3(:,1), esti_pos3(:,2),[],'b'); title('Position estimated with ls\_trilat\_2d, using all 4 anchors'); 
figure; 
scatter(esti_pos4(:,1), esti_pos4(:,2),[],'b'); title('Position estimated with trilat2d\_geometrical, using the first 3 anchors'); 

figure; 
scatter(tag_x, tag_y, [],'r'); title('Position output from demo platform vs estimated here'); 
hold on;
scatter(esti_pos3(:,1), esti_pos3(:,2), [],'y');
legend('Position output from demo platform', 'Position estimated with ls\_trilat\_2d, using all 4 anchors');

figure; 
scatter(esti_pos1(:,1), esti_pos1(:,2), [],'y');
hold on;
scatter(esti_pos2(:,1), esti_pos2(:,2), [],'b');
legend('Norrdine method, using the first 3 anchors', 'Norrdine method, using all 4 anchors');

figure; 
scatter(esti_pos4(:,1), esti_pos4(:,2),[],'r'); title('Position estimated with trilat2d\_geometrical, using the first 3 anchors'); 
hold on;
scatter(esti_pos2(:,1), esti_pos2(:,2), [],'b');
legend('Geometrical method, using the first 3 anchors', 'Norrdine method, using all 4 anchors');

%% Why should the result of trilat2d_geometrical_method is the same as that of RecTrilateration(), instead of Trilateration()?
