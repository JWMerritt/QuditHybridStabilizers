function StateOut = UnitaryMajoranaBasic(StateIn,NumColumns,C_Numbers_Hdim,Hdim,RunOptions,Offset)
% StateOut = UnitaryMajoranaBasic(StateIn,NumColumns,C_Numbers_Int,Hdim,RunOptions,Offset)
% Mostly a wrapper for SystemSymplecticMajorana, but in a standard form.
% 

SystemSymplectic = SiteSymplecticMajorana(NumColumns/2,C_Numbers_Hdim,Hdim,Offset);
%   We dont need any RunOptions for this evolution.

StateOut = mod(StateIn*SystemSymplectic,Hdim);

end