function Out = CheckRowSubspace(In1,In2,Hdim,PrintOutput)
%CHECKROWSUBSPACE  Check if the span of the row vectors of one matrix is contained in another matrix.
%
%   Out = CHECKROWSUBSPACE(A,B,Hdim) checks if every row vector of B is
%   equal to some linear combination of the row vectors in A i.e., if
%   span(B) is a subset of span(A). This is a very sloppy code that just
%   checks is by brute force, but it's sometimes helpful for small tests.
%   Specifically, if span(In2) is a subspace of span(In1).
%
%   -- Hdim is assumed to be a prime number
%
%   -- A and B are assumed to be matrices with the same number of columns,
%   and only contain integers [0,...,Hdim].
%
%
%   The original purpose was to see if two generating sets were equivalent
%   - if they generate the same stabilizer group, then they span the same
%   subset, and so span(In2) \subset span(In1) and span(In1) \subset
%   span(In2). If size(In2)==size(In1) and all vectors are independent of
%   others in the same set, then span(In2) \subset span(In1) iff
%   span(In2)==span(In1), since they have the same dimension. So we can
%   still use this function in this way.

if nargin<4
    PrintOutput = false;
end

[NumRows1, ~] = size(In1);
[NumRows2, ~] = size(In2);

Digits = @(n) mod(floor(n./(Hdim.^(0:NumRows1-1))),Hdim);
NumVectors1 = Hdim^NumRows1;

checklist = 1:NumRows2;
%   gonna try this new version of a checklist...
NumberChecked = 0;

Out = false;

for IterativeRowIndex=1:NumVectors1

    CurrentVector = mod(Digits(IterativeRowIndex)*In1,Hdim);
    %   systematically generates all elements of the stabilizer group of In1

    for IterativeRowIndex2 = checklist

        if isequal(CurrentVector,In2(IterativeRowIndex2,:))

            checklist(checklist==IterativeRowIndex2) = [];
            %   checklist should slowly dwindle down to [], and we only iterate over its values to begin with.
            NumberChecked = NumberChecked + 1;

        end

    end

    if NumberChecked == NumRows2
        if PrintOutput
            fprintf("In2 generates a subspace of In1.\n")
        end
        Out = true;
        return
    end

end

if Out==false
    if PrintOutput
        fprintf("In2 does *NOT* generate a subspace of In1.\n")
    end
end


end