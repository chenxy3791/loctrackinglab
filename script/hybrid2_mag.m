function dout = hybrid2_mag(din)
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
min_iqabs = min([i_abs(:) q_abs(:)], [], 2); % Find max for each pair of I/Q.

appr1     = max_iqabs*(7/8) + min_iqabs*(1/2);

dout      = max([max_iqabs(:) appr1(:)], [], 2);

end