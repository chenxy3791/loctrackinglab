% chenxy, 2019-11-30

close all; clear all; clc

%global SYSCNT_PERIOD

SYSCNT_PERIOD = 2^40;

%% In the original data, there is severe discontinuity in around 73000~74000.
%% the first half and the second half cannot be used together.

%% nlines = 50000; % Number of lines to be read into memory.

filename = 'trek_cnt_tx_rx_ppm_20191209_1741.txt';
disp(filename);

% There is error with this command. -- To be investigated.

%% dat = load(filename); 
%% 
%% ttcko = us2signed(dat(:,4), 19);
%% ttcki = dat(:,5);
%% 
%% ppm_meas = ttcko./ttcki * 1e6;
%% 
%% figure; plot(ppm_meas); title('PPM reported from DW1000'); ylabel('ppm');

fid = fopen(filename,'r');
datarray  = [];
totalline = 0;
validline = 0;

%%1. Read data from file
while (~feof(fid))

    totalline = totalline + 1;    
    str = fgetl(fid); % Read one line as a string.
    S   = regexp(str, '\s+', 'split');
    [size1 size2] = size(S);
    assert(size1 == 1);
    
    if(size2 == 6)
        S = S(2:6);
    end    
    size2 = size(S,2);
    
    if(size2 == 5)
        tmp = zeros(1,5);
        validline= validline + 1;
        % pkt counter
        s1 = char(S(1));
        tmp(1)   = str2num((s1));
        
        % txstamp
        s2 = char(S(2)); 
        tmp(2)   = hex2dec((s2(3:end)));

        % rxstamp
        s3 = char(S(3)); 
        tmp(3)   = hex2dec((s3(3:end)));

        % ttcko
        s4 = char(S(4)); 
        tmp(4)   = hex2dec((s4(3:end)));
                
        % ttcki
        s5 = char(S(5)); 
        tmp(5)   = hex2dec((s5(3:end)));
  
        datarray = [datarray; tmp];
    end
     
    if mod(totalline, 10000) == 0
        fprintf(1, 'totalline = %d\n', totalline);
    end    
    %% if totalline == 50000
    %%     break;
    %% end
end
fclose(fid);
fprintf(1, 'totalline = %d, validline = %d\n', totalline, validline);

%%2. Repair the data
%2.1 Remove duplicated lines.
dat1  = datarray(1,:);
for k = 2:1:totalline
    if datarray(k,1) ~= datarray(k-1,1)
        dat1  = [dat1; datarray(k,:)];
    end
end
disp('Duplicated lines removal: complete!')

%2.2 unwrap pkt_cnt
dat1(:,1) = general_unwrap(dat1(:,1), 256);
disp('Pkt_cnt unwrapping: complete!')

%2.3 unwrap txstamp
dat1(:,2) = general_unwrap(dat1(:,2), SYSCNT_PERIOD);
disp('Txstamp unwrapping: complete!')

%2.4 unwrap rxstamp.
dat1(:,3) = general_unwrap(dat1(:,3), SYSCNT_PERIOD);
disp('Rxstamp unwrapping: complete!')

%2.5 Insert the lost packets by interpolation.
dat2  = [];
for k = 1:1:size(dat1,1)-1
    dat2  = [dat2; dat1(k,:)];
    num_ins = dat1(k+1,1) - dat1(k,1) - 1;
    for jj = 1:1:num_ins
        cnt    = dat1(k,1) + jj;
        txtime = (dat1(k,2)*(num_ins + 1 - jj) + dat1(k+1,2)*jj)/(num_ins+1);
        rxtime = (dat1(k,3)*(num_ins + 1 - jj) + dat1(k+1,3)*jj)/(num_ins+1);
        ttcko  = dat1(k,4);
        ttcki  = dat1(k,5);
        dat2  = [dat2; [cnt txtime rxtime ttcko ttcki]];
    end    
end
disp('Lost packet insertion: complete!')

pkt_cnt = dat2(:,1);
txstamp = dat2(:,2);
rxstamp = dat2(:,3);

figure; plot(diff(pkt_cnt)); title('difference of pkt count after unwrapping');

figure; plot(txstamp); title('tx timestamp');
figure; plot(rxstamp); title('rx timestamp');
figure; plot(diff(txstamp/64)); title('diff of tx timestamp'); ylabel('ns');
figure; plot(diff(rxstamp/64)); title('diff of rx timestamp'); ylabel('ns');

% Remove the extra error -- temporariry solution, as measure the new problem in this data.
%sync_period = txstamp(2) - txstamp(1);
%for k = 1:1:length(rxstamp)-1
%    if ((rxstamp(k+1) - rxstamp(k)) - sync_period) > 100
%        rxstamp(k+1) = rxstamp(k) + sync_period;
%    end    
%end
rxstamp_diff = diff(rxstamp);
rxstamp_norm = rxstamp_diff-mean(rxstamp_diff);
rxstamp_norm1 = rxstamp_norm(abs(rxstamp_norm) < 1000);
figure; plot(rxstamp_norm1);
x = rxstamp_norm1(10000:end)/64;
hist(x,100);
disp(std(x))

%% In the original data, there is severe discontinuity in around 73000~74000.
%% the first half and the second half cannot be used together.
x = dat2(1:end,2)/64e9; % txstamp, in unit of second.
y = dat2(1:end,3)/64e9; % rxstamp, in unit of second.

%% x = dat2(75000:end,2)/64e9; % txstamp, in unit of second.
%% y = dat2(75000:end,3)/64e9; % rxstamp, in unit of second.
