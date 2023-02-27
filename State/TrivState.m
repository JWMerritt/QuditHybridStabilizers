function Out = TrivState(L)
%creates generator for trivial product state in C' representation
Out = zeros(L,2*L);
%   I would love for this to be of type 'single', but then we can't multiply it together with sparse matrices.
for ii=1:L
    Out(ii,2*ii-1:2*ii)=[1,-1];
end
end