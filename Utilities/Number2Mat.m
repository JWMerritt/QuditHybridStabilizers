function Out = Number2Mat(In,Hdim,L)
%NUMBER2MAT  Express a decimal number in base HDIM, with digits as the
% entries of a row matrix.
%
%   OUT = NUMBER2MAT(IN, HDIM, L) takes the decimal number IN, calculates the
%   digits when the number is represented in base HDIM, and places the
%   digits into a row matrix of size L (little-endian).
%
%   See also STATEENCODE, STATEDECODE

    Out = zeros(1,L);
    for ii=1:L
        Out(ii) = mod(In,Hdim);
        In = (In-Out(ii))/Hdim;
    end

end