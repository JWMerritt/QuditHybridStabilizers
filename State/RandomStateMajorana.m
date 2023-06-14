function StateOut = RandomStateMajorana(NumSites,C_Numbers_Int,Hdim,CircuitDepth)
% SystemOut = RandomStateMajorana(NumSites,Hdim,CircuitDepth)
% Applies a number CircuitDepth of unitary time steps (of UnitaryBoson type) to the trivial boson state (given by TrivStateBoson).

if nargin<4
    CircuitDepth = floor(NumSites/2);
end

StateOut = TrivState(NumSites);

for IterativeCircuitIndex = 1:CircuitDepth
    StateOut = mod(StateOut*GetSystemSymplectic(2*NumSites,C_Numbers_Int,Hdim,0),Hdim);
    StateOut = mod(StateOut*GetSystemSymplectic(2*NumSites,C_Numbers_Int,Hdim,1),Hdim);
end

StateOut = mod(StateOut,Hdim);

end