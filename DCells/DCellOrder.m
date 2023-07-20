function Out = DCellOrder(In)
%DCELLORDER  Order the contents of the DCell by independent variable.
%
%   Out = DCellOrder(In) orders the entries of In by increasing value of
%   the independent variables, in the following order of significance:
%       SystemSize
%       ProbabilityValue
%       InteractingProbability

Out={};
SystemSizeValues=[];
MeasurementProbabilityValues=[];
InteractingProbabilityValues=[];
TotalTimeSteps=[];

% First, get a list of all the values and order them.
for i=1:numel(In)
    SystemSizeValues(i) = In{i}.SystemSize;
    MeasurementProbabilityValues(i) = In{i}.MeasurementProbability;
    InteractingProbabilityValues(i) = In{i}.InteractingProbability;
    TotalTimeSteps(i) = In{i}.TotalTimeSteps;
end

NVals = unique(SystemSizeValues,'sorted');
pVals = unique(MeasurementProbabilityValues,'sorted');
qVals = unique(InteractingProbabilityValues,'sorted');
tVals = unique(TotalTimeSteps,'sorted');

Nnum = numel(NVals);
pnum = numel(pVals);
qnum = numel(qVals);
tnum = numel(tVals);

%   If we assume no duplicates, then every entry in In has a unique
%   set of (N,p,q,t) coordinates, and each (N,p,q,t) only refers to
%   one entry.

for i=1:Nnum
for j=1:pnum
for k=1:qnum
for l=1:tnum
    if sum((SystemSizeValues==NVals(i))...
            &(MeasurementProbabilityValues==pVals(j))...
            &(InteractingProbabilityValues==qVals(k))...
            &(TotalTimeSteps==tVals(l)))==1
        Out{end+1} = In{(SystemSizeValues==NVals(i))...
            &(MeasurementProbabilityValues==pVals(j))...
            &(InteractingProbabilityValues==qVals(k))...
            &(TotalTimeSteps==tVals(l))};
    elseif sum((SystemSizeValues==NVals(i))...
            &(MeasurementProbabilityValues==pVals(j))...
            &(InteractingProbabilityValues==qVals(k))...
            &(TotalTimeSteps==tVals(l)))>1
        ErMsg = sprintf(['More than one entry detected for (SS,MP,IP) = (%0.0f,%0.4f,%0.4f).\n'...
            'Use A = DCellCombine({},A) to combine duplicate entries.'],NVals(i),pVals(j),qVals(k));
            % this sprintf is for including the newline character in the error message.
        ErSrct = struct('message',ErMsg,'identifier','DCellOrder:DuplicateEntries');
        Out = In1;  % This is so the error doesn't overwrite a good DCell with incomplete data.
        error(ErSrct)
    end
end
end
end
end


end