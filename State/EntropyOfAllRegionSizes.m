function Out = EntropyOfAllRegionSizes(BigramsIn,SystemSize,FullOutput)
%ENTROPYOFALLREGIONSIZES  Find the subsystem entropy for all region sizes
% in a system.
%
%   OUT = ENTROPYOFALLREGIONSIZES(BIGRAMS, N) returns the average subsystem
%   entropy for all regions of size L, for values of L from 1 to N/2. The
%   output stops at N/2 because a region of size L has the same subsystem
%   entropy as its complement system of size N-L, and thus the entropies
%   are not independent.
%
%   -- BIGRAMS is the list of bigrams a state, calculated from the
%   generators of the state in the clipped gauge.
%
%   -- N is the number of sites in the system.
%
%   OUT = ENTROPYOFALLREGIONSIZES(BIGRAMS, N, FULL_OUTPUT) will return the
%   average subsystem entropy for all regions of size L, for values in the
%   full range from 1 to N, if FULL_OUTPUT=true. The default value is
%   FULL_OUTPUT=false.
%
%   See also BIGRAMS, CLIP, ENTROPYOFREGIONSIZE

%   Sweeps over entropy of regions size [1,SystemSize/2] (since L and SystemSize-L give the same answer).

if nargin<=2
    FullOutput=false;
end

NumystemSizes = floor(SystemSize/2);
Out = zeros(NumystemSizes,1);

for ii=1:NumystemSizes
    Out(ii) = EntropyOfRegionSize(ii,BigramsIn,SystemSize);
end

if FullOutput
    Out = [Out;Out(end:-1:1)];
end

end
