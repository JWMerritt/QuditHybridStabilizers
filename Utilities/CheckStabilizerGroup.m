function Out = GenerateStabilizerGroup(In,Hdim)
%GENERATESTABILIZERGROUP  Generate the stabilizer group given a generating set.
%
%   Out = GENERATESTABILIZERGROUP(G,Hdim) A VERY COSTLY function that takes
%   a generating set G and generates the entire stabilizer group from it.
%   If G has N generators, the stabilizer group will be a (Hdim^N)-by-2N
%   matrix! 
% 
%   -- Hdim is assumed to be a prime number.

[NumRows,NumColumns] = size(In)

%U = @(n,d) mod(floor(n./(d.^Numbers)),d);
Digits = @(n) mod(floor(n./(Hdim.^(0:NumRows-1))),Hdim);
NumOutRows = Hdim^NumRows;
Out = zeros(NumOutRows,NumColumns,'single');
%   oof that's a big matrix!

for IterativeRowIndex=1:NumOutRows
    Out(IterativeRowIndex,:) = Digits(IterativeRowIndex)*In;
    %   This takes a linear combination of the rows of In, with the coefficients given by Digits()
    %   This will sweep over all possible combinations
end

end