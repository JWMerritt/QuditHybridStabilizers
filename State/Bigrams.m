function Out = Bigrams(In,NumGenerators)
%   Outputs a list of the left and right endpoints of the clipped state [In]
%   !! Assumes [In] is a 2L-by-L matrix of row generators.

if nargin<=1
    [NumGenerators,~] = size(In);
end

Out = zeros(NumGenerators,2,'single');

%fprintf('NumGenerators = %d',NumGenerators)

for InteractiveRowIndex=1:NumGenerators
    IndexList = find(In(InteractiveRowIndex,:));
    %fprintf('Index=%d, list=[%s]\n',InteractiveRowIndex,sprintf('%d,',IndexList(:)))
    TempBig = [min(IndexList),max(IndexList)];
    if numel(TempBig)==0
        fprintf('\n     >>: ERROR in Bigrams: Zero generator found before exhausting the expected number of generators')
        Out(InteractiveRowIndex,:) = [0,0];
    else
        Out(InteractiveRowIndex,:) = TempBig;
    end
end

end