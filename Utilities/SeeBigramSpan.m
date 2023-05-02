function SeeBigramSpan(Bigrams_,Figure_)

if nargin<=1
    Figure_ = figure;
end

[N,~] = size(Bigrams_);

figure(Figure_);
clf
hold on

for ii=1:N
    plot([Bigrams_(ii,1),Bigrams_(ii,2)],[-ii,-ii],'ko-')
end

end

