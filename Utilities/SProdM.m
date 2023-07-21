function Out = SProdM(a,b,Hdim)
%SPRODM  Calculate the symplectic product of two row vectors using the
% Majorana parafermion symplectic matrix.
%
%   OUT = SPRODM(A, B, HDIM) calculates the row-vector symplectic inner
%   product modulo HDIM, OUT = A*M*B, where M is the Majorana parafermion
%   symplectic metric.
%
%   See also SYMPLECTICMETRICMAJORANA


% Gives the row-vector symplectic inner product Out = a*Om*b'
% Can be used for matrices, too, as long as the dimensions line up.

[~,aNumColumns] = size(a);
[~,bNumColumns] = size(b);

% NumColumns is the dimensionality of the space
% Each matrix has NumRows vectors stacked on top of each other

if aNumColumns~=bNumColumns
    fprintf("Vector dimensions not equal!\n")
    Out = [];
    return
end

NumSites = aNumColumns/2;
Om = SymplecticMetricMajorana(NumSites);

Out = mod(a*Om*b',Hdim);
    
end