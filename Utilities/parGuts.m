function [Current_State,par_NumGenerators,localTemp] = parGuts(par_SystemSize,par_TotalTimeSteps,RunOptions,IsPure,C_Numbers_Int,Hdim,UnitaryFunc,EvolFunc,par_RealizationsBeforeSaving,S_Metric)

    localTemp = {}
    for kk = 1:abs(par_RealizationsBeforeSaving)

        if IsPure
            Current_State = TrivState(par_SystemSize);
            par_NumGenerators = par_SystemSize;
        else
            Current_State = zeros(par_SystemSize,2*par_SystemSize);
            par_NumGenerators = 0;
        end

        for jj=1:par_TotalTimeSteps
            fprintf('...sumsum = %d, NumGenerators = %d\n',sum(sum(abs(Current_State))),par_NumGenerators)
            [Current_State,par_NumGenerators] = EvolFunc(Current_State,par_NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric);
        end

        try
            par_Bigram = Bigrams(Current_State,par_NumGenerators)
            localTemp{kk,1} = LengthDistribution(par_Bigram,par_SystemSize)		% Length Distributions
            localTemp{kk,2} = EntropyOfAllRegionSizes(par_Bigram,par_SystemSize)	% Subsystem entropy
            localTemp{kk,3} = par_SystemSize - par_NumGenerators					% Purification entropy
        catch ErStr
            fprintf('Error!')
            return
        end
    end


end