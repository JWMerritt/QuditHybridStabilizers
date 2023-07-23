function [Out, EvenNumOfSites] = SymplecticMajorana(C_Numbers_Hdim, Hdim, NumSites, Offset)
%SYPLECTICMAJORANA  Create symplectic matrices to effect a unitary Clifford
%transformation on a parafermion Majorana stabilizer state.
%
%   OUT = SYMPLECTICMAJORANA(CLIFF_NUMS, HDIM) creates a random 4-by-4
%   symplectic matrix modulo HDIM, where the symplectic metric is that for
%   the Majorana parafermion states.
%
%   -- CLIFF_NUMS is the list of numbers associate with HDIM which
%   correspond to valid parafermion symplectic matrices. One is chosen at
%   random, and this becomes the symplectic matrix output.
%
%   OUT = SYMPLECTICMAJORANA(CLIFF_NUMS, HDIM, NUMSITES) creates a
%   2*NUMSITES-by-2*NUMSITES matrix, with as many 4-by-4 symplectic
%   matrices on the diagonal as will fit.
%
%   OUT = SYMPLECTICMAJORANA(CLIFF_NUMS, HDIM, NUMSITES, OFFSET) will
%   offset the symplectic matrices. OFFSET must be 0 or 1. If OFFSET is 1,
%   the 4-by-4 symplectic matrices are shifted by one site. This process
%   uses periodic boundary conditions, and so for an even number of sites,
%   there will be connections between the parafermions at site NUMSITES
%   and site 1.
%
%   See also SYMPLECTICMETRICMAJORANA, UNITARYMAJORANABASIC

% [MatrixOut,EvenNumOfSites] = SystemSymplecticMajorana(NumSites,C_Numbers_Hdim,Hdim,Offset)
% MatrixOut is a symplectic matrix which is the direct sum of 4x4 symplectic matrices. Uses periodic boundary conditions.
% EvenNumOfSites is true if NumSites is even, false if NumSites is odd.
% The code can handle an odd NumSites, but expects NumSites to be even. Does not implement periodic boundary conditions for odd NumSites.
% Offset=0 is for odd pairs, (1,2), (3,4), ..., (N-1,N).
% Offset=1 is for even pairs, (2,3), (4,5), ..., (N,1).

    Num_C_Numbers = numel(C_Numbers_Hdim);
    
    if nargin<3
        NumSites = 2;
    end
    if (nargin<4)||(NumSites==1)
        Offset = 0;
    end
    
    NumPairs = floor(NumSites/2);
    
    EvenNumOfSites = (NumPairs==NumSites/2);
    %   This will return false if there are an odd number of sites.
    
    Out = speye(2*NumSites);
    
    if (Offset~=0)&&(Offset~=1)
        ErrStrc = struct('message','Offset must be either 1 or 0.','identifier','SymplecticMajorana:InvalidOffset');
        error(ErrStrc)
    end
    
    for PairIndex = 0:NumPairs-1
        RandNum = randi([1,Num_C_Numbers]);
        SymplecticLocal = CNumToMajSymplectic(C_Numbers_Hdim(RandNum),Hdim);
        ColumnIndex = 4*PairIndex;
        Out(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = SymplecticLocal;
    end
    
    PairIndex = NumPairs-1;
    RandNum = randi([1,Num_C_Numbers]);
    if (Offset==1)&&(EvenNumOfSites)
            % This Symplectic matrix will wrap around the system, connecting i=N and i=1.
            % We negate half of the matrix to account for the change in the metric as we wrap around the system.
        SymplecticLocal = mod(-diag([-1,-1,1,1])*CNumToMajSymplectic(C_Numbers_Hdim(RandNum),Hdim)*diag([1,1,-1,-1]),Hdim);
    else
        SymplecticLocal = CNumToMajSymplectic(C_Numbers_Hdim(RandNum),Hdim);
    end
    ColumnIndex = 4*PairIndex;
    Out(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = SymplecticLocal;
    
    Out = circshift(circshift(Out,2*Offset,1),2*Offset,2);

end