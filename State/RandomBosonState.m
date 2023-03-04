function Out = RandomBosonState(NumSites,Hdim,CircuitDepth)
%   Uses GetSystemSymplectic in a brick pattern to get a random state.

if nargin<4
    CircuitDepth = floor(NumSites/2);
end

Out = TrivState(NumSites);
Out(Out==-1)=0;

for IterativeCircuitIndex = 1:CircuitDepth
    Out = BosonUnitary(Out,2*NumSites,false,Hdim,false,0);
    Out = BosonUnitary(Out,2*NumSites,false,Hdim,false,1);
end



end