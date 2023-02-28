function Out = GetCliff(Number,Hdim)
% gives the actual 4x4 symplectic matrix, given the numerical output of
% FindCliffs.

Numbers = 0:11;
V = single(mod(floor(Number./(Hdim.^Numbers)),Hdim));

%{
Out = [1-v(1)-v(5)-v(9), 1-v(2)-v(6)-v(10), 1-v(3)-v(7)-v(11), 1-v(4)-v(8)-v(12)
    v(1),v(2),v(3),v(4)
    v(5),v(6),v(7),v(8)
    v(9),v(10),v(11),v(12)]';
%}

Out = [1-V(1)-V(2)-V(3), V(1), V(2), V(3)
    1-V(4)-V(5)-V(6), V(4), V(5), V(6)
    1-V(7)-V(8)-V(9), V(7), V(8), V(9)
    1-V(10)-V(11)-V(12), V(10), V(11), V(12)];

Out = mod(Out,Hdim);

end
