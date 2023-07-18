function Augend = DCellAppend(Augend,Addend)
%DCELLAPPEND  Append one DCell to another
%   A = DCELLAPPEND(A,B) appends DCell or struct B to DCell A.
%   A = DCELLAPPEND({},B) converts struct B to DCell and then orders the entries.

if numel(Augend)==0
    if isstruct(Addend)
        Augend = DCellConvert(Addend);
    elseif iscell(Addend)
        Augend = Addend;
    else
        ErrorStruct = struct('message','Inputs must be DCells or structs.','identifier','DCellAppend:IncorrectInputFormat');
        error(ErrorStruct)
    end
else
    if isstruct(Addend)
        Augend = DCellOrder(DCellCombine(Augend,DCellConvert(Addend)));
    elseif iscell(Addend)
        Augend = DCellOrder(DCellCombine(Augend,Addend));
    else
        ErrorStruct = struct('message','Inputs must be DCells or structs.','identifier','DCellAppend:IncorrectInputFormat');
        error(ErrorStruct)
    end
end

end