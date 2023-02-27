function Out = Number2Mat(In,Hdim,L)
%   Basically converts 'In' into the decimal representation of a base-Hdim number (little-endian).
%   L is the number of columns in the output, and can be any number larger than the original sequence the number came from.

Out = zeros(1,L);
for ii=1:L
    Out(ii) = mod(In,Hdim);
    In = (In-Out(ii))/Hdim;
end

end