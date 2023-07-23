function [Out,LessThanFlag] = LengthDistribution(BigramsIn,SystemSize,GiveWarning)
%LENGTHDISTRIBUTION  Find the distribution of stabilizers as a function of
% stabilizer length.
%
%   OUT = LENGTHDISTRIBUTION(BIGRAMS, N) returns the length distribution of
%   the stabilizers described by BIGRAMS.
%   >> Note that this length distribution includes both endpoints of the
%   stabilizer in the stabilizer's length, which is not the most common
%   convention, cf. https://doi.org/10.1103/PhysRevB.100.134306 .
%   >> Note that this length distribution is not normalized - it gives the
%   number of stabilizers, not the fraction.
%
%   -- BIGRAMS is the list of bigrams a state, calculated from the
%   generators of the state in the clipped gauge.
%
%   -- N is the number of sites in the system.

%   Gives the distribution of lengths of a set of bigrams. Out(L) = number of stabilizers of length L. ### NOT NORMALIZED

if nargin<3
    GiveWarning = false;
end

[NumRows,NumColumns] = size(BigramsIn);

if NumColumns~=2
    ColErrStruct = struct('message','Error in LengthDistribution: Bigram list does not have two columns. Make sure the first input is a Bigram list.','identifier','LengthDistribution:BigramColumnError');
    error(ColErrStruct)
end

Out = zeros(SystemSize,1);
if NumRows==0
    return % The state is completely mixed.
end

SiteBigrams = ceil(BigramsIn/2);

Lengths = SiteBigrams(:,2) - SiteBigrams(:,1) + 1;
% With this +1, generators supported on a single site are cosidered to have a length of 1.

for ii=1:SystemSize
    Out(ii) = sum(Lengths==ii);
end

%   This code is to give us a warning if the total number of entries in
%   'Lengths' doesn't add up to the system, size, which it always should if
%   Bigrams_ describes a pure state.

LessThanFlag = false;

if sum(Out)<SystemSize
    LessThanFlag = true;
    if GiveWarning
        fprintf('\nWarning: Total number of entries in LengthDistribution is less than system size.\n')
    end
elseif sum(Out)>SystemSize
    LessThanFlag = true;
    fprintf('\nWARNING: Total number of entries in LengthDistribution is MORE than system size!?\n')
end

end