function [Psi,S] = BosonUnitary(Psi,NumColumns,C_Numbers_Int,Hdim,RunOptions,Offset)
%   Makes a bosonic unitary, assuming a bosonic S_Metric

NumPairs = NumColumns/4;

S = speye(NumColumns);

for PairIndex = 0:NumPairs-2

    S_Local = BosonSymplectic(Hdim);
    ColumnIndex = 4*PairIndex+2*Offset;
    S(ColumnIndex+1:ColumnIndex+4, ColumnIndex+1:ColumnIndex+4) = S_Local;

end

S_Local = BosonSymplectic(Hdim);

if Offset==0
    Indices = NumColumns-3:NumColumns;
    S(Indices,Indices) = S_Local;
elseif Offset==1
    Indices = [NumColumns-1, NumColumns, 1, 2];
    S(Indices,Indices) = S_Local;
else
    error('Offset must be 0 or 1.')
end

Psi = mod(Psi*S,Hdim);

end

