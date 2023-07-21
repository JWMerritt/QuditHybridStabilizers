function Out = Bigrams(In,NumGenerators)
%BIGRAMS  Find the bigrams (endpoints) of a set of generators.
%
%   OUT = Bigrams(G, NUM_GENERATORS) calculates the list of bigrams of the
%   generators in G.
%
%   -- G is a N-by-2N matrix of integers with NUM_GENERATORS nonzero rows. G
%   is assumed to be in the clipped gauge.
%
%   -- Out is a NUM_GENERATORS-by-2 matrix of type 'single', where each row
%   Out(:,i) is the bigram of the generator G(:,i). Out(1,i) is index of
%   the left endpoint and Out(2,i) is the right endpoint.
%
%   See CLIP


if nargin<=1
    [NumGenerators,~] = size(In);
end

Out = zeros(NumGenerators,2,'single');

for InteractiveRowIndex=1:NumGenerators
    IndexList = find(In(InteractiveRowIndex,:));
    TempBig = [min(IndexList),max(IndexList)];
    if numel(TempBig)==0
        fprintf('\n     >>: ERROR in Bigrams: Zero generator found before exhausting the expected number of generators')
        Out(InteractiveRowIndex,:) = [0,0];
    else
        Out(InteractiveRowIndex,:) = TempBig;
    end
end

end