% chenxy, 2019-12-14
% Comparison test of several trilateral algorithm implementation.

close all; clear; clc

addpath('./Norrdine/');
addpath('./func/');

nsim     = 20000;
anchor   = [ [0 0 0]; [0 500 0]; [500 500 0]; [500 0 0] ]; % [x y z]
         
tag_pos  = [rand(nsim,1) rand(nsim,1) zeros(nsim,1)] * 500;
dist_err = zeros(nsim,4);
esti_pos1= zeros(nsim,3);
esti_pos2= zeros(nsim,3);
esti_pos3= zeros(nsim,3);
esti_pos4= zeros(nsim,3);

for k = 1:1:nsim
    %%1. Initialization. Assuming the unit of the range is cm.    
    
    sigma   = 3; % Ranging data standard deviation.
    error   = sigma * randn(4,1);
    range1  = norm(tag_pos(k,:) - anchor(1,:)) + error(1);
    range2  = norm(tag_pos(k,:) - anchor(2,:)) + error(2);
    range3  = norm(tag_pos(k,:) - anchor(3,:)) + error(3);
    range4  = norm(tag_pos(k,:) - anchor(4,:)) + error(4);
    
    %figure;
    %scatter( anchor(1,:), anchor(2,:), 50, 'o', ...
    %                'MarkerEdgeColor',[0 .5 .5],...
    %                'MarkerFaceColor',[0 .7 .7],...
    %                'LineWidth',1.5);
    %hold on;                
    %scatter( tag_pos(k,1), tag_pos(k,2), 50, '*', ...
    %                'MarkerEdgeColor',[0.5 .2 .2],...
    %                'MarkerFaceColor',[0.7 .3 .3],...
    %                'LineWidth',1.5);
    
    %%3. Position estimation.
    %3.1 Call Trilateration_Norrdine to use only three anchors(the first three are used)
    P = anchor';        
    S = [range1 range2 range3 range4];    
    W = diag(ones(1,length(S)));
    
    [N1 N2] = Trilateration_Norrdine(P,S,W);
    assert(isequal(N1,N2));
    esti_pos1(k,:) = N1(2:4);
        
    %3.2 Call RecTrilateration_Norrdine to use all four anchors
    Nmat = RecTrilateration_Norrdine(P,S,W);    
    esti_pos2(k,:) = Nmat(2:4,(size(P,2)-1));
    
    %3.3 Call ls_trilat2d to use all four anchors
    AncPos = P(1:2,:);
    esti_pos3(k,1:2) = ls_trilat2d(AncPos, S);
    
    %3.4 Call trilat2d_geometrical_method to use all four anchors
    esti_pos4(k,1:2) = trilat2d_geometrical_method(P(:,1), P(:,2), P(:,3), S(1), S(2), S(3));
   
    dist_err(k,1) = norm(esti_pos1(k,1:2) - tag_pos(k,1:2));
    dist_err(k,2) = norm(esti_pos2(k,1:2) - tag_pos(k,1:2));
    dist_err(k,3) = norm(esti_pos3(k,1:2) - tag_pos(k,1:2));
    dist_err(k,4) = norm(esti_pos4(k,1:2) - tag_pos(k,1:2));
   
    %fprintf(1,'tag_pos       = %g %g\n', tag_pos(k,1)  ,tag_pos(k,2)  );
    %fprintf(1,'range error   = %g %g %g %g\n', dist_err(k,:));
           
    if mod(k,1000) == 0
        fprintf(1, 'k = %d\n', k);
    end
end

xy_err1 = esti_pos1(:,1:2) - tag_pos(:,1:2);
xy_err2 = esti_pos2(:,1:2) - tag_pos(:,1:2);
xy_err3 = esti_pos3(:,1:2) - tag_pos(:,1:2);
xy_err4 = esti_pos4(:,1:2) - tag_pos(:,1:2);

figure;
subplot(2,2,1); scatter(xy_err1(:,1),xy_err1(:,2)); title('position deviation scatter diagram');
subplot(2,2,2); scatter(xy_err2(:,1),xy_err2(:,2)); title('position deviation scatter diagram');
subplot(2,2,3); scatter(xy_err3(:,1),xy_err3(:,2)); title('position deviation scatter diagram');
subplot(2,2,4); scatter(xy_err4(:,1),xy_err4(:,2)); title('position deviation scatter diagram');

figure;
subplot(2,2,1); hist(dist_err(:,1)); title('postion distance error histogram');
subplot(2,2,2); hist(dist_err(:,2)); title('postion distance error histogram');
subplot(2,2,3); hist(dist_err(:,3)); title('postion distance error histogram');
subplot(2,2,4); hist(dist_err(:,4)); title('postion distance error histogram');

fprintf(1,'Assuming ranging error standard deviation is %g\n', sigma);
disp(std(dist_err(:,1)));
disp(std(dist_err(:,2)));
disp(std(dist_err(:,3)));
disp(std(dist_err(:,4)));