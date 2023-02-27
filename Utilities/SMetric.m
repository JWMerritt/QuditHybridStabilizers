function Out = SMetric(LiteralSize,IsSingle)
% gives the (size)x(size) symplectic metric

if nargin<2
    IsSingle = true;
end

if IsSingle
    H = single(zeros(LiteralSize));
else
    H = zeros(LiteralSize);
end

for ii=1:LiteralSize
    for jj=ii:LiteralSize
        H(ii,jj)=1;
    end
end

Out = H-H';

end