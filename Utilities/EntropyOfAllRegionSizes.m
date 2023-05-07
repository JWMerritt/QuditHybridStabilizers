function Out = EntropyOfAllRegionSizes(BigramsIn,SystemSize,FullOutput)
%   Sweeps over entropy of regions size [1,$SystemSize/2] (since L and SystemSize-L give the same answer).

if nargin<=2
    FullOutput=false;
end

NumystemSizes = floor(SystemSize/2);
Out = zeros(NumystemSizes,1);

for ii=1:NumystemSizes
    Out(ii) = EntropyOfRegionSize(ii,BigramsIn,SystemSize);
end

if FullOutput
    Out = [Out;Out(end:-1:1)];
end

end
