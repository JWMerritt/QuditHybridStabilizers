function Out = Scellerize(In)
%changes Struct into a cell array, with a struct for each phase point.

EntryStruct = struct('SystemSize',[],'MeasurementProbability',[],'InteractingProbability',[],'TotalTimeSteps',[],'LengthDistribution',cell(1),'SubsystemEntropy',cell(1),'PurificationEntropy',cell(1),'Realizations',cell(1));
Out = {};
skip = false;

for ii=1:numel(In)
    skip = false;
        %now, we check if In(ii) actually has any data
    if numel(In(ii).SystemSize)==0
        skip = true;
    end
    if ~isequal(class(In(ii).SubsystemEntropy),'cell')  %mostly here in case ns=[] instead of ns={[]}
        skip = true;
    elseif numel(In(ii).SubsystemEntropy{1})==0
        skip = true;
    end
    if isfield(In,'LengthDistribution')
        if ~isequal(class(In(ii).LengthDistribution),'cell')
            skip = true;
        elseif numel(In(ii).LengthDistribution{1})==0
            skip = true;
        end
    end
    if ~skip        %just place entries into the cell, no duplicate-checking
        Out{numel(Out)+1} = EntryStruct;
        Os = numel(Out);
        Out{Os}.SystemSize = In(ii).SystemSize;
        Out{Os}.MeasurementProbability = In(ii).MeasurementProbability;
        Out{Os}.InteractingProbability = In(ii).InteractingProbability;
        Out{Os}.SubsystemEntropy = In(ii).SubsystemEntropy;
        if isfield(In,'TotalTimeSteps')
            Out{Os}.TotalTimeSteps = In(ii).TotalTimeSteps;
        else
            Out{Os}.TotalTimeSteps = [];
        end
        if isfield(In,'LengthDistribution')
            Out{Os}.LengthDistribution = In(ii).LengthDistribution;
        else
            Out{Os}.LengthDistribution = {};
        end
        if isfield(In,'PurificationEntropy')
            Out{Os}.PurificationEntropy = In(ii).PurificationEntropy;
        else
            Out{Os}.PurificationEntropy = {};
        end
        if isfield(In,'Realizations')
            Out{Os}.Realizations = In(ii).Realizations;
        else
            Out{Os}.Realizations = {};
        end
    end
end



%{

%%%% OLD_DATA

EntryStruct = struct('N',[],'p',[],'q',[],'t',[],'S',cell(1),'ns',cell(1),'reals',cell(1));
Out = {};
skip = false;

for i=1:numel(In)
    skip = false;
        %now, we check if In(i) actually has any data
    if numel(In(i).N)==0
        skip = true;
    end
    if ~isequal(class(In(i).ns),'cell')  %mostly here in case ns=[] instead of ns={[]}
        skip = true;
    elseif numel(In(i).ns{1})==0
        skip = true;
    end
    if isfield(In,'S')
        if ~isequal(class(In(i).S),'cell')
            skip = true;
        elseif numel(In(i).S{1})==0
            skip = true;
        end
    end
    if ~skip        %just place entries into the cell, no duplicate-checking
        Out{numel(Out)+1} = EntryStruct;
        Os = numel(Out);
        Out{Os}.N = In(i).N;
        Out{Os}.p = In(i).p;
        Out{Os}.q = In(i).q;
        Out{Os}.ns = In(i).ns;
        if isfield(In,'t')
            Out{Os}.t = In(i).t;
        else
            Out{Os}.t = [];
        end
        if isfield(In,'S')
            Out{Os}.S = In(i).S;
        else
            Out{Os}.S = {};
        end
        if isfield(In,'reals')
            Out{Os}.reals = In(i).reals;
        else
            Out{Os}.reals = {};
        end
    end
end
%}

end