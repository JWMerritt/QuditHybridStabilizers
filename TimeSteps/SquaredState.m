function Psi = SquaredState(SystemSize,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric)
%   Makes a trivial state with [SystemSize] sites, and evolves it by [SystemSize] timesteps.

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