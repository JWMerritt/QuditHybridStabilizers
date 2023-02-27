function [S,EvenNumOfSites] = GetSystemSymplectic(NumColumns,C_Numbers_Int,Hdim,Offset)
%   Creates a symplectic matrix which is the direct sum of 4x4 symplectic matrices. Uses periodic BC.
%   Offset=0 is for odd sites, (1,2), (3,4), ..., (L-1,L).
%   Offset=1 is for even sites, (2,3), (4,5), ..., (L,1).

Num_C_Numbers = numel(C_Numbers_Int);

NumPairs = NumColumns/4;
EvenNumOfSites = (floor(NumPairs)==NumPairs);
%   This will return false if there are an odd number of sites.

S = speye(NumColumns);
for PairIndex = 0:NumPairs-2
    %PairIndex
    RandNum = randi([1,Num_C_Numbers]);
    S_Local = GetCliff(C_Numbers_Int(RandNum,Hdim);
    ColumnIndex = 4*PairIndex+2*Offset;
    S(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = S_Local;
end

if Offset==0
    %   Do the usual for the last site.
    RandNum = randi([1,Num_C_Numbers]);
    S_Local = GetCliff(C_Numbers_Int(RandNum),Hdim);
    ColumnIndex = NumColumns-4;
    S(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = S_Local;
elseif Offset==1
    %   Do the usual, but flip the signs of half of the matrix.
    RandNum = randi([1,Num_C_Numbers]);
    S_Local = -diag([-1,-1,1,1])*GetCliff(C_Numbers_Int(RandNum),Hdim)*diag([1,1,-1,-1]);
    %   This modifies the Symplectic matrix to account for the change in the metric as we wrap around the system.
    Indices = [NumColumns-1, NumColumns, 1,2];
    S(Indices,Indices) = S_Local;
else
    fprintf("Error in GetSystemSymplectic() : Offset must be equal to 0 or 1.\n")
end


end