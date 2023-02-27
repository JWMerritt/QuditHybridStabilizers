function Out = Mat2Number(In,Hdim)
%   Basically takes a row matrix, and thinks of it as being the digits of a base-Hdim number (little-endian). We find this number.
%   Hdim should be larger than any of the entries in In, otherwise we won't be able to decode uniquely.
%   Length of In should be small enough that MATLAB can get all of the info into double-precision. 
%       (approx L < 52*log(2)/log(Hdim))

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