function StateOut = RandomStateBoson(NumSites,Hdim,CircuitDepth)
% SystemOut = RandomStateBoson(NumSites,Hdim,CircuitDepth)
% Applies a number CircuitDepth of unitary time steps (of UnitaryBoson type) to the trivial boson state (given by TrivStateBoson).

if nargin<3
    CircuitDepth = floor(NumSites/2);
    % Generally, the state becomes maximally mixed before NumSites/2 time steps have been applied
end

StateOut = TrivStateBoson(NumSites);

for IterativeCircuitIndex = 1:CircuitDepth
    StateOut = UnitaryBoson(StateOut,2*NumSites,false,Hdim,false,0);
    StateOut = UnitaryBoson(StateOut,2*NumSites,false,Hdim,false,1);
end



end