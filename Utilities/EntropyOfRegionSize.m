function Out = EntropyOfRegionSize(Bigrams,SystemSize,SizeA)
%   Finds the average entropy of all contiguous regious of size [SizeA]. This is only confirmed to be accurate for Pure states.

Out = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bigrams = ceil(Bigrams/2);
% this gives us the sites that the endpoints are on instead of the operator index

Lengths = Bigrams(:,2)-Bigrams(:,1);

SizeA = min(SizeA, SystemSize-SizeA);
%   For a pure state, you can find the entanglement entropy between A and not-A using either subsystem.
%   If not-A is smaller than A, just call it A.
%   This helps because the logic below breaks if SizeA>SystemSize/2.

TimesGeneratorIsBroken = 2*(min(Lengths,SizeA)-1);
%   As we wrap our subsystem of size [SizeA] around the system, each bigram will contribute
%     to a subsystem entropy this many times. This takes into account the wrapping of the
%     subsystem around the system's edges for periodic BC.

Out = (0.5*sum(TimesGeneratorIsBroken))/SystemSize;
%   From Li, Chen, Fisher (2019), in the clipped gauge, since each point will have 2 generators' endpoints on it,
%       the entropy of region A is equal to 1/2(b+c) = 1/2(endpoints in A with the corresponding other end outside of A).
%   Each time a generator is broken by A, it contributes one endpoint to the above eaquation.
%   This is only fully accurate if the state is a Pure state, since this property of the clipped gauge only holds for Pure states.
%
%   There are [SystemSize] total contiguous subsystems of size [SizeA], so this is what we divide by to get the average.

end

% If a bigram's length = K<L, then it will fall on the edge of a region of length L exactly 2*(K-1) times.
% If it's length L, it'll fall on the edge 2*(L-1) times
% If it's larger than L, it'll fall on the edge 2*(L-1) times.
% This works with L = min(SizeA, SystemSize-SizeA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Old code:

%{
for IterativeRowIndex=1:L
    if IterativeRowIndex+SizeA-1<=L
        [2*IterativeRowIndex-1, 2*(IterativeRowIndex+SizeA-1)]
        Out = Out + sum( (Bigrams(:,1) >= (2*IterativeRowIndex-1)) & (Bigrams(:,2) <= (2*(IterativeRowIndex+SizeA-1))) )
    else % Second index is greater than L
        LesserRowIndex = mod(IterativeRowIndex+SizeA-1,L);
        %   Since this is definitely going to be greater than L, we don't have to do the usual +1 -1 trick for mod().
        [2*LesserRowIndex+1, 2*IterativeRowIndex-2]
        Out = Out + sum( (Bigrams(:,1) >= (2*LesserRowIndex + 1)) & (Bigrams(:,2) <= (2*IterativeRowIndex - 2)) )
    end
end
%}