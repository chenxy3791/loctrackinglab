function dout = hybrid1_mag(din)
% HYBRID1_MAG: Hybrid1 approximation of complex magnitude
% Input:
%   din: complex input sequence. 
%        Cannot handle 2-D array input.
%   a:
%   b:
% Output:
%   dout: real output sequence.  

i_abs     = abs(real(din));
q_abs     = abs(imag(din));
max_iqabs = max([i_abs(:) q_abs(:)], [], 2); % Find max for each pair of I/Q.

part1     = floor((i_abs(:) + q_abs(:)) * 3 / 8);
part2     = floor((max_iqabs * 5 / 8));

dout      = (part1 + part2);

end