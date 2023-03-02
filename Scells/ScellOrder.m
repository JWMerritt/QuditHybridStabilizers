function Out = ScellOrder(Scell)
%orders the contents of Scell by (N,p,q,t)

Out={};
N=[];
p=[];
q=[];
t=[];
for i=1:numel(Scell)
    N(i) = Scell{i}.N;
    p(i) = Scell{i}.p;
    q(i) = Scell{i}.q;
    t(i) = Scell{i}.t;
end

NVals = unique(N,'sorted');
pVals = unique(p,'sorted');
qVals = unique(q,'sorted');
tVals = unique(t,'sorted');

Nnum = numel(NVals);
pnum = numel(pVals);
qnum = numel(qVals);
tnum = numel(tVals);
        %if we assume no duplicates, then every entry in Scell has a unique
        %set of (N,p,q,t) coordinates, and each (N,p,q,t) only refers to
        %one entry.


for i=1:Nnum
for j=1:pnum
for k=1:qnum
for l=1:tnum
    %Scell{(N==NVals(i))&(p==pVals(j))&(q==qVals(k))&(t==tVals(l))}
    %apparently, this doesn't give an empty cell when we don't find an 
    %element, this is just empty. weird...
    if sum((N==NVals(i))&(p==pVals(j))&(q==qVals(k))&(t==tVals(l)))==1
        Out{numel(Out)+1} = Scell{(N==NVals(i))&(p==pVals(j))&(q==qVals(k))&(t==tVals(l))};
    elseif sum((N==NVals(i))&(p==pVals(j))&(q==qVals(k))&(t==tVals(l)))>1
        fprintf('error, more than one entry detected for (N,p,q) = (%d,%d,%d)',NVals(i),pVals(j),qVals(k));
    end
end
end
end
end


end