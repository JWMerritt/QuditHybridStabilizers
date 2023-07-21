function SeeBigramSiteSpan(BigramsIn,FormatSpec,FigureIn)
%SEEBIGRAMSITESPAN  Builds a picture which shows the location and span
% of stabilziers in a stabilizer state.
%
%   SEEBIGRAMSITESPAN(BIGRAMS) creates a figure, with horizontal lines
%   indicating the span of the generators described with BIGRAMS. The span
%   is given in terms of the site index.
%
%   -- BIGRAMS is the list of bigrams a state, calculated from the
%   generators of the state in the clipped gauge.
%
%   SEEBIGRAMSITESPAN(BIGRAMS, FIG) plots the lines on the figure FIG
%   instead of creating a new figure.
%
%   See also SEEBIGRAMOPERATORSPAN

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

