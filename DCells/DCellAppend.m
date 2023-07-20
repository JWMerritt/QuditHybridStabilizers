function Augend = DCellAppend(Augend,Addend)
%DCELLAPPEND  Append one DCell to another
%
%   A = DCELLAPPEND(A,B) appends B to DCell A.
%   -- B can be either a DCell or a struct.
%
%   A = DCELLAPPEND({},B) converts struct B to DCell and then orders the entries.
%
%   See DCELLCONVERT

if numel(Augend)==0
    if isstruct(Addend)
        Augend = DCellConvert(Addend);
    elseif iscell(Addend)
        Augend = Addend;
    else
        ErSrct = struct('message','Inputs must be DCells or structs.','identifier','DCellAppend:IncorrectInputFormat');
        error(ErSrct)
    end
else
    if isstruct(Addend)
        Augend = DCellOrder(DCellCombine(Augend,DCellConvert(Addend)));
    elseif iscell(Addend)
        Augend = DCellOrder(DCellCombine(Augend,Addend));
    else
        ErSrct = struct('message','Inputs must be DCells or structs.','identifier','DCellAppend:IncorrectInputFormat');
        error(ErSrct)
    end
end

end