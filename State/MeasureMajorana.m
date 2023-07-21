function [Psi,NumGenerators] = MeasureMajorana(Psi,NumGenerators,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
%MEASUREMAJORANA  Project state onto the eigenspace of a pair of Majorana
%operators.
%
%   [PSI, NUM_GEN] = MEASUREMAJORANA(PSI, NUM_GEN, COL_IDX, HDIM) takes the
%   check-matrix PSI and performs a projective measurement of the operator
%   $\gamma_i \gamma_{i+1}^\dag$, where i=COL_IDX. 
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
%   column of measurement, not the physical site. If COL_IDX = 2j is an
%   even integer, then the measurement is of parefrmion parity at site j.
%   If COL_IDX = 2j-1, then the measurement is of Majorana operators
%   between sites.
%
%   -- HDIM is a prime integer which is equal to the order of the Majorana
%   parafermions.
%
%   [PSI, NUM_GEN] = MEASUREMAJORANA(PSI, NUM_GEN, COL_IDX, HDIM, NUM_ROWS,
%   NUM_COLS, S_METRIC) explicitly takes in the number of rows and columns
%   of PSI (NUM_ROWS and NUM_COLS), as well as the relevant symplectic
%   matrix (S_METRIC). This is so that the metric will not have to be
%   generated from scratch every time.
%
%   See also SYMPLECTICMETRICMAJORANA, TIMESTEPBASIC

    

%   Pseudocode:
% 
%       Run down the generators, until you find one that has nontrivial
%         commutation with the operator we're measuring.
% 
%           If none have nontrivial commutation, add the operator to the
%           end of the list, NumGenerators++. If the state is pure, do
%           nothing.
% 
%       Find the inverse of the commutation result, and multiply that
%       generator by this inverse (in terms of operators, this multiplies
%       the generator by itself that many times). Call it the Replaceable
%       generator.
%             
%           We'll also work with the negation of the numbers, equivalent to
%           taking the hermitian conjugate of the operator, up to an
%           overall factor.
% 
%       Then, for the rest of the generators, when we find some nontrivial
%       commutation, then add to that generator the Replaceable generator,
%       multiplied by the factor such that the sum will commute.
%           
%           This gives us an independent generator that commutes with the
%           measured operator.
% 
%       Once we've run out of generators, replace the Replaceable generator
%       with the measured operator.
% 
%     There's some understanding that the state needs to be clipped first?
%     Hopefully I'll remember what that's about...
% 
%     Advanced Pseudocode:
%         Take the inner produce of Psi with MeasureGenerator. This gives you a column vector, which is the list of inner products of all generators with MeasureGenerator
%             Run down this list, until you find one that has nontrivial commutation with the projective operator.
%             If the list is all zero, add the projective operator to the end of the list (if NumGenerators<NumRows), NumGenerators++
%         Find the inverse, and multiply that generator by that number (this multiplies the generator by itself that many times). Call it the Replaceable generator.
%             We'll also work with the negation of the generator, equivalent to taking the hermitian conjugate, up to an overall factor.
%         Then, for the rest of the nonzero list entries,
% 

    
    if nargin<=4
        [NumRows,NumColumns] = size(Psi);
        S_Metric = SymplecticMetricMajorana(NumRows);
    end
    
    MeasureOperator = mod([1,-1],Hdim);
        % This corresponds to the generator we're going to measure in the system.
        % For fermions, this corresopnds to $\gamma_i \gamma_{i+1}^\dag$.
        % Generally, [a,b] -> (\gamma_i)^a (\gamma_{i+1})^b.

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