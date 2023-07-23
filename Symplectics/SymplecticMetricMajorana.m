function Out = SymplecticMetricMajorana(NumSites,IsSingle)
%SYMPLECTICMETRICMAJORANA  Create a symplectic metric for the generating
% set of a system of Majorana parafermions
%
%   OUT = SYMPLECTICMETRICMAJORANA(N) creates the symplectic metric for a
%   system of N parafermions using the Majorana operator representation.




% gives the (size)x(size) symplectic metric

if nargin<2
    IsSingle = true;
end

if IsSingle
    H = single(zeros(2*NumSites));
else
    H = zeros(2*NumSites);
end

for ii=1:2*NumSites
    for jj=ii:2*NumSites
        H(ii,jj)=1;
    end
end

Out = H-H';

end