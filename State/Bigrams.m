function Out = Bigrams(In,NumGenerators)
%   Outputs a list of the left and right endpoints of the clipped state [In]
%   !! Assumes [In] is a 2L-by-L matrix of row generators.

if nargin<=1
    [NumGenerators,~] = size(In);
end

Out = zeros(NumGenerators,2,'single');

%fprintf('NumGenerators = %d',NumGenerators)

for IterativeRowIndex=1:NumGenerators
    IndexList = find(In(IterativeRowIndex,:));
    %fprintf('Index=%d, list=[%s]\n',IterativeRowIndex,sprintf('%d,',IndexList(:)))
    Out(IterativeRowIndex,:) = [min(IndexList),max(IndexList)];
end

end