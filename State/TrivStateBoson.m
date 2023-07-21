function StateOut = TrivStateBoson(NumSites, SiteEigenoperator)
%TRIVSTATEBOSON  Create a trivial boson stabilizer state.
%
%   OUT = TRIVSTATEBOSON(N) creates the check-matrix for the trivial boson
%   state - a state which is the tensor product of bosons, each of which is
%   an eigenstate of the Pauli Z oeprator.
%
%   OUT = TRIVSTATEBOSON(N, EIGENOPERATOR) creates a state which is a tensor
%   product of bosons which are each an eigenstate of the EIGENOPERATOR
%   operator.
%
%   EIGENOPERATOR = [a,b] is the row of integers which corresponds to the
%   operator X^a Z^b.

StateOut = zeros(NumSites,2*NumSites);
if nargin<2
    SiteEigenoperator = [0,1];
end

%   I would love for this to be of type 'single', but MATLAB cannot multiply a single matrix with a sparse matrix.

for ii=1:NumSites
    StateOut(ii,2*ii-1:2*ii) = SiteEigenoperator;
end

end