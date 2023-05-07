function SeeBigramOperatorSpan(BigramsIn,FigureIn)

if nargin<=1
    FigureIn = figure;
end

[N,~] = size(BigramsIn);

figure(FigureIn);
clf
hold on

for ii=1:N
    plot([BigramsIn(ii,1),BigramsIn(ii,2)],[-ii,-ii],'ko-')
end

end

