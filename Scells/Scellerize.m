function Out = Scellerize(In)
%changes Struct into a cell array, with a struct for each phase point.

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

end