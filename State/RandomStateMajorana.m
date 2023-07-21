function StateOut = RandomStateMajorana(NumSites,C_Numbers_Int,Hdim,CircuitDepth)
%RANDOMSTATEMAJORANA  Generate a random parafermionic stabilizer state.
%
%   OUT = RANDOMSTATEMAJORANA(NUM_SITES, CLIFF_NUMS HDIM) creates a random
%   parafermion state. This is done by applying NUM_SITES/2 layers of the
%   basic Majorana unitary operation to all sites, starting with an initial
%   trivial Majorana state. The state should become maximally mixed before
%   NUM_SITES/2 time steps have occurred.
%
%   -- CLIFF_NUMS is the list of numbers which will generate the symplectic
%   (Clifford) matrices corresponding to HDIM.
%
%   OUT = RANDOMESTATEMAJORANA(NUM_SITES, CLIFF_NUMS, HDIM, DEPTH) applies
%   a number of unitary layers equal to DEPTH.
%
%   See also TRIVSTATEMAJORANA, UNITARYMAJORANABASIC

    if nargin<4
        CircuitDepth = floor(NumSites/2);
    end
    
    StateOut = TrivStateMajorana(NumSites);
    
    for IterativeCircuitIndex = 1:CircuitDepth
        StateOut = UnitaryMajoranaBasic(StateOut,2*NumSites,C_Numbers_Int,Hdim,struct(),0);
        StateOut = UnitaryMajoranaBasic(StateOut,2*NumSites,C_Numbers_Int,Hdim,struct(),1);
    end

end