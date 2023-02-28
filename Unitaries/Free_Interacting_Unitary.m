function [Psi,Unitary] = Free_Interacting_Unitary(Psi,NumColumns,C_Numbers_Int,Hdim,RunOptions,Offset)
%   The main unitary, that has a parameter switching between free and interacting unitary gates.
%   Chooses between the two independently for each pair of sites.
%   Assumes C_Numbers_Int is C_Numbers_2, where the first 24 entries are the free unitaries, and the last 24 are interacting.

%   The code below is essentially a modified GetSystemSymplectic, but with another choice when making the pair-symplectics

Num_C_Numbers = numel(C_Numbers_Int);
%   We expect that this is C_Numbers_2

NumPairs = NumColumns/4;
EvenNumOfSites = (floor(NumPairs)==NumPairs);
%   This will return false if there are an odd number of sites.

S = speye(NumColumns);
for PairIndex = 0:NumPairs-2

    if rand<RunOptions.InteractingProbability
        % These are the interacting gates
        RandNum = randi([25,48]);
    else
        % These are the free gates
        RandNum = randi([1,24]);
    end

    S_Local = GetCliff(C_Numbers_Int(RandNum),Hdim);
    ColumnIndex = 4*PairIndex+2*Offset;
    S(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = S_Local;

end

if Offset==0

    %   Do the usual for the last site.
    
    if rand<RunOptions.InteractingProbability
        % These are the interacting gates
        RandNum = randi([25,48]);
    else
        % These are the free gates
        RandNum = randi([1,24]);
    end

    S_Local = GetCliff(C_Numbers_Int(RandNum),Hdim);
    ColumnIndex = NumColumns-4;
    S(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = S_Local;

elseif Offset==1

    %   Do the usual, but flip the signs of half of the matrix.
    
    if rand<RunOptions.InteractingProbability
        % These are the interacting gates
        RandNum = randi([25,48]);
    else
        % These are the free gates
        RandNum = randi([1,24]);
    end

    S_Local = -diag([-1,-1,1,1])*GetCliff(C_Numbers_Int(RandNum),Hdim)*diag([1,1,-1,-1]);
    %   This modifies the Symplectic matrix to account for the change in the metric as we wrap around the system.
    Indices = [NumColumns-1, NumColumns, 1,2];
    S(Indices,Indices) = S_Local;

else

    fprintf("Error in GetSystemSymplectic() : Offset must be equal to 0 or 1.\n")

end

Psi = mod(Psi*S,Hdim);
Unitary = S;

end