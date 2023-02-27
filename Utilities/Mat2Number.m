function Out = Mat2Number(In,Hdim)
%   Basically takes a row matrix, and thinks of it as being the digits of a base-Hdim number (little-endian). We find this number.
%   Hdim should be larger than any of the entries in In, otherwise we won't be able to decode uniquely.
%   Length of In should be small enough that MATLAB can get all of the info into double-precision. 
%       (approx L < 52*log(2)/log(Hdim))

L = numel(In);
Out = 0;
for ii=1:L
    Out = Out + In(ii)*(Hdim^(ii-1));
end

end