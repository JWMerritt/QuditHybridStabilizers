function Out = Mat2Number(In,Hdim)
%MAT2NUMBER  Compress a matrix of integers into a number.
%
%   OUT = MAT2NUMBER(IN, HDIM) basically takes a row matrix, thinks of it
%   as being the digits of a base-Hdim number (little-endian), and
%   calculates this number in base-10.
%
%   HDIM should be larger than any of the entries in In (i.e. In should be
%   modulo HDIM), otherwise we won't be able to decode uniquely.
%
%   Length of In should be small enough that MATLAB can get all of the info
%   into double-precision. (approximately, this means L < 52*log(2)/log(Hdim))
%
%   See also STATEENCODE, STATEDECODE

L = numel(In);

Out = uint64(0);
    %   uint64(x) is exactly what we want.
    %   It uses all 8 bytes to just store the digits of the number.
Base = uint64(Hdim);
    %   This is necessary, because if we do the multiplication with double precision, we might lose some digits...

for ii=1:L
    Out = Out + In(ii)*(Base^(ii-1));
end

end