function Out = StateDecode(In,Hdim,NumColumns)
%STATEDECODE  Convert a cell of numbers into a generator matrix.
%
%   OUT = STATEDECODE(IN, HDIM) converts a cell of numbers which was
%   encoded using StateEncode back into a matrix of integers modulo HDIM.
%
%   See also STATEENCODE, NUMBER2MAT

%   Decodes the mess we made with StateEncode.

[NumRows,NumCellColumns] = size(In);
MaxL = floor(64*log(2)/log(Hdim));
%   We're assuming that this is the same chunk length used to encode the state...

Out = zeros(NumRows,NumColumns);

for IterativeRowIndex=1:NumRows
    for IterativeCellColumnIndex=1:NumCellColumns
        DecodeLength = min(MaxL,NumColumns-(IterativeCellColumnIndex-1)*MaxL);
        tempArray = Number2Mat(In(IterativeRowIndex,IterativeCellColumnIndex),Hdim,DecodeLength);

        OutRange = ((IterativeCellColumnIndex-1)*MaxL) + (1:DecodeLength);
        Out(IterativeRowIndex,OutRange) = tempArray;
    end
end

end