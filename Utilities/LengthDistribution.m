function [Out,LessThanFlag] = LengthDistribution(Bigrams_,SystemSize,GiveWarning)
%   Gives the distribution of lengths of a set of bigrams. Out(L) = number of stabilizers of length L.

if nargin<3
    GiveWarning = false;
end

[NumRows,NumColumns] = size(Bigrams_);

Out = zeros(SystemSize,1);
if NumRows==0
    return % The state is completely mixed.
end

Lengths = ceil((Bigrams_(:,2) - Bigrams_(:,1))/2);

for ii=1:SystemSize
    Out(ii) = sum(Lengths==ii);
end

%   This code is to give us a warning if the total number of entries in
%   'Lengths' doesn't add up to the system, size, which it always should if
%   Bigrams_ describes a pure state.

LessThanFlag = false;

if sum(Lengths)<SystemSize
    LessThanFlag = true;
    if GiveWarning
        fprintf('\nWarning: Total number of entries in LengthDistribution is less than system size.\n')
    end
elseif sum(Lengths)>SystemSize
    LessThanFlag = true;
    fprinft('\nWARNING: Total number of entries in LengthDistribution is MORE than system size!?\n')
end


end