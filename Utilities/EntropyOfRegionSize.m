function Out = EntropyOfRegionSize(RegionSize,BigramIn,SystemSize)
% Calculates average entropy of all regions of size $RegionSize

% Entropy of region A is |A|-|G_A|, where |G_A| is the number of stabilizers supported on A (in clipped gauge)
% Average Entropy = 1/N * (Sum of entropy for all N of the possible regions A, assuming periodic boundary conditions)
% Sum of entropies = sum over A of (L - |G_A|) = NL - sum over A of (|G_A|)
% Each generator g of length (l_g) is going to be supported in L-(l_g)+1 different regions of length L,
%   as long as l_g < L
% If there are K generators with $l_g <= L), then 
%   sum over A of (|G_A|) = sum over g in generator group of (L - (l_g) + 1) = KL - sum over g of (l_g - 1).
% Thus, for a pure or mixed state,
% Average Entropy = 1/N * (NL - KL + sum over g (l_g - 1)) = 1/N*((N-K)L + sum over g (l_g - 1))

SiteBigrams = ceil(BigramIn/2);
%   This gives the endpoints in terms of sites instead of operator indeces
LengthsMinusOne = SiteBigrams(:,2)-SiteBigrams(:,1);
%   This is actually length - 1
SmallEnoughGenerators = LengthsMinusOne < RegionSize;

LengthSum = sum(LengthsMinusOne.*SmallEnoughGenerators);
NumSmallGenerators = sum(SmallEnoughGenerators);

Out = 1/SystemSize*( (SystemSize-NumSmallGenerators)*RegionSize + LengthSum);

end

