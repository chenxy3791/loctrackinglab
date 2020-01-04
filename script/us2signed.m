function out_data = us2signed(in_data, Nbits)

% Transform the Nbits fixed-point unsigned representation of signed data to the original signed
% representation, assuming the input is 2's complementary format.
% in_data:  Nbits fixed-point unsigned representation
% out_data: The original signed data;
% Nbits: Number of bits for the fixed-point represention.

out_data=in_data;

I_minus = find(in_data >= (2^(Nbits-1)));
out_data(I_minus) = in_data(I_minus) - (2^Nbits);

end