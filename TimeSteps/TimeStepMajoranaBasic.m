function  [Psi, NumGenerators] = TimeStepMajoranaBasic(Psi, NumGenerators, C_Numbers_Hdim, Hdim, UnitaryFunc, RunOptions, S_Metric)
%TIMESTEPMAJORANABASIC  Apply a time step to a system.
%
%   [PSI, NUM_GENS] = TIMESTEPMAJORANABASIC(PSI, NUM_GENS, CLIFF_NUMS,
%   HDIM, UFUNC, RUNOPTIONS, S_METRIC) applies one time step to Psi using
%   periodic (closed) boundary conditions and returns the resulting state.
%
%   -- PSI is an N-by-2N check-matrix, with an even number of sites N.
%
%   -- NUM_GENS is the number of nonzero generators in PSI.
%
%   -- CLIFF_NUMS is the list of numbers corresonding to (symplectic)
%   Clifford matrices for the corresponding value of Hdim.
%
%   -- HDIM is the Majorana parafermion order.
%
%   -- UFUNC is the unitary function to apply during each time step.
%
%   -- RUNOPTIONS is the struct containing the details of the evolution applied.
%
%   -- S_METRIC is the symplectic metric corrsponding to the system.
%
%   Applies one time step, with periodic boundary conditions. Applies two
%   layers of unitaries and measurements, with alternate pairings for the
%   distinct layers. Measurements are in line with the pairings of the
%   unitaries applied immediately before them. E.g., unitary gates and then
%   measurements on (1,2), (3,4), ... then on (2,3), (4,5), ...
%
%   Requires: RUNOPTIONS.MeasurementProbability -- This number must be
%   between 0 and 1 inclusive, and determines the probability of a
%   measurment occuring at each pairing for each layer.

    [NumRows,NumColumns] = size(Psi);
    if NumColumns~=2*NumRows
        ErrMsg = sprintf('Input state not correct size. - Input size: (%d, %d). Needs to be (N, 2N).\n', NumRows, NumColumns);
        ErrStrc = struct('message',ErrMsg,'identifier','TimeStepMajoranaBasic:IncorrectDimensions');
        error(ErrStrc)
    end
    
    NumPairs = NumColumns/4;
    
    if floor(NumPairs)~=NumPairs
        ErrStrc = struct('message','Input state must have an even number of sites (i.e., the number of columns should be divisable by 4).','identifier','TimeStepMajoranaBasic:OddNumOfSites');
        error(ErrStrc)
    end
    
    if nargin<=5
        S_Metric = SymplecticMetricMajorana(NumColumns/2);
    end
    
    NumSites = NumRows;
    %   Just here for code readability
    
    Num_C_Numbers = numel(C_Numbers_Hdim);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   First, the odd pairings: (1,2), (3,4), etc.
    
    %   Unitaries: %%%%%%%%%%%%%%
    
    Psi = UnitaryFunc(Psi,NumColumns,C_Numbers_Hdim,Hdim,RunOptions,0);
    
    %   Measurement: %%%%%%%%%%%
    
    MeasurementSites = [];
    
    for site_idx=1:NumSites
        if rand<=RunOptions.MeasurementProbability
            MeasurementSites = [MeasurementSites,2*site_idx-1];
            %   Only allows (2k-1,2k) measurement pairs.
        end
    end
    
    for site_idx=MeasurementSites
        [Psi,NumGenerators] = Measure(Psi,NumGenerators,site_idx,Hdim,NumRows,NumColumns,S_Metric);
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Second, the even pairings: (L,1), (2,3), (4,5), etc.
    
    %   Unitaries: %%%%%%%%%%%%%%
    
    Psi = UnitaryFunc(Psi,NumColumns,C_Numbers_Hdim,Hdim,RunOptions,1);
    
    %   Measurement: %%%%%%%%%%%
    
    MeasurementSites = [];
    
    for site_idx=1:NumSites
        if rand<=RunOptions.MeasurementProbability
            MeasurementSites = [MeasurementSites,2*site_idx];
            %   Only allows (2k,2k+1) measurement pairs.
        end
    end
    
    for site_idx=MeasurementSites
        [Psi,NumGenerators] = Measure(Psi,NumGenerators,site_idx,Hdim,NumRows,NumColumns,S_Metric);
    end

end

