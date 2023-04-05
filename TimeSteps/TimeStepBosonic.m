function  [Psi,NumGenerators] = TimeStepBosonic(Psi,NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric)
%   Applies one time step, with periodic BC, alternating each step.
%   Measurements follow the pairings of the unitaries just applied.
%
%   Requires: RunOptions.MeasurementProbability
%   Expects an Lx2L check-matrix, with an even number of sites L.
%   Fermion specific, as measurements can happen between sites


[NumRows,NumColumns] = size(Psi);
if NumColumns~=2*NumRows
    fprintf("Error in TimeStep(): Input state not correct size.\n")
    fprintf(' - Input size: [%d, %d]. Needs to be [L, 2L].\n', NumRows, NumColumns)
    %Out = [];
    return
end

NumPairs = NumRows/2;

if floor(NumPairs)~=NumPairs
    fprintf("Error in TimeStep(): We can only handle systems withan even number of sites.")
    %Out = [];
    return
end

if nargin<=5
    S_Metric = SMetricBoson(NumColumns);
end

NumSites = NumRows;
%   Just here for code readability
%   NumSites = NumColumns/2 = NumRows

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

%fprintf('-%d-',numel(MeasurementSites));

for IterativeColumnIndex=MeasurementSites
    [Psi,NumGenerators] = MeasureBoson(Psi,NumGenerators,IterativeColumnIndex,Hdim,NumRows,NumColumns,S_Metric);
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
        MeasurementSites = [MeasurementSites,2*IterativeSiteIndex-1];
        %   Only allows (2k-1,2k) measurement pairs.
        %   We don't do cross-site measurements for bosons, only measurements of Z ~ (0,1)
    end
end

%fprintf('-%d-',numel(MeasurementSites));

for IterativeColumnIndex=MeasurementSites
    [Psi,NumGenerators] = MeasureBoson(Psi,NumGenerators,IterativeColumnIndex,Hdim,NumRows,NumColumns,S_Metric);
    %   has inputs Measure(Psi,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
end

% and that should be all!


end

