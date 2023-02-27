function Out = LengthDistribution(Bigrams_,SystemSize)
%   Gives the distribution of lengths of a set of bigrams. Out(L) = number of stabilizers of length L.

Lengths = Bigrams_(2,:) - Bigrams_(1,:);
Out = zeros(SystemSize,1);

for ii=1:SystemSize
    Out(ii) = sum(Lengths==ii);
end

end