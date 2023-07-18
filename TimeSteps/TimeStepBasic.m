function  [Psi,NumGenerators] = TimeStepBasic(Psi,NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric)
%TIMESTEPBASIC  Apply a time step to a system.
%
%   [Psi,NumGenerators] = TIMESTEPBASIC(Psi,NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric) applies one time step to Psi using periodic (closed) boundary conditions and returns the resulting state.
%   -- NumGenerators is the number of nonzero generators in Psi.
%   -- C_Numbers_Int is the list of numbers corresonding to (symplectic) Clifford matrices for the corresponding value of Hdim.
%   -- Hdim is the on-site Hilbert space dimension (number of qudit states).
%   -- UnitaryFunc is the unitary function to apply during each time step.
%   -- RunOptions is the struct containing the details of the evolution applied.
%   -- S_Metric is the symplectic metric corrsponding to the system.
%
%   Applies one time step, with periodic boundary conditions. Applies two layers of unitaries and measurements, with alternate pairings for the distinct layers.
%   Measurements are in line with the pairings of the unitaries applied immediately before them.
%   E.g., unitary gates and then measurements on (1,2), (3,4), ... then on (2,3), (4,5), ...
%
%   Requires: RunOptions.MeasurementProbability
%   -- This number must be between 0 and 1 inclusive, and determines the probability of a measurment occuring at each pairing for each layer.
%   Expects Psi to be an Nx2N check-matrix, with an even number of sites N.
%   Fermion specific, as measurements can happen between sites


[NumRows,NumColumns] = size(Psi);
if NumColumns~=2*NumRows
    fprintf("Error in TimeStep(): Input state not correct size.\n")
    fprintf(' - Input size: [%d, %d]. Needs to be [L, 2L].\n', NumRows, NumColumns)
    return
end

NumPairs = NumRows/2;

if floor(NumPairs)~=NumPairs
    fprintf("Error in TimeStep(): We can only handle systems withan even number of sites.")
    return
end

if nargin<=5
    S_Metric = SMetric(NumColumns);
end

NumSites = NumRows;
%   Just here for code readability

Num_C_Numbers = numel(C_Numbers_Int);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   First, the odd pairings: (1,2), (3,4), etc.

%   Unitaries: %%%%%%%%%%%%%%

Psi = UnitaryFunc(Psi,NumColumns,C_Numbers_Int,Hdim,RunOptions,0);

%   Measurement: %%%%%%%%%%%

MeasurementSites = [];

for IterativeSiteIndex=1:NumSites
    if rand<=RunOptions.MeasurementProbability
        MeasurementSites = [MeasurementSites,2*IterativeSiteIndex-1];
        %   Only allows (2k-1,2k) measurement pairs.
    end
end



for IterativeSiteIndex=MeasurementSites
    [Psi,NumGenerators] = Measure(Psi,NumGenerators,IterativeSiteIndex,Hdim,NumRows,NumColumns,S_Metric);
    %   has inputs Measure(Psi,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Second, the even pairings: (L,1), (2,3), (4,5), etc.

%   Unitaries: %%%%%%%%%%%%%%

Psi = UnitaryFunc(Psi,NumColumns,C_Numbers_Int,Hdim,RunOptions,1);

%   Measurement: %%%%%%%%%%%

MeasurementSites = [];

for IterativeSiteIndex=1:NumSites
    if rand<=RunOptions.MeasurementProbability
        MeasurementSites = [MeasurementSites,2*IterativeSiteIndex];
        %   Only allows (2k,2k+1) measurement pairs.
    end
end



for IterativeSiteIndex=MeasurementSites
    [Psi,NumGenerators] = Measure(Psi,NumGenerators,IterativeSiteIndex,Hdim,NumRows,NumColumns,S_Metric);
    %   has inputs Measure(Psi,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
end

end

