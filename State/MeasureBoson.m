function [Psi,NumGenerators] = MeasureBoson(Psi,NumGenerators,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
%MEASUREBOSON  Project state onto the eigenspace of Pauli Z
%
%   [PSI, NUM_GEN] = MEASUREBOSON(PSI, NUM_GEN, COL_IDX, HDIM) takes the
%   check-matrix PSI and performs a projective measurement of the
%   generalized Pauli Z operator at the site COL_IDX/2. For boson, COL_IDX
%   should properly be an odd number.
% 
%   Due to the nature of stabilzier states, the result will always have an
%   equal probability for all possible outcomes, unless PSI is already an
%   eigenstate. Further, the mearuement result changes the state only by
%   the overall phase of the generator which will be added to the
%   generating set PSI. Thus, the actual measurement outcome is
%   inconsequential, and the state is simply projected instead of
%   'actually' measured.
%
%   -- PSI is a N-by-2N matrix of integers modulo HDIM. It has NUM_GEN
%   nonzero rows which are linearly independent modulo HDIM.
%
%   -- NUM_GEN is the number of generators of PSI. If NUM_GEN < N, then PSI
%   is a mixed state.
%
%   -- COL_IDX is an integer from 1 to 2N inclusive, and describes the
%   column of measurement, not the physical site. If COL_IDX = 2j-1 is an
%   odd integer, then the measurement is of Pauli Z at site j. If COL_IDX =
%   2j, then the measurement is of Pauli X at site j+1.
%
%   -- HDIM is a prime integer which is equal to the order of the
%   generalized Pauli operators i.e., the hilbert space dimension of the
%   qudits.
%
%   [PSI, NUM_GEN] = MEASUREBOSON(PSI, NUM_GEN, COL_IDX, HDIM, NUM_ROWS,
%   NUM_COLS, S_METRIC) explicitly takes in the number of rows and columns
%   of PSI (i.e., NUM_ROWS and NUM_COLS), as well as the relevant symplectic
%   matrix (S_METRIC). This is so that the metric will not have to be
%   generated from scratch every time.
%
%   See also SYMPLECTICMETRICBOSON, TIMESTEPBASIC
    
%   Pseudocode: See MeasureMajorana.
%   This function should only differ from that function in two places:
%       Using SymplecticMetricBoson instead of SymplecticMetricMajorana in
%       the next lines.
%       Using MeasurementOperator=[0,1] instead of [1,-1].
    

    if nargin<=7
        [NumRows,NumColumns] = size(Psi);
        S_Metric = SymplecticMetricBoson(NumRows);
    end

    MeasureOperator = [0,1];
        % This corresponds to the generator we're going to measure in the system.
        % For bosons, this corresponds to a Pauli Z.
        % [a,b] -> X^a Z^b for an odd ColumnIndex
    
    MeasureGenerator = zeros(1,NumColumns);
    MeasureGenerator([ColumnIndex,(ColumnIndex~=NumColumns)*ColumnIndex+1]) = MeasureOperator;
        % The logic in the second entry of the indexing is so that if ColumnIndex
        % is the last column, the pair wraps around the system.
    

    %   Get list of inner products
    Commutants = mod(Psi*S_Metric*MeasureGenerator',Hdim);
    %   This gives zeroes for the sites that commute with the MeasureGenerator.
    NonzeroCommutants = find(Commutants);

    if numel(NonzeroCommutants)==0
        % Then the state is already an eigenstate of this measurement operator.
 
        if NumGenerators<NumRows

            Psi(NumGenerators+1,:) = MeasureGenerator;
                %   We now need to check if the new MeasureGenerator is already a known stabilizer
            CheckRows = any(RowReduceMod(Psi(1:(NumGenerators+1),:),Hdim),2);
                %   If MeasureGenerator is dependent on what's already there, then there will be a zero row in our reduced matrix.
            if all(CheckRows)
                %   No zero rows - MeasureGenerator is independent
                NumGenerators = NumGenerators + 1;
            else
                Psi(NumGenerators+1,:) = zeros(1,NumColumns);
            end

            return

        end

    else

        %   Get the generator that we'll use to make all the others commute
        ReplaceableGenerator = mod(ModInverse(Commutants(NonzeroCommutants(1)),Hdim)*Psi(NonzeroCommutants(1),:),Hdim);
        %   This should have SProd(ReplaceableGenerator,MeasurementGenerator) = 1

        Psi(NonzeroCommutants,:) = mod( Psi(NonzeroCommutants,:)-Commutants(NonzeroCommutants)*ReplaceableGenerator, Hdim );
        %   This forces Psi(ii,:) to commute with MeasureGenerator.
        %   This will also make the ReplaceableGenerator row become all zeroes, but that's okay since we'll replace it later.

        %   At this point, we should have an equivalent generating set, with only ReplaceableGenerator not commuting with MeasureGenerator.
        %   Now, we just replace the ReplaceableGenerator with the MeasureGenerator

        Psi(NonzeroCommutants(1),:) = MeasureGenerator;

    end
    
end