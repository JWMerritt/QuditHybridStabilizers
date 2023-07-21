function [MatrixOut,EvenNumOfSites] = SymplecticMajorana(NumSites,C_Numbers_Hdim,Hdim,Offset)
% [MatrixOut,EvenNumOfSites] = SystemSymplecticMajorana(NumSites,C_Numbers_Hdim,Hdim,Offset)
% MatrixOut is a symplectic matrix which is the direct sum of 4x4 symplectic matrices. Uses periodic boundary conditions.
% EvenNumOfSites is true if NumSites is even, false if NumSites is odd.
% The code can handle an odd NumSites, but expects NumSites to be even. Does not implement periodic boundary conditions for odd NumSites.
% Offset=0 is for odd pairs, (1,2), (3,4), ..., (N-1,N).
% Offset=1 is for even pairs, (2,3), (4,5), ..., (N,1).

Num_C_Numbers = numel(C_Numbers_Hdim);

NumPairs = floor(NumSites/2);

EvenNumOfSites = (NumPairs==NumSites/2);
%   This will return false if there are an odd number of sites.

MatrixOut = speye(2*NumSites);

for PairIndex = 0:NumPairs-2
    
    RandNum = randi([1,Num_C_Numbers]);
    SymplecticLocal = CliffordSymplecticMajorana(C_Numbers_Hdim(RandNum),Hdim);
    ColumnIndex = 4*PairIndex+2*Offset;
    MatrixOut(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = SymplecticLocal;

end



PairIndex = NumPairs-1;

if (Offset==0)||(~EvenNumOfSites)

    %   We do not need to wrap around the system.
    %   Do the previous, but for the last pair.
    RandNum = randi([1,Num_C_Numbers]);
    SymplecticLocal = CliffordSymplecticMajorana(C_Numbers_Hdim(RandNum),Hdim);
    ColumnIndex = 4*PairIndex+2*Offset;
    MatrixOut(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = SymplecticLocal;


elseif (Offset==1)&&(EvenNumOfSites)
    
    %   We need to wrap around the system.
    %   Do the previous, but negate half of the matrix.
    %   This modifies the Symplectic matrix to account for the change in the metric as we wrap around the system.
    RandNum = randi([1,Num_C_Numbers]);
    SymplecticLocal = mod(-diag([-1,-1,1,1])*CliffordSymplecticMajorana(C_Numbers_Hdim(RandNum),Hdim)*diag([1,1,-1,-1]),Hdim);
    Indices = [2*NumSites-1, 2*NumSites, 1,2];
    MatrixOut(Indices,Indices) = SymplecticLocal;

else

    fprintf("Error in GetSystemSymplectic() : Offset must be equal to 0 or 1.\n")

end


end