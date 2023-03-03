function Out = RandomState(NumSites,C_Numbers_Int,Hdim,CircuitDepth)
%   Uses GetSystemSymplectic in a brick pattern to get a random state.

if nargin<4
    CircuitDepth = floor(NumSites/2);
end

Out = TrivState(NumSites);

for IterativeCircuitIndex = 1:CircuitDepth
    Out = mod(Out*GetSystemSymplectic(2*NumSites,C_Numbers_Int,Hdim,0),Hdim);
    Out = mod(Out*GetSystemSymplectic(2*NumSites,C_Numbers_Int,Hdim,1),Hdim);
end

Out = mod(Out,Hdim);

end