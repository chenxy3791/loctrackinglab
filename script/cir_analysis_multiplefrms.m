% chenxy, 2019-11-30
close all; clear; clc

global filename0 SYSCNT_PERIOD

%filename0 = 'normal_CIR_dump_20191230_1114'; nFrames      = 5;
%filename0 = 'abnormal_CIR_dump_20191230_1114'; nFrames      = 7;
filename0 = 'normal_CIR_dump_20200101_1215'; nFrames      = 5;

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

        if(linecnt == 2)
            strtmp = char(S(1));            
            THRESH(k)   = hex2dec(strtmp(10:end));        
            strtmp = char(S(3));            
            PP_INDEX(k) = hex2dec(strtmp(10:end));
            strtmp = char(S(4));
            PP_AMPL(k)  = hex2dec(strtmp(10:end));
            strtmp = char(S(5));
            RXANTD(k)  = hex2dec(strtmp(10:end));            
        end
        
        %if(strcmp(char(S(1)), '')) % To handle the case that 'space' appears in the beginning of a line.
        if(isequal(size(char(S(1))),[1,0]))
            S = S(3:end);
        else
            S = S(2:end);
        end        

        if(linecnt == 8) % RX_TIME, assuming in ascending byte order
            RX_STAMP(k) = hex2dec([char(S(5)) char(S(4)) char(S(3)) char(S(2)) char(S(1))]);
            FP_INDEX(k) = hex2dec([char(S(7)) char(S(6))]); %
            FP_INDEX(k) = FP_INDEX(k)/64; % The 6 least significant bits of FP_INDEX represent the fractional part
            S8_prev     = char(S(8));
        end

        if(linecnt == 9) % RX_TIME, assuming in ascending byte order
            FPAMPL1(k)  = hex2dec([char(S(1)) S8_prev]);
            RX_RAWST(k) = hex2dec([char(S(6)) char(S(5)) char(S(4)) char(S(3)) char(S(2))]);
        end

        if(linecnt <= 10) continue; end% The first 10 lines are register information for each packet.

        %size(S)
        %disp(S)
        assert(size(S,2)==8);
                    
        real1_str = [char(S(7)) char(S(8))];
        imag1_str = [char(S(5)) char(S(6))];
        real2_str = [char(S(3)) char(S(4))];
        imag2_str = [char(S(1)) char(S(2))];
    
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
disp('Question1: The max postions from CIR amplitude are not the same as the reported PP_INDEX, why?');
[cirMax, cirMaxPos] = max(abs(cir(1:992,:)));
disp(['cirMaxPos = ', num2str(cirMaxPos)]);
disp(['PP_INDEX  = ', num2str(PP_INDEX )]);
disp(['FP_INDEX  = ', num2str(FP_INDEX )]);
disp(['cirMax    = ', num2str(cirMax)]);
disp(['PP_AMPL   = ', num2str(PP_AMPL )]);


disp('Question2: It is supposed diff1 should the same for all packet. But why not, and instead, diff2 are the same?');
disp('RX_RAWST - RX_STAMP - (PP_INDEX - FP_INDEX) * 64 = :')
diff1 = RX_RAWST - RX_STAMP - (PP_INDEX - FP_INDEX) * 64

disp('RX_RAWST - RX_STAMP - (750 - FP_INDEX) * 64 = ')
diff2 = RX_RAWST - RX_STAMP - (750 - FP_INDEX) * 64
      
fclose(fid);
