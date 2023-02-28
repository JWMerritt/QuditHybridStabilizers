function  [Psi,NumGenerators,Unitary1,Unitary2,Measurements1,Measurements2] = TimeStepBasic(Psi,NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric)
%   Applies one time step, with periodic BC, alternating each step.
%   Measurements follow the pairings of the unitaries just applied.
%
%   Requires: RunOptions.MeasurementProbability
%   Expects an Lx2L check-matrix, with an even number of sites L.

Psi;
[NumRows,NumColumns] = size(Psi);
if NumColumns~=2*NumRows
    fprintf("Error in TimeStep(): Input state not correct size.\n")
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
    S_Metric = SMetric(NumColumns);
end

NumSites = NumRows;
%   Just here for code readability

Num_C_Numbers = numel(C_Numbers_Int);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   First, the odd pairings: (1,2), (3,4), etc.

%   Unitaries: %%%%%%%%%%%%%%

[Psi,Unitary1] = UnitaryFunc(Psi,NumColumns,C_Numbers_Int,Hdim,RunOptions,0);


%   Measurement: %%%%%%%%%%%

MeasurementSites = [];

for IterativeSiteIndex=1:NumSites
    if rand<=RunOptions.MeasurementProbability
        MeasurementSites = [MeasurementSites,2*IterativeSiteIndex-1];
        %   Only allows (2k-1,2k) measurement pairs.
    end
end

Measurements1 = MeasurementSites;

for IterativeSiteIndex=MeasurementSites
    [Psi,NumGenerators] = Measure(Psi,NumGenerators,IterativeSiteIndex,Hdim,NumRows,NumColumns,S_Metric);
    %   has inputs Measure(Psi,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Second, the even pairings: (L,1), (2,3), (4,5), etc.

%   Unitaries: %%%%%%%%%%%%%%

[Psi,Unitary2] = UnitaryFunc(Psi,NumColumns,C_Numbers_Int,Hdim,RunOptions,1);

%   Measurement: %%%%%%%%%%%

MeasurementSites = [];

for IterativeSiteIndex=1:NumSites
    if rand<=RunOptions.MeasurementProbability
        MeasurementSites = [MeasurementSites,2*IterativeSiteIndex];
        %   Only allows (2k,2k+1) measurement pairs.
    end
end

Measurements2=MeasurementSites;

for IterativeSiteIndex=MeasurementSites
    [Psi,NumGenerators] = Measure(Psi,NumGenerators,IterativeSiteIndex,Hdim,NumRows,NumColumns,S_Metric);
    %   has inputs Measure(Psi,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
end

% and that should be all!


end

