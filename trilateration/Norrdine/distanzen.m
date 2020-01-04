
% Calculate distance between Nn and referece points Pi and the error
% P= [P1 P2 ...]: reference point coordinate matric 
% S= [s1 s2 ...] : measured distances
% Sn = []: calculated distances 
% F : Error norm
function [Sn , F] = distanzen(Nn,P,S)
% global P S -- Seems unnecessary. Commented out by chenxy.

for i1=1:length(S)
    Sn(i1)=norm(P(:,i1)-Nn);
end
F = norm(S-Sn);
