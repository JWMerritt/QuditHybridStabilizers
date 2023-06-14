function StateOut = TrivStateBoson(NumSites)
% StateOut = TrivStateBoson(SystemSize)
% Makes a trivial state of N bosons, 
%   which is an eigenstate of the generalized Pauli Z at each site.

StateOut = zeros(NumSites,2*NumSites);

%   I would love for this to be of type 'single', but MATLAB cannot multiply a single matrix with a sparse matrix.

for ii=1:NumSites
    StateOut(ii,2*ii-1:2*ii)=[0,1];
end

end