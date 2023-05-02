function Out = EntropyOfAllRegionSizes(BigramsIn,SystemSize)
%   Sweeps over entropy of regions size [1,SystemSize/2] (since L and SystemSize-L give the same answer).

Number_SystemSizes = floor(SystemSize/2);
Out = zeros(Number_SystemSizes,1);

for ii=1:Number_SystemSizes
    Out(ii) = EntropyOfRegionSize(ii,BigramsIn,SystemSize);
end

end
