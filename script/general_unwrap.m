function out = general_unwrap(in, wrap_period)

%%% Assuming the input is in ascenting order.

nums = length(in);

for k = 1:nums - 1
    if in(k) - in(k+1) >= wrap_period/2
        in(k+1:end) = in(k+1:end) + wrap_period;
    end        
end

out = in;