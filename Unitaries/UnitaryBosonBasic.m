function [Psi,S] = UnitaryBosonBasic(Psi,NumColumns,C_Numbers_Int,Hdim,RunOptions,Offset)
%UNITARYBOSONBASIC  Apply random two-site Clifford unitary gates across an
% entire system.
%
%   PSI = UNITARYBOSONBASIC(PSI, NUM_COLS, [], HSIM, [], OFFSET)
%
%   PSI = UNITARYBOSONBASIC(PSI, NUM_COLS, CLIFF_NUMS, HDIM, RUNOPTIONS,
%   OFFSET) creates a syplectic matrix corresponding to two-site unitary
%   operations which are selected randomly over a uniform distribution of
%   all 4-by-4 symplectic matrices modulo HDIM and then applies the result
%   to the generating set PSI.
%
%   -- PSI is an N-by-2N matrix of integers modulo HDIM.
%
%   -- NUM_COLS is the number of columns of PSI.
%
%   -- CLIFF_NUMS is not used in this function, but is present for
%   consistency with other unitary functions.
%
%   -- HDIM is the qudit dimension, and should be a prime number.
%
%   -- RUNOPTIONS s not used in this function, but is present for
%   consistency with other unitary functions.
%
%   -- OFFSET is a number, either 0 or 1, which will offset the symplectic
%   matrices by this many sites.
%
%   [PSI, S] = UNITARYBOSONBASIC(PSI, NUM_COLS, CLIFF_NUMS, HDIM,
%   RUNOPTIONS, OFFSET) returns the symplectic matrix S which is applied to
%   the system.

    NumPairs = NumColumns/4;
    
    S = speye(NumColumns);
    
    for PairIndex = 0:NumPairs-2
    
        S_Local = SymplecticBoson(Hdim);
        ColumnIndex = 4*PairIndex+2*Offset;
        S(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = S_Local;
    
    end
    
    S_Local = SystemSymplecticBoson(Hdim);
    
    if Offset==0
        Indices = NumColumns-3:NumColumns;
        S(Indices,Indices) = S_Local;
    elseif Offset==1
        Indices = [NumColumns-1, NumColumns, 1, 2];
        S(Indices,Indices) = S_Local;
    else
        error('Offset must be 0 or 1.')
    end
    
    Psi = mod(Psi*S,Hdim);

end

