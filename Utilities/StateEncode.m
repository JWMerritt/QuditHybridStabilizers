function Out = StateEncode(In,Hdim);
%   Takes a state - an L-by-2L matrix - and encodes the contents into numbers.
%   Helps with the otherwise large overhead of storing tens of thousands of doubles, each of which is a single-digit integer.

MaxL = floor(64*log(2)/log(Hdim));
%   If the length of the matrix we're encoding is larger than this
%     then the maximum number required (where all entries are Hdim-1) will code into a number larger than the uint64 limit.

[NumRows,NumColumns] = size(In);
CellColumns = ceil(NumColumns/MaxL);
Out = zeros(NumRows,CellColumns,'uint64');

for IterativeRowIndex = 1:NumRows

    for IterativeCellColumnIndex=1:CellColumns

        InRange = ((IterativeCellColumnIndex-1)*MaxL+1):(min(IterativeCellColumnIndex*MaxL,NumColumns));
        Out(IterativeRowIndex,IterativeCellColumnIndex) = Mat2Number(In(IterativeRowIndex,InRange),Hdim);

    end

end




end