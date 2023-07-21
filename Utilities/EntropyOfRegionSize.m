function Out = EntropyOfRegionSize(RegionSize,BigramIn,SystemSize)
%ENTROPYOFREGIONSIZE  Find the average subsystem entanglement entropy of
% all regions that have a certain size. Works for both pure and mixed
% states of both bosons (qudits) and parafermions.
%
%   OUT = ENTORPYOFREGIONSIZE(L, BIGRAMS, N) finds the subsystem
%   entanglement entropy of all regions of size L and returns their
%   average. Periodic boundary conditions are used, and regions which wrap
%   around the periodic boundary are included in the average.
%
%   -- BIGRAMS is the list of bigrams a state, calculated from the
%   generators of the state in the clipped gauge.
%
%   -- N is the number of sites in the system.
%
%   For more information on the mathematics involved, see:
%       https://doi.org/10.1103/PhysRevB.100.134306
%       https://doi.org/10.1103/PhysRevA.71.042315
%       https://doi.org/10.1016/j.physleta.2013.12.009
%       
%   See also BIGRAMS, CLIP

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