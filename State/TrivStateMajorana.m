function StateOut = TrivStateMajorana(NumSites)
% StateOut = TrivStateMajorana(SystemSize)
% Makes a trivial state of N fermions (2N Majorana fermions), 
%   which is an eigenstate of fermion parity at each site.
%   Note that the state is not modulo Hdim.

StateOut = zeros(NumSites,2*NumSites);

%   I would love for this to be of type 'single', but MATLAB cannot multiply a single matrix with a sparse matrix.

for ii=1:NumSites
    StateOut(ii,2*ii-1:2*ii)=[1,-1];
end

end