function MatrixOut = CNumToMajSymplectic(C_Number,Hdim)
%CNUMTOMAJSYMPLECTIC  Turn an integer into a matrix
%
%   OUT = CNUMTOMAJSYMPLECTIC(CLIFF_NUMBER, HDIM) returns a 4-by-4 matrix,
%   who's entries are functions of the digits of CLIFF_NUMBER when written
%   in base-HDIM (little-endian). Note that this does not necessarily
%   result in a symplectic matrix, unless the input CLIFF_NUMBER is chosen
%   correctly.
%
%   See also FINDCLIFFS

% gives the actual 4x4 symplectic matrix, given the numerical output of
% FindCliffs.

Numbers = 0:11;
V = single(mod(floor(C_Number./(Hdim.^Numbers)),Hdim));

%{
Out = [1-v(1)-v(5)-v(9), 1-v(2)-v(6)-v(10), 1-v(3)-v(7)-v(11), 1-v(4)-v(8)-v(12)
    v(1),v(2),v(3),v(4)
    v(5),v(6),v(7),v(8)
    v(9),v(10),v(11),v(12)]';
%}

MatrixOut = [1-V(1)-V(2)-V(3), V(1), V(2), V(3)
    1-V(4)-V(5)-V(6), V(4), V(5), V(6)
    1-V(7)-V(8)-V(9), V(7), V(8), V(9)
    1-V(10)-V(11)-V(12), V(10), V(11), V(12)];

MatrixOut = mod(MatrixOut,Hdim);

end
