function Out = SymplecticMetricBoson(N)
%SYMPLECTICMETRICBOSON  Create a symplectic metric.
%
%   OUT = SYMPLECTICMETRICBOSON(N) creates a symplectic metric
%   corresponding to a generating set of a system with N sites. Uses a
%   representation where the X and Z operators for a site are kept close
%   together, instead of all X and then all Z, which is more common.

    Out = zeros(2*N,'single');
    inv = -1;
    for i=1:N
        Out(2*i-1,2*i) = 1;
        Out(2*i,2*i-1) = inv;
    end
end