function StateOut = UnitaryMajoranaBasic(StateIn,NumColumns,C_Numbers_Hdim,Hdim,~,Offset)
%UNITARYMAJORANABASIC  Apply random two-site Clifford unitary gates across an
% entire system.
%
%   PSI = UNITARYMAJORANABASIC(PSI, NUM_COLS, CLIFF_NUMS, HSIM, ~, OFFSET)
%
%   PSI = UNITARYMAJORANABASIC(PSI, NUM_COLS, CLIFF_NUMS, HDIM, RUNOPTIONS,
%   OFFSET) creates a syplectic matrix corresponding to two-site unitary
%   operations which are selected randomly over a uniform distribution of
%   all 4-by-4 symplectic matrices modulo HDIM and then applies the result
%   to the generating set PSI.
%
%   -- PSI is an N-by-2N matrix of integers modulo HDIM, and is the
%   generating set of the stabilizer state.
%
%   -- NUM_COLS is the number of columns of PSI.
%
%   -- CLIFF_NUMS is the list of numbers corresonding to (symplectic)
%   Clifford matrices for the relevant value of Hdim.
%
%   -- HDIM is the parafermion order, and should be a prime number.
%
%   -- RUNOPTIONS s not used in this function, but is present for
%   consistency with other unitary functions.
%
%   -- OFFSET is a number, either 0 or 1, which will offset the symplectic
%   matrices by this many sites.

    % Mostly a wrapper for SystemSymplecticMajorana, but in a standard form.
    
    SystemSymplectic = SymplecticMajorana(C_Numbers_Hdim, Hdim, NumColumns/2, Offset);
    %   We dont need any RunOptions for this evolution.
    
    StateOut = mod(StateIn*SystemSymplectic,Hdim);

end