function StateOut = TrivStateMajorana(NumSites,SiteEigenoperator)
%TRIVSTATEMAJORANA  Create a trivial parafermion stabilizer state.
%
%   OUT = TRIVSTATEMAJORANA(N) creates the check-matrix for the trivial
%   Majorana parafemrion state, in which each site is an eigenstate of the
%   on-site parafermion parity (i.e., the operator [1,-1]). This makes it
%   the "tensor product" state of N sites with definite parafermion parity.
%
%   It is good practice to first set this matrix to be modulo Hdim for the
%   specific parafermion dimension before using it in any other functions.
%
%   OUT = TRIVSTATEBOSON(N, SITE_EIGEN) creates a state in which each site
%   i is an eigenstate of the SITE_EIGEN operator.
%
%   SITE_EIGEN = [a,b] is the row of integers which corresponds to the
%   operator $(\gamma_i)^a (\gamma_{i+1})^b$.

StateOut = zeros(NumSites,2*NumSites);
if nargin<2
    SiteEigenoperator = [1,-1];
end

%   I would love for this to be of type 'single', but MATLAB cannot multiply a single matrix with a sparse matrix.

for ii=1:NumSites
    StateOut(ii,2*ii-1:2*ii) = SiteEigenoperator;
end

end