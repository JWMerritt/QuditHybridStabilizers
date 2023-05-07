function Out = EntropyOfRegionSize(RegionSize,BigramIn,SystemSize)
% Calculates average entropy of all regions of size $RegionSize
% V. 3.0

% Entropy of region A is |A|-|G_A|, where |G_A| is the number of stabilizers supported on A (in clipped gauge).
% If the region wraps around the system's endpoints, then we can find the entropy of A's complement.
% This method should work for both pure and mixed states.
% This is the most inelegant, brute force method I know, and I should have gone with this from the beginning...

SiteBigrams = ceil(BigramIn/2);
Out = 0;


% First, the properly contiguous regions
NumRegions = SystemSize-RegionSize+1;

for ii=1:NumRegions
    EndpointsSupported = (SiteBigrams>=ii).*(SiteBigrams<=(ii+RegionSize-1));
    NumberGenerators = sum(EndpointsSupported(:,1).*EndpointsSupported(:,2));
    Out = Out + RegionSize - NumberGenerators;
        % Add this region's entropy to the toal
end


% Then, the wrap-around regions
ComplementSize = SystemSize-RegionSize;
NumComplements = SystemSize-NumRegions;

for ii=2:(NumComplements+1)
    EndpointsSupported = (SiteBigrams>=ii).*(SiteBigrams<=(ii+ComplementSize-1));
    NumberGenerators = sum(EndpointsSupported(:,1).*EndpointsSupported(:,2));
    Out = Out + ComplementSize - NumberGenerators;
end

Out = Out/SystemSize;

end