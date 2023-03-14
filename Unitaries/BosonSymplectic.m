function Out = BosonSymplectic(Hdim)
%makes random 4x4 Clifford symplectic in C' representation.
%with Pauli operators written as column vectors

%v1.5

%{
    Pseudocode:
start with standard basis, 4x4 identity matrix
pick random vector mod d; v
find conjugate vector; w
project other 3 to be orthogonal to v by f'=f-<v,f>w
    (these three should be independent, and span the space orthogonal to v)
choose random coefficients for those three to add to w, to randomize it; w'
project three to be orthogonal to v and w' by f' = f - <v,f>w + <w,f>v
find two of the three that are conjugate
    those two, v, and w', make our first symplectic
Then, get a random 2x2 symplectic, mod d
multiply the first symplectic by (I tensor+ 2x2)
return the output
%}



sm=0;
index=0;
P = single([0,1,0,0;-1,0,0,0;0,0,0,1;0,0,-1,0]);
Ki = eye(4,'single'); %collection of basis vecotrs for the space
Kb = zeros(4,5,'single'); %K buffer, holding the vectors up to this point
Kf = zeros(4,4,'single'); %K out, to be used once one of the vectors decouples
C2 = zeros(4,4,'single'); %an element of the C1 subgroup, for the last step

%this first part chooses the first two images.
%it picks a vector, G-S the rest, chooses a second, and G-S again
while sm == 0
a1 = randi([0,Hdim-1],4,1,'single');
sm=sum(a1(:));      %make sure the vector isn't all zero. NOTE: don't do sum mod Hdim.
end
Kb(:,1)=a1(:);  %this is our first v1

Kb(:,5)=mod((a1'*P)',Hdim);   %since the vectors are unit basis, this vector lists the symplectic product of them all.
    %note that we're just usning the last entry of Kb to store this, it'll
    %be removed later
sm=1;
while sm<=4 && index==0
    inv = ModInverse(Kb(sm,5),Hdim); %computes inverse mod Hdim of inner product
    if inv~=0
        Kb(:,2)=inv*Ki(:,sm);   % the sm basis vector is chosen as w1
        index = sm;
    end
    sm=sm+1;
end
    %note also that we don't have to worry about vectors decoupling
    %at this point, only in the next one.
for ii=1:4
    if ii<index
        Kb(:,ii+2)=Ki(:,ii);
    elseif ii>index
        Kb(:,ii+1)=Ki(:,ii);
    end
end      %use w1 to project project perp to v

for ii=3:5
    Kb(:,ii) = mod(Kb(:,ii)-(Kb(:,1)'*P*Kb(:,ii))*Kb(:,2),Hdim);
end
    %this should give us 3 independent vectors which are
    %perpendicular to v1, forming a basis for that 3d subspace. 
    %Now, add them at random to w1 to get a random conjugate to v1.
    %They're also linearly independent of w1, so we shouldn't have
    %to worry avout the vector vanishing.
q = randi([0,Hdim-1],3,1,'single');
Kb(:,2)=mod(Kb(:,2)+q(1)*Kb(:,3)+q(2)*Kb(:,4)+q(3)*Kb(:,5),Hdim);

for ii=3:5       %make the others orthogonal to both v1 and w1
    Kb(:,ii) = mod(Kb(:,ii)-(Kb(:,1)'*P*Kb(:,ii))*Kb(:,2)+(Kb(:,2)'*P*Kb(:,ii))*Kb(:,1),Hdim);
end

Kf(:,1)=Kb(:,1);
Kf(:,2)=Kb(:,2);
    %now we G-S the 2d subspace. There are 3 vectors, so we pick
    %two that have the correct inner product; then the third will
    %be dependent on those, and we throw it out.
index = 0;
for ii=4:5
    if mod(Kb(:,3)'*P*Kb(:,ii),Hdim)~=0     %try to find a conjugate to '3'
        index=ii;
        break
    end
end
if index==0
    %[~,inv]=gcd(Kb(:,4)'*P*Kb(:,5),Hdim);
    %inv=mod(inv,Hdim);
    inv = ModInverse(Kb(:,4)'*P*Kb(:,5),Hdim);
    Kf(:,3)=Kb(:,4);
    Kf(:,4)=inv*Kb(:,5);    
    %If '3' is orthogonal
    %to the other two, (inner products are zero with all others),
    %and the three span a 2d vector space, it decouples,
    %and the other two must have an inner product of 1 - they're a basis
else    %otherwise, we've found a vector that '3' is conjugate to
    %[~,inv]=gcd(Kb(:,3)'*P*Kb(:,index),Hdim);
    %inv=mod(inv,Hdim);
    inv = ModInverse(Kb(:,3)'*P*Kb(:,index),Hdim);
    Kf(:,3)=Kb(:,3);
    Kf(:,4)=inv*Kb(:,index);
end
    %that's the first step. Now, we pick a random 2x2 symplectic matrix
    %to multiply it by.
C1 = single([1,0,0,0;0,1,0,0;0,0,0,0;0,0,0,0]) + kron(single([0,0;0,1]),random2d(Hdim));
    %makes random C1 matrix and puts it into the form eye(2)(+)C1
Kf = mod(Kf*C1,Hdim);
Out=Kf;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function Out = random2d(Hdim)
    %makes random 2x2 Clifford symplectic in C' representation
    
    %v2.0
    
    Kb=eye(2,'single');
    Kf=zeros(2,2,'single');
    P=single([0,1;-1,0]);
    sm=0;
    inv=0;
    index=0;
    
    while sm==0     %choose v at random
    a1=randi([0,Hdim-1],2,1,'single');
    sm=sum(a1(:));
    end
    Kf(:,1)=a1(:);
    
    if mod(a1'*P*Kb(:,1),Hdim)~=0     %find a w conjugate to v, mod Hdim. It's not orthogonal to both of them!
        %[~,inv]=gcd(a1'*P*Kb(:,1),Hdim);
        %inv=mod(inv,Hdim);
        inv = ModInverse(a1'*P*Kb(:,1),Hdim);
        Kf(:,2)=mod(inv*Kb(:,1),Hdim);
        index=1;
    else
        %[~,inv]=gcd(a1'*P*Kb(:,2),Hdim);
        %inv=mod(inv,Hdim);
        inv = ModInverse(a1'*P*Kb(:,2),Hdim);
        Kf(:,2)=mod(inv*Kb(:,2),Hdim);
        index=2;
    end
    
    a1=mod(Kb(:,3-index)-(a1'*P*Kb(:,3-index))*Kf(:,2),Hdim);
        %projects the other vector to be orthogonal to v, and calls it a1
        %a1 is now the vector that spans the 1D subspace orthogonal to v
    Kf(:,2) = mod(Kf(:,2) + randi([0,Hdim-1])*a1,Hdim);  %randomize w
    
    Out=Kf;
    
    
    
    
    end

