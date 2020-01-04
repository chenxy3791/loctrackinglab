% chenxy, 2019-11-18
% Demonstration program for 2D-TDOA with three anchors.
% Test with data from actual measureement.

clear all; close all;

ANC    = zeros(4,2);
% Measurement data captured by YanChao@2019/11/20.
ANC(1,:) = [15.611, 9.453]; % B0
ANC(2,:) = [15.62,   6.65]; % B1 
ANC(3,:) = [18.879,  6.65]; % B2
ANC(4,:) = [18.888,  9.49]; % B3
TAG      = [16.284, 8.453]; % TAG

dist_meas(1)   = 1.407;
dist_meas(2)   = 1.916;
dist_meas(3)   = 3.219;
dist_meas(4)   = 2.957;

case_idx = 0;
fid = fopen('test_result.txt','w');

for ref_anc = 1:1:4
    for unused_anc = 1:1:4
        
        if (unused_anc == ref_anc) continue; end
        
        % anchor2
        for k = 1:1:4
            if k ~= ref_anc && unused_anc
                anc2 = k;
                break;
            end
        end
        % anchor3
        for k = 1:1:4
            if k ~= ref_anc && k ~= unused_anc && k ~= anc2
                anc3 = k;
                break;
            end
        end
        case_idx = case_idx + 1;        
        anc_set_uesd = [ref_anc,anc2,anc3,unused_anc]; % The first is used as reference anchor, the last is not used.
        fprintf(1,'case#%d: anc1~4 = [%d %d %d %d]\n', case_idx, anc_set_uesd);

        ANC_POS = [ ANC(anc_set_uesd(1),:) - ANC(anc_set_uesd(1),:); ...
                    ANC(anc_set_uesd(2),:) - ANC(anc_set_uesd(1),:); ...
                    ANC(anc_set_uesd(3),:) - ANC(anc_set_uesd(1),:); ...
                    ANC(anc_set_uesd(4),:) - ANC(anc_set_uesd(1),:) ];
                    
        TAG_POS = TAG - ANC(anc_set_uesd(1),:);
        
        dist1 = euclid_dist(ANC_POS(1,:), TAG_POS);
        dist2 = euclid_dist(ANC_POS(2,:), TAG_POS);
        dist3 = euclid_dist(ANC_POS(3,:), TAG_POS);
        dist4 = euclid_dist(ANC_POS(4,:), TAG_POS);
        
        % fprintf(1,'dist1~4 = %g, %g, %g, %g\n', dist1, dist2, dist3, dist4);

        if(1) %--The actual measuree
            R(1)   = dist_meas(anc_set_uesd(1));
            R(2)   = dist_meas(anc_set_uesd(2));
            R(3)   = dist_meas(anc_set_uesd(3));
            R(4)   = dist_meas(anc_set_uesd(4));
        else
            R(1)   = dist1;
            R(2)   = dist2;
            R(3)   = dist3;
            R(4)   = dist4;
        end    
         
        dist21 = R(2)-R(1);
        dist31 = R(3)-R(1);
        dist41 = R(4)-R(1);
        
        [OUT, OUT1, OUT2]  = tdoa2d(ANC_POS, dist21, dist31);
        
        %% figure;
        %% scatter(ANC_POS(1:3,1),ANC_POS(1:3,2), 100,'rs','filled'); hold on;
        %% scatter(TAG_POS(1), TAG_POS(2),    50, 'bo','filled'); hold on;
        %%   
        %% xlabel('X [m]');
        %% ylabel('Y [m]');
        %% box on;   hold on;
        %% scatter(OUT1(1),    OUT1(2),   50, 'kp','filled'); hold on;
        %% scatter(OUT2(1),    OUT2(2),   50, 'bd','filled'); hold on;
        %% legend('Anchor', 'Tag - Actual Position', 'Tag - esti1', 'Tag - esti2');
        %% title('Illustration of 2D TDOA'); grid on;

        %% OUT
        %% ANC(anc_set_uesd(1),:)        
        TAG_POS_esti = OUT + ANC(anc_set_uesd(1),:)'; % Note the alignement of dimensionality.

        fprintf(fid,'case#%d: anc1~4 = [%d %d %d %d], esti_pos = [%g, %g], esti_err = [%g, %g]\n',...
            case_idx, ...
            anc_set_uesd(1), anc_set_uesd(2), anc_set_uesd(3), anc_set_uesd(4),...
            TAG_POS_esti(1), TAG_POS_esti(2), ...
            TAG_POS_esti(1)-TAG(1), TAG_POS_esti(2)-TAG(2) );
    end
end    

fclose(fid);