function Out = SProd(a,b,Hdim)
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

Dim = aNumColumns;
Om = SMetric(Dim);

Out = mod(a*Om*b',Hdim);
    
end