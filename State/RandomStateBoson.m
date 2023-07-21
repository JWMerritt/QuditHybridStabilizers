function StateOut = RandomStateBoson(NumSites,Hdim,CircuitDepth)
%RANDOMSTATEBOSON  Generate a random bosonic stabilizer state.
%
%   OUT = RANDOMSTATEBOSON(NUM_SITES, HDIM) creates a random boson state.
%   This is done by applying NUM_SITES/2 layers of the basic bosonic
%   unitary operation to all sites, starting with an initial trivial
%   bosonic state. The state should become maximally mixed before
%   NUM_SITES/2 time steps have occurred.
%
%   OUT = RANDOMESTATEBOSON(NUM_SITES, HDIM, DEPTH) applies a number of
%   unitary layers equal to DEPTH.
%
%   See also TRIVSTATEBOSON, UNITARYBOSONBASIC

    if nargin<3
        CircuitDepth = floor(NumSites/2);
        % Generally, the state becomes maximally mixed before NumSites/2 time steps have been applied
    end
    
    StateOut = TrivStateBoson(NumSites);
    
    for IterativeCircuitIndex = 1:CircuitDepth
        StateOut = UnitaryBosonBasic(StateOut,2*NumSites,[],Hdim,struct(),0);
        StateOut = UnitaryBosonBasic(StateOut,2*NumSites,[],Hdim,struct(),1);
    end

end