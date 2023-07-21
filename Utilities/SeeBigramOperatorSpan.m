function SeeBigramOperatorSpan(BigramsIn,FigureIn)
%SEEBIGRAMOPERATORSPAN  Builds a picture which shows the location and span
% of stabilziers in a stabilizer state.
%
%   SEEBIGRAMOPERATORSPAN(BIGRAMS) creates a figure, with horizontal lines
%   indicating the span of the generators described with BIGRAMS. The span
%   is given in terms of the operator index, not the physical site index.
%
%   -- BIGRAMS is the list of bigrams a state, calculated from the
%   generators of the state in the clipped gauge.
%
%   SEEBIGRAMOPERATORSPAN(BIGRAMS, FIG) plots the lines on the figure FIG
%   instead of creating a new figure.
%
%   See also SEEBIGRAMSITESPAN

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

