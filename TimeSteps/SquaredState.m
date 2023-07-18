function Psi = SquaredState(SystemSize,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric)
%SQUAREDSTATE  Make a trivial state and evolve for a number of times equal to the system size.
%
%   Psi = SQUAREDSTATE(SystemSize,C_Numbers,Hdim,UnitaryFunc,RunOption,S_Metric) makes a trivial state with (SystemSize) sites, and evolves it by (SystemSize) timesteps.
%   -- C_Numbers_Int is the list of numbers corresonding to (symplectic) Clifford matrices for the corresponding value of Hdim.
%   -- Hdim is the on-site Hilbert space dimension (number of qudit states).
%   -- UnitaryFunc is the unitary function to apply during each time step.
%   -- RunOptions is the struct containing the details of the evolution applied.
%   -- S_Metric is the symplectic metric corrsponding to the system.
%       
%   See also UNITARYBOSONBASIC, SYSTEMSYMPLECTICBOSON


try
    IsPure = RunOptions.PureState;
catch
    IsPure = true;
end

if IsPure
    Psi = TrivState(SystemSize);
    NumGenerators = SystemSize;
else
    Psi = zeros(SystemSize,2*SystemSize);
    NumGenerators = 0;
end

if nargin<=5
    S_Metric = SMetric(2*SystemSize);
end

for Time = 1:SystemSize
    Psi = TimeStep(Psi,NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric);
end

%{
S_Subsystem = zeros(floor(SystemSize/2),1);
Bigs = Bigrams(Psi,NumGenerators);

for IterativeLength = 1:floor(SystemSize/2)
    S_Subsystem(IterativeLength) = EntropyOfRegionSize(Bigs,SystemSize,IterativeLength);
end

S_Mixed = SystemSize - NumGenerators;
%}

end