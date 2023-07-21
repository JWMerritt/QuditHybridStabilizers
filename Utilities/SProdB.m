function Out = SProdB(a,b,Hdim)
%SPRODB  Calculate the symplectic product of two row vectors using the
% bosonic symplectic matrix.
%
%   OUT = SPRODB(A, B, HDIM) calculates the row-vector symplectic inner
%   product modulo HDIM, OUT = A*M*B, where M is the bosonic symplectic
%   metric.
%
%   See also SYMPLECTICMETRICBOSON

[~,aNumColumns] = size(a);
[~,bNumColumns] = size(b);

% NumColumns is the dimensionality of the space
% Each matrix has NumRows vectors stacked on top of each other

if aNumColumns~=bNumColumns
    fprintf("Vector dimensions not equal!\n")
    Out = [];
    return
end

Dim = aNumColumns;
Om = SMetric(Dim);

Out = mod(a*Om*b',Hdim);
    
end