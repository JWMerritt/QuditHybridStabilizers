function [Psi,NumGenerators] = Measure(Psi,NumGenerators,ColumnIndex,Hdim,NumRows,NumColumns,S_Metric)
    %   Gives the generating set for the collapsed state, after a \gamma_i \gamma_{i+1}^\dag measurement, where i=ColumnIndex.
    
    if nargin<=4
        [NumRows,NumColumns] = size(Psi);
        S_Metric = SMetric(NumColumns);
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
    MeasureGenerator([ColumnIndex,(ColumnIndex~=NumColumns)*ColumnIndex+1]) = mod([1,-1],Hdim);
    %   This represents the operator \gamma_{i} \gamma_{i+1}^\dagger
    %   The logic in the second entry of the indexing is so that if ColumnIndex is the last column, the pair wraps around the system,
    %     and we have \gamma_{L} \gamma_{1}^\dagger.
    

    %   Get list of inner products
    Commutants = mod(Psi*S_Metric*MeasureGenerator',Hdim);
    %   This gives zeroes for the sites that commute with the MeasureGenerator.
    NonzeroCommutants = find(Commutants);

    if numel(NonzeroCommutants)==0
        % Then the state is already an eigenstate of this measurement operator.
 
        if NumGenerators<NumRows

            Psi(NumGenerators+1,:) = MeasureGenerator;
                %   We now need to check if the new MeasureGenerator is already a known stabilizer
            CheckRows = sum(RowReduceMod(Psi(1:(NumGenerators+1),:),Hdim)');
                %   If MeasureGenerator is dependent on what's already there, then there will be a zero row in our reduced matrix.
            if numel(find(CheckRows==0))==0
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

        Psi(NonzeroCommutants,:) = mod( Psi(NonzeroCommutants,:) - Commutants(NonzeroCommutants)*ReplaceableGenerator, Hdim );
        %   This forces Psi(ii,:) to commute with MeasureGenerator.
        %   This will also make the ReplaceableGenerator row become all zeroes, but that's okay since we'll replace it later.

        %   At this point, we should have an equivalent generating set, with only ReplaceableGenerator not commuting with MeasureGenerator.
        %   Now, we just replace the ReplaceableGenerator with the MeasureGenerator

        Psi(NonzeroCommutants(1),:) = ReplaceableGenerator;

    end

    %{
    ReplaceableRowIndex = 0;

    for IterativeRowIndex=1:NumGenerators
        Product = InProd(Psi(IterativeRowIndex,:),MeasureGenerator);
        if Product==0
            % do nothing and continue to iterate
        else
            ReplaceableRowIndex = IterativeRowIndex;
            inverse = ModInverse(Product,Hdim);
            ReplaceableGenerator = inverse*Psi(ReplaceableRowIndex,:);
            %   This is now an independent generator such that <ReplaceableGenerator,MeasureGenerator> = +1.
            break
        end
    end
    
    if ReplaceableRowIndex==0
        % Then the state is already an eigenstate of this measurement operator.
        
        if NumGenerators<NumRows
            NumGenerators = NumGenerators + 1;
            Psi(NumGenerators,:) = MeasureGenerator;
        end

    else

        for IterativeRowIndex = ReplaceableRowIndex+1:NumGenerators
            %   We know that the rows above this already commute with MeasureGenerator
            
            Commutant = InProd(Psi(IterativeRowIndex,:),MeasureGenerator);
            if Commutant~=0
                Psi(IterativeRowIndex,:) = mod(Psi(IterativeRowIndex,:) - Commutant*ReplaceableGenerator,Hdim);
                %   This forces In(IterativeRowIndex,:) to commute with MeasureGenerator
            end
        end
        %   At this point, we should have an equivalent generating set, with only ReplaceableGenerator not commuting with MeasureGenerator.
        %   Now, we just replace the ReplaceableGenerator with the MeasureGenerator

        Psi(ReplaceableRowIndex,:) = MeasureGenerator;

    end
    %}
    
    
    end