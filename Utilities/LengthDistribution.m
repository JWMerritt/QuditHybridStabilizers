function Out = LengthDistribution(Bigrams_,SystemSize)
%   Gives the distribution of lengths of a set of bigrams. Out(L) = number of stabilizers of length L.

[NumRows,NumColumns] = size(Bigrams_);

Out = zeros(SystemSize,1);
if NumRows==0
    return % The state is completely mixed.
end

Lengths = ceil((Bigrams_(:,2) - Bigrams_(:,1))/2);

for ii=1:SystemSize
    Out(ii) = sum(Lengths==ii);
end

end