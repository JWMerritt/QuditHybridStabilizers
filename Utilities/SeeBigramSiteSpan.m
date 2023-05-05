function SeeBigramSiteSpan(BigramsIn,FormatSpec,FigureIn)

if nargin<=1
    FigureIn = figure;
    FormatSpec = 'ko-';
elseif nargin<=2
    FigureIn = figure;
end

[NumBigrams,~] = size(BigramsIn);
SiteBigrams = ceil(BigramsIn/2);

figure(FigureIn);
clf
hold on

for ii=1:NumBigrams
    plot([SiteBigrams(ii,1),SiteBigrams(ii,2)],[-ii,-ii],FormatSpec)
end

end

