% chenxy, 2019-11-30

global filename0 SYSCNT_PERIOD
%SYSCNT_PERIOD = 2^40;
filename0 = 'cir&lde_20191226_1517';

filename  = [filename0 '.txt'];
disp(filename);

fid = fopen(filename,'r');
%% log_filename = [filename0 '.log'];
%% log_fid      = fopen(log_filename,'w');
totalline    = 0;
validline    = 0;
cir          = zeros(1024,1);
cir_wptr     = 1;

%%1. Read data from file

%1.1 Skip the first two lines.
str = fgetl(fid); % Read one line as a string.
disp(str)
str = fgetl(fid); % Read one line as a string.
disp(str)

ng_lines = [];
while (~feof(fid))
    totalline = totalline + 1;
    str = fgetl(fid); % Read one line as a string.
    S   = regexp(str, '\s+', 'split');
    [size1 size2] = size(S);
    assert(size1 == 1);
    
    if(size2 == 10) % To handle the case that 'space' appears in the beginning of a line.
        %disp(S);
        S = S(2:10);
    end        
           
    % real1_str = [char(S(3)) char(S(2))];
    % imag1_str = [char(S(5)) char(S(4))];
    % real2_str = [char(S(7)) char(S(6))];
    % imag2_str = [char(S(9)) char(S(8))];

    real1_str = [char(S(8)) char(S(9))];
    imag1_str = [char(S(6)) char(S(7))];
    real2_str = [char(S(4)) char(S(5))];
    imag2_str = [char(S(2)) char(S(3))];

    real1     = us2signed(hex2dec(real1_str), 16);
    imag1     = us2signed(hex2dec(imag1_str), 16);
    real2     = us2signed(hex2dec(real2_str), 16);
    imag2     = us2signed(hex2dec(imag2_str), 16);   
                   
    cir(cir_wptr) = complex( real1, imag1 );
    cir_wptr = cir_wptr + 1;              
    cir(cir_wptr) = complex( real2, imag2 );
    cir_wptr = cir_wptr + 1;
    
end
fclose(fid);
disp(cir_wptr)

figure;
subplot(1,2,1); plot(abs(cir(1:992))) ; title('cir plot in real domain');
subplot(1,2,2); plot(20*log10(abs(cir(1:992)))) ; title('cir plot in log domain'); ylabel('dB');
