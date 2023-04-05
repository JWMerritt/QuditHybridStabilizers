function [Psi,NumGenerators] = MeasureBoson(Psi,NumGenerators,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
    %   Gives the generating set for the collapsed state, after a Z=(0,1) measurement, where i=ColumnIndex.
    
    if nargin<=7
        [NumRows,NumColumns] = size(Psi);
        S_Metric = SMetricBoson(NumRows);
    end
    
    %{
        Pseudocode:
            Run down the generators, until you find one that has nontrivial commutation with the projective operator.
                If none have nontrivial commutation, add the projective operator to the end of the list, NumGenerators++
            Find the inverse, and multiply that generator by that number (this multiplies the generator by itself that many times). Call it the Replaceable generator.
                We'll also work with the negation of the generator, equivalent to taking the hermitian conjugate, up to an overall factor.
            Then, for the rest of the generators, when we find some nontrivial commutation,
            then add to that generator the Replaceable generator, multiplied by the factor that will force commutation.
                This gives us an independent generator that commutes with the projective operator.
            Once we've run out of generators, replace the Replaceable generator with the projective operator.
        
        There's some understanding that the state needs to be clipped first? Hopefully I'll remember what that's about...

        Advanced Pseudocode:
            Take the inner produce of Psi with MeasureGenerator. This gives you a column vector, which is the list of inner products of all generators with MeasureGenerator
                Run down this list, until you find one that has nontrivial commutation with the projective operator.
                If the list is all zero, add the projective operator to the end of the list (if NumGenerators<NumRows), NumGenerators++
            Find the inverse, and multiply that generator by that number (this multiplies the generator by itself that many times). Call it the Replaceable generator.
                We'll also work with the negation of the generator, equivalent to taking the hermitian conjugate, up to an overall factor.
            Then, for the rest of the nonzero list entries,
    %}
    
    
    %InProd = @(a,b) mod(a*S_Metric*b',Hdim);
    
    MeasureGenerator = zeros(1,NumColumns);
    MeasureGenerator([ColumnIndex,(ColumnIndex~=NumColumns)*ColumnIndex+1]) = mod([0,1],Hdim);
    %   This represents the operator \gamma_{i} \gamma_{i+1}^\dagger
    %   The logic in the second entry of the indexing is so that if ColumnIndex is the last column, the pair wraps around the system,
    %     and we have \gamma_{L} \gamma_{1}^\dagger.
    %   For bosons, this code isn't relevant, since we should only choose ColumnIndex to be an odd number
    

    %   Get list of inner products
    Commutants = mod(Psi*S_Metric*MeasureGenerator',Hdim);
    %   This gives zeroes for the sites that commute with the MeasureGenerator.
    NonzeroCommutants = find(Commutants);

    if numel(NonzeroCommutants)==0
        % Then the state is already an eigenstate of this measurement operator.
 
        if NumGenerators<NumRows
            % And we have a mixed state
            % If our state is not already an eigenstate of MeasureGenerator 
            %   (i.e. MeasureGenerator is not in our stabilizer group <=> MeasureGenerator is not in the rowspace of Psi)
            %   then MeasureGenerator becomes a new generator of our state

            Psi(NumGenerators+1,:) = MeasureGenerator;
                %   We now need to check if the new MeasureGenerator is already a known stabilizer
            CheckRows = sum(RowReduceMod(Psi(1:(NumGenerators+1),:),Hdim)');
                %   If MeasureGenerator is dependent on what's already there, then there will be a zero row in our reduced matrix.
                %   CheckRows is just the sum of all entries in each row; since this is already mod Hdim, there will be no negative numbers,
                %       and CheckRows(ii) will only be zero if row ii is zero.
                %   Note that we're not actually changing Psi here
            if numel(find(CheckRows==0))==0
                %   No zero rows - MeasureGenerator is independent
                NumGenerators = NumGenerators + 1;
            else
                %   Zero rows - MeasureGenerator is not independent
                Psi(NumGenerators+1,:) = zeros(1,NumColumns);
            end

            return

        end
            % If NumGenerators=NumRows, then we do nothing - the state is already an eigenstate.

    else % There is a nonzero commutant

        %   Get the generator that we'll use to make all the others commute
        ReplaceableGenerator = mod( ModInverse( Commutants(NonzeroCommutants(1)) ,Hdim) * Psi(NonzeroCommutants(1),:),Hdim );
        %   This should have SProd(ReplaceableGenerator,MeasurementGenerator) = 1

        Psi(NonzeroCommutants,:) = mod( Psi(NonzeroCommutants,:) - Commutants(NonzeroCommutants)*ReplaceableGenerator ,Hdim);
        %   This forces Psi(ii,:) to commute with MeasureGenerator.
        %   This will also make the ReplaceableGenerator row become all zeroes, but that's okay since we'll replace it later.

        %   At this point, we should have an equivalent generating set, with only ReplaceableGenerator not commuting with MeasureGenerator.
        %   Now, we just replace the ReplaceableGenerator with the MeasureGenerator

        Psi(NonzeroCommutants(1),:) = MeasureGenerator;
        %!!?!???!?!???!?!?!?

    end
    
end