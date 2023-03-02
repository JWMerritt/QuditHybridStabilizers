function [N,p,q,t,Out,reals,sig,roughLimits] = ScellPullData(Scell,arg,roughLimit)
%sig is std deviation; roughLimits is the number of times data was thrown due to being over the roughLimit

if nargin<=2
	roughLimit = inf;
	if nargin<=1
		arg = 'S';
	end
end


if ~iscell(Scell)
    if isstruct(Scell)
        fprintf('ERROR: Input is struct. Remember to Scellerize inputs.\n')
        return
    else
        fprintf('ERROR: Expecting input to be cell array.\n')
    end
end

N=[];
p=[];
q=[];
t=[];
Out=[];
sig=[];
reals=[];
roughLimits = [];


for ii=1:numel(Scell)
    eval(['Current = Scell{ii}.',arg,';'])   %should give us the cell array we're looking for
    N(ii)=Scell{ii}.N;
    p(ii)=Scell{ii}.p;
    q(ii)=Scell{ii}.q;
    t(ii)=Scell{ii}.t;
    holdReals = 0;
    holdArg = 0;
    entries = numel(Current); 	%note: replace this loop with cell2mat() & sum() in the future...
    for jj=1:entries
        holdArg(jj) = Current{jj};
        if numel(Scell{ii}.reals)~=0
            holdReals(jj) = Scell{ii}.reals{jj};
        end
    end
	keptOnes = holdArg<roughLimit;
	finalArg = holdArg(keptOnes);
	finalReals = holdReals(keptOnes);
	roughLimits(ii) = entries - sum(keptOnes);
    Out(ii) = sum(finalArg)/numel(finalArg);
    if numel(Scell{ii}.reals)~=0
        reals(ii) = sum(finalReals);
    end
    holdVar = [];
    for jj=1:numel(finalArg)
        holdVar(jj) = (Out(ii)-finalArg(jj))^2;
    end
    sig(ii) = sqrt(sum(holdVar)/(numel(finalArg)-1));        
end

end

%03/Feb/21 - Added catch conditions for when I accidentally just put the
%   struct into the function. Also changed the name from Scell_pull_data to
%   ScellPullData
%07/Feb/21 - Added measurement standard deviation (sig) to list of
%   calculations.