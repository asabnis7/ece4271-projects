function BER = bit_error(bits, est_bits)
% Find matches between bits and estimation
match = bits == est_bits;
error = numel(find(match==0));
% Find error rate
BER = error/length(bits);
end