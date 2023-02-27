function Out = StateEncode(In,Hdim);
%   Takes a state - an L-by-2L matrix - and encodes the contents into numbers.
%   Helps with the otherwise large overhead of storing tens of thousands of doubles, each of which is a single-digit integer.

MaxL = floor(50*log(2)/log(Hdim));
%   Too much over this, and we'll run into problems with the double-digit precision not holding all of the information.
%   It's not the max, but I've chosen 2^50 to be safe. A better estimate it 2^52, that is, (2^52 +1 ) - 2^52 = 1 in MATLAB.
%       And we could also theoretically code into the negatives.

[NumRows,NumColumns] = size(In);
CellColumns = ceil(NumColumns/MaxL);
Out = zeros(NumRows,CellColumns);

for IterativeRowIndex = 1:NumRows

    for IterativeCellColumnIndex=1:CellColumns

        InRange = ((IterativeCellColumnIndex-1)*MaxL+1):(min(IterativeCellColumnIndex*MaxL,NumColumns));
        Out(IterativeRowIndex,IterativeCellColumnIndex) = Mat2Number(In(IterativeRowIndex,InRange),Hdim);

    end

end




end