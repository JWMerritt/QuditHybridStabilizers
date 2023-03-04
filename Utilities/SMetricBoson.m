function Out = SMetricBoson(L)
%creates symplectic metric matrix in C' representation, mod d. L is length of the system

%v1.1

Out = zeros(2*L,'single');
inv = -1;
for i=1:L
    Out(2*i-1,2*i) = 1;
    Out(2*i,2*i-1) = inv;
end