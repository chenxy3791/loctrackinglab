% chenxy, 2019-11-30
close all; clear; clc

global filename0 SYSCNT_PERIOD

addpath('..\data\');

%filename0 = 'normal_CIR_dump_20200102_1900'; nFrames = 74;
%filename0 = 'normal_CIR_dump_20200103_0945'; nFrames = 587;
filename0 = 'normal_CIR_outdoor_10m_20200107_1424';  nFrames = 14;

filename  = [filename0 '.txt'];
disp(filename);

fid = fopen(filename,'r');
%% log_filename = [filename0 '.log'];
%% log_fid      = fopen(log_filename,'w');

cir          = zeros(1016,nFrames); % Assume a maximum of 10 frames of data.

for k = 1:nFrames
    %fprintf(1, 'k = %d\n', k);
    
    linecnt  = 0;
    cir_wptr = 1;    
     
    while (1) %( ~feof(fid))
        linecnt = linecnt + 1;
        str = fgetl(fid); % Read one line as a string.
        S   = regexp(str, '\s+', 'split');
        [size1 size2] = size(S);
        assert(size1 == 1);

        %if(strcmp(char(S(1)), '')) % To handle the case that 'space' appears in the beginning of a line.
        if(isequal(size(char(S(1))),[1,0]))
            S = S(3:end);
        else
            S = S(2:end);
        end        

        if(linecnt == 3)
            strtmp = [char(S(4)) char(S(3)) char(S(2)) char(S(1))];
            RX_TTCKI(k)   = hex2dec(strtmp);        
        end

        if(linecnt == 5)
            strtmp = [char(S(4)) char(S(3)) char(S(2)) char(S(1))];
            RX_TTCKO(k)   = hex2dec(strtmp);        
        end

        if(linecnt == 7)
            strtmp = [char(S(2)) char(S(1))];
            LDE_THRESH(k)   = hex2dec(strtmp);
        end
        if(linecnt == 8)
            strtmp = char(S(1));
            LDE_CFG1(k)   = hex2dec(strtmp);
        end        
        if(linecnt == 9)
            strtmp = [char(S(2)) char(S(1))];
            LDE_PPINDX(k)   = hex2dec(strtmp);
        end
        if(linecnt == 10)
            strtmp = [char(S(2)) char(S(1))];
            LDE_PPAMPL(k)   = hex2dec(strtmp);
        end
        if(linecnt == 11)
            strtmp = [char(S(2)) char(S(1))];
            LDE_RXANTD(k)   = hex2dec(strtmp);
        end        
        if(linecnt == 12)
            strtmp = [char(S(2)) char(S(1))];
            LDE_CFG2(k)   = hex2dec(strtmp);
        end        
        if(linecnt == 13)
            strtmp = [char(S(2)) char(S(1))];
            LDE_REPC(k)   = hex2dec(strtmp);
        end                
        
        if(linecnt == 19) % RX_TIME, assuming in ascending byte order
            RX_STAMP(k) = hex2dec([char(S(5)) char(S(4)) char(S(3)) char(S(2)) char(S(1))]);
            FP_INDEX(k) = hex2dec([char(S(7)) char(S(6))]); %
            FP_INDEX(k) = FP_INDEX(k)/64; % The 6 least significant bits of FP_INDEX represent the fractional part
            S8_prev     = char(S(8));
        end

        if(linecnt == 20) % RX_TIME, assuming in ascending byte order
            FPAMPL1(k)  = hex2dec([char(S(1)) S8_prev]);
            RX_RAWST(k) = hex2dec([char(S(6)) char(S(5)) char(S(4)) char(S(3)) char(S(2))]);
        end

        if(linecnt <= 21) continue; end% The first lines are register information for each packet.

        %size(S)
        %disp(S)
        assert(size(S,2)==8);
                    
        %% There maybe mistake in DW user-manual. 
        %% For each 2-bytes, take the left one as MSB, and the right one as LSB, seems to produce more reasonable CIR curve.
        %%        Tap[2*K]                    Tap[2*K+1]
        %% (1) I_MSB I_LSB Q_MSB Q_LSB     I_MSB I_LSB Q_MSB Q_LSB   -- which one?
        %% (2) Q_MSB Q_LSB I_MSB I_LSB     Q_MSB Q_LSB I_MSB I_LSB   -- which one?
        %% Currently, no obvious way to distinguish which one is correct.
        
        % real1_str = [char(S(7)) char(S(8))];
        % imag1_str = [char(S(5)) char(S(6))];
        % real2_str = [char(S(3)) char(S(4))];
        % imag2_str = [char(S(1)) char(S(2))];

        % Corresponding to the abovementioned (2)
        real2_str = [char(S(7)) char(S(8))];
        imag2_str = [char(S(5)) char(S(6))];
        real1_str = [char(S(3)) char(S(4))];
        imag1_str = [char(S(1)) char(S(2))];

        % Corresponding to the abovementioned (1)
        % imag2_str = [char(S(7)) char(S(8))];
        % real2_str = [char(S(5)) char(S(6))];
        % imag1_str = [char(S(3)) char(S(4))];
        % real1_str = [char(S(1)) char(S(2))];
    
        real1     = us2signed(hex2dec(real1_str), 16);
        imag1     = us2signed(hex2dec(imag1_str), 16);
        real2     = us2signed(hex2dec(real2_str), 16);
        imag2     = us2signed(hex2dec(imag2_str), 16);   
                       
        cir(cir_wptr,k) = complex( real1, imag1 );
        cir_wptr = cir_wptr + 1;              
        cir(cir_wptr,k) = complex( real2, imag2 );
        cir_wptr = cir_wptr + 1;        
        
        if (cir_wptr > 1016) break; end
    end
    %disp(cir_wptr)
                  
end

for k = 1:nFrames
    figure;
    plot(abs(cir(1:992,k))) ; title(['cir plot in real domain, k = ', num2str(k)]);
end

%% figure; hold on;
%% for k = 1:nFrames
%%     plot(abs(cir(1:992,k))) ; title('cir plot in real domain');
%% end


%% disp('Question1: The max postions from CIR amplitude are not the same as the reported LDE_PPINDX, why?');
cir = cir(1:992,:);
[cirMax, cirMaxPos] = max(abs(cir(1:992,:)));

disp(['cirMaxPos = ', num2str(cirMaxPos)]);
disp(['LDE_PPINDX  = ', num2str(LDE_PPINDX )]);
disp(['FP_INDEX  = ', num2str(FP_INDEX )]);
disp(['cirMax    = ', num2str(cirMax)]);
disp(['LDE_PPAMPL   = ', num2str(LDE_PPAMPL )]);

disp('Question2: It is supposed diff1 should the same for all packet. But why not?');
disp('RX_RAWST - RX_STAMP - (LDE_PPINDX - FP_INDEX) * 64 = :')
diff1 = RX_RAWST - RX_STAMP - (LDE_PPINDX - FP_INDEX) * 64 - LDE_RXANTD

disp('RX_RAWST - RX_STAMP - (750 - FP_INDEX) * 64 = ')
FIX_PPINDX = (RX_RAWST - RX_STAMP - (0 - FP_INDEX) * 64 - LDE_RXANTD)/64

figure; stem(FIX_PPINDX - 727.625); title('FIX_PPINDX ?')
      
fclose(fid);

save([filename0,'.mat'])
