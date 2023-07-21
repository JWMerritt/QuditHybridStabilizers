function Out = StateEncode(In,Hdim)
%STATEENCODE  Compress a generator matrix into a cell of numbers to save
% memory.
%
%   OUT = STATEENCODE(IN, HDIM) converts a generator matrix IN and encodes
%   it into a cell of numbers. Helps with the otherwise large overhead of
%   storing tens of thousands of 'single' values, each of which is a
%   single-digit integer.
%
%   See also STATEDECODE, MAT2NUMBER

    MaxL = floor(64*log(2)/log(Hdim));
    %   If the length of the matrix we're encoding is larger than this value,
    %   then the maximum number required (in the worst case scenario where all
    %   entries = Hdim-1) will encode into a number larger than the uint64
    %   limit.
    
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