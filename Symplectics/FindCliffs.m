function Out = FindCliffs(Hdim)
%FINDCLIFFS  Use brute force to find the valid 4-by-4 symplectic matrices for the
% Majorana parafermion symplectic metric. Only needs to be run once for
% each value of HDIM.
%
%   OUT = FINDCLIFFS(HDIM) uses brute force to check HDIM^12 possible
%   matrices, and selects those which are valid 4-by-4 Majorana parafermion
%   symplectic matrices.
%
%   -- OUT is a list of integers which correspond to the 4-by-4 symplectic
%   matrices. The 4-by-4 matrices can be recovered by using
%   CNumToMajSymplectic(NUM).
%
%   See also CNUMTOMAJSYMPLECTIC

%   a 4-by-4 matrix has 16 entries. 4 of these can be removed by the
%   constraint that the total parafermion parity of the resultin operators
%   must be 1 (i.e., the sum of each column must equal 1). We use brute
%   force to check the remaining 12 entries to see what combinations result
%   in a symplectic matrix.

Out = [];

Numbers = 0:11;

U = @(n,d) mod(floor(n./(d.^Numbers)),d);

% These six equations are the constraints for a symplectic matrix, with the
% symplectic metric that has all 1's above the diagonal.

%{
Eqs = @(v) [v(1)*(-1+v(6)+v(10)) + v(5)*(-1-v(2)+v(10)) + v(9)*(-1-v(2)-v(6)) + v(2)+v(6)+v(10)-1
    v(1)*(-1+v(7)+v(11)) + v(5)*(-1-v(3)+v(11)) + v(9)*(-1-v(3)-v(7)) + v(3)+v(7)+v(11)-1
    v(1)*(-1+v(8)+v(12)) + v(5)*(-1-v(4)+v(12)) + v(9)*(-1-v(4)-v(8)) + v(4)+v(8)+v(12)-1
    v(2)*(-1+v(7)+v(11)) + v(6)*(-1-v(3)+v(11)) + v(10)*(-1-v(3)-v(7)) + v(3)+v(7)+v(11)-1
    v(2)*(-1+v(8)+v(12)) + v(6)*(-1-v(4)+v(12)) + v(10)*(-1-v(4)-v(8)) + v(4)+v(8)+v(12)-1
    v(3)*(-1+v(8)+v(12)) + v(7)*(-1-v(4)+v(12)) + v(11)*(-1-v(4)-v(8)) + v(4)+v(8)+v(12)-1];
%}

Eqs = @(V) [V(1)*(-1+V(5)+V(6)) + V(2)*(-1-V(4)+V(6)) + V(3)*(-1-V(4)-V(5)) + (-1+V(4)+V(5)+V(6))
    V(1)*(-1+V(8)+V(9)) + V(2)*(-1-V(7)+V(9)) + V(3)*(-1-V(7)-V(8)) + (-1+V(7)+V(8)+V(9))
    V(1)*(-1+V(11)+V(12)) + V(2)*(-1-V(10)+V(12)) + V(3)*(-1-V(10)-V(11)) + (-1+V(10)+V(11)+V(12))
    V(4)*(-1+V(8)+V(9)) + V(5)*(-1-V(7)+V(9)) + V(6)*(-1-V(7)-V(8)) + (-1+V(7)+V(8)+V(9))
    V(4)*(-1+V(11)+V(12)) + V(5)*(-1-V(10)+V(12)) + V(6)*(-1-V(10)-V(11)) + (-1+V(10)+V(11)+V(12))
    V(7)*(-1+V(11)+V(12)) + V(8)*(-1-V(10)+V(12)) + V(9)*(-1-V(10)-V(11)) + (-1+V(10)+V(11)+V(12))];


for ii=1:((Hdim^12)-1)
    % if the numbers are a valid solution, then all the entries of U(ii)
    % should be zero.
    %Md = mod(Eqs(U(ii)),Hdim)
    Try = sum(abs(mod(Eqs(U(ii,Hdim)),Hdim)));
    if Try==0
        Out = [Out,ii];
    end
end

end


