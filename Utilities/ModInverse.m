function Out = ModInverse(In,d)
% gives multiplicative inverse of 'In' modulo 'd'
% mainly here because the gcd() approach eats a lot of computation time

% v2.1
%   - fixed ModInverse(3,7).

In = mod(In,d);


if In==1
    Out=1;
else
    switch d
    case 3
        Out=In;
    case 5
        switch In
        case 2
            Out = 3;
        case 3
            Out = 2;
        case 4
            Out = 4;
        otherwise
            Out = 0;
        end
    case 7
        switch In
        case 2
            Out = 4;
        case 3
            Out = 5;
        case 4
            Out = 2;
        case 5
            Out = 3;
        case 6
            Out = 6;
        otherwise
            Out = 0;
        end
    case 11
        switch In
        case 2
            Out = 6;
        case 3
            Out = 4;
        case 4
            Out = 3;
        case 5
            Out = 9;
        case 6
            Out = 2;
        case 7
            Out = 8;
        case 8
            Out = 7;
        case 9
            Out = 5;
        case 10
            Out = 10;
        otherwise
            Out = 0;
        end
    otherwise
        [~,Out] = gcd(In,d);
        Out = mod(Out,d);
    end
end

end
        
    