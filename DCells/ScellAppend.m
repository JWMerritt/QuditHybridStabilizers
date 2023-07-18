function Scell = ScellAppend(Scell,App)
%append App to Scell, even if Scell is empty = {}

if numel(Scell)==0
    if isstruct(App)
        Scell = Scellerize(App);
    elseif iscell(App)
        Scell = App;
    else
        fprintf('\nError: needs Scell or struct inputs\n')
        return
    end
else
    if isstruct(App)
        Scell = ScellOrder(ScellCombine(Scell,Scellerize(App)));
    elseif iscell(App)
        Scell = ScellOrder(ScellCombine(Scell,App));
    else
        fprintf('\nError: needs Scell or struct inputs.\n')
    end
end

end