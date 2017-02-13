function [ out ] = NM_round_decimal(in, digit)
%NM_ROUND_DECIMAL Summary of this function goes here
%   Detailed explanation goes here

out = round(in.*(10 ^ digit))./(10 ^ digit);

end

