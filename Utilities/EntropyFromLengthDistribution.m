function Out = EntropyFromLengthDistribution(LengD,SystemSize)
%   Uses an equation to calculate the subssytem-averaged subssytem entropy S(L) from the length distribution of a state.

%   The equation is: S(L) = (sum x=1:SystemSize) ( (normalized length distribution of x)*min(2*x-2, 2*SystemSize-2) )
%           = (sum x=1:L-1) ((normalized length distribution of x)*(2*x-2)) + (sum x=L:SystemSize) ((normalized length distribution of x)*(2*L-2))
%   Note that this function expects the *unnormalzed* length distribution, since that is what LengthDistribution() returns

NumberOut = floor(SystemSize/2);
Out = zeros(NumberOut,1);
    % S(L) = S(SystemSize-L), so we only need to know half of the entropies
LengDMod = LengD(1:(NumberOut+1));
LengDMod(2:NumberOut) = LengDMod(2:NumberOut) + LengD(end:-1:(NumberOut+2));
    % This takes care of min(g-1, N-g+1)

for ii=1:NumberOut
    Out(ii) = sum(LengDMod(1:ii).*(0:(ii-1))') + sum(LengDMod((ii+1):(NumberOut+1))*ii);
        % = (sum x=1:ii) 2*LengDMod(x)*min(x-1,ii)
end

Out = Out/SystemSize;
    % This is because LengD was unnormalized

end