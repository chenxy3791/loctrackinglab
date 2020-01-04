% chenxy, 2019-11-30

global filename0 SYSCNT_PERIOD
%SYSCNT_PERIOD = 2^40;

filename  = [filename0 '.txt'];
disp(filename);

% There is error with this command. -- To be investigated.
%% dat = load(filename); 

fid = fopen(filename,'r');
log_filename = [filename0 '.log'];
log_fid      = fopen(log_filename,'w');
datarray  = [];
totalline = 0;
validline = 0;

%%1. Read data from file
ng_lines = [];
while (~feof(fid))

    totalline = totalline + 1;
    str = fgetl(fid); % Read one line as a string.
    S   = regexp(str, '\s+', 'split');
    [size1 size2] = size(S);
    assert(size1 == 1);
    
    if(size2 == 6) % To handle the case that 'space' appears in the beginning of a line.
        S = S(2:6);
    end    
    size2 = size(S,2);
    
    if isequal(char(S(1)), 'NG') 
        ng_lines = [ng_lines; S];

        fprintf(log_fid,'lineNo = %d: ',totalline);
        for kk=1:1:length(S)
            fprintf(log_fid,'%s ',char(S(kk)));
        end
        fprintf(log_fid,'\n');
        disp(S);    
        continue
    end    
    
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
     
    if mod(totalline, 10000) == 0
        fprintf(1, 'totalline = %d\n', totalline);
    end    
    %% if totalline == 20000
    %%     break;
    %% end
end
fclose(fid);
fprintf(log_fid, 'totalline = %d, validline = %d\n', totalline, validline);
fprintf(log_fid,'\n\n');

%%2. Repair the data
%2.1 Remove duplicated lines.
dat1  = datarray(1,:);
for k = 2:1:validline
    if datarray(k,1) ~= datarray(k-1,1)
        dat1  = [dat1; datarray(k,:)];
    else
        fprintf(log_fid,'k = %d, duplicated line\n', k);
    end
end
fprintf(log_fid,'Totally, %d Duplicated lines have been removed\n', size(datarray,1)-size(dat1,1));
fprintf(log_fid,'\n\n');

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
total_num_ins = 0;
for k = 1:1:size(dat1,1)-1
    dat2  = [dat2; dat1(k,:)];
    num_ins = dat1(k+1,1) - dat1(k,1) - 1;
    if(num_ins > 0)
        fprintf(log_fid,'k=%d, %d lines to be inserted\n', k, num_ins);
        for jj = 1:1:num_ins
            cnt    = dat1(k,1) + jj;
            txtime = (dat1(k,2)*(num_ins + 1 - jj) + dat1(k+1,2)*jj)/(num_ins+1);
            rxtime = (dat1(k,3)*(num_ins + 1 - jj) + dat1(k+1,3)*jj)/(num_ins+1);
            ttcko  = dat1(k,4);
            ttcki  = dat1(k,5);
            dat2  = [dat2; [cnt txtime rxtime ttcko ttcki]];
        end    
        total_num_ins = total_num_ins + num_ins;
    end
end
fprintf(log_fid,'Totally, %d lines have been inserted\n', total_num_ins);
disp('Lost packet insertion: complete!')

save([filename0 '.mat'], 'dat2');
fclose(log_fid);
