% Trilateration algorithm
% paper "An algebraic solution to the multilateration problem"
% Author: Norrdine, Abdelmoumen  (norrdine@hotmail.de)
% https://www.researchgate.net/publication/275027725_An_Algebraic_Solution_to_the_Multilateration_Problem
% usage: [N1 N2] = Trilateration(P,S,W) 
% P = [P1 P2 P3 P4 ..] Reference points matrix
% S = [s1 s2 s3 s4 ..] distance matrix.
% W : Weights Matrix (Statistics).
% N : calculated solution
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY!! 

% Refined by chenxy, by mainly adding comment. 2019-11-22.

function [N1 N2] = Trilateration(P,S,W)
[mp,np] = size(P); % mp: coordinate dimensionality, unused; np: number of reference points.
ns = length(S);    % ns: number of distances, should be equal to np.

if (ns~=np)
    error('Number of reference points and distances are different');
end

% Generate design matrix, A and b.
A=[]; b=[];
for i1=1:np
    x = P(1,i1); y = P(2,i1); z = P(3,i1);
    s = S(i1);
    A = [A ; 1 -2*x  -2*y  -2*z]; % Adding one row.
    b = [b ; s^2-x^2-y^2-z^2 ];
end

% In case of only 3 reference points, give two solutions.
% They shoule be very close, if rank(A)==3 (?)
if (np==3)
    warning off;
    Xp= A\b;  % Gaussian elimination
    % or Xp=pinv(A)*b; 
    % the matrix  inv(A'*A)*A' or inv(A'*C*A)*A'*C or pinv(A)
    % depend only on the reference points
    % it could be computed only once
    xp = Xp(2:4,:);
    Z  = null(A,'r'); % Homogeneous solution: Ax = 0
    z  = Z(2:4,:);    % 
    if rank (A)==3    % What if rank(A)~=3?
        %Polynom coeff.
        a2 = z(1)^2 + z(2)^2 + z(3)^2 ;
        a1 = 2*(z(1)*xp(1) + z(2)*xp(2) + z(3)*xp(3))-Z(1);
        a0 = xp(1)^2 +  xp(2)^2+  xp(3)^2-Xp(1);
        p = [a2 a1 a0];
        t = roots(p);

        %Solutions
        N1 = Xp + t(1)*Z;
        N2 = Xp + t(2)*Z;
    end
end

% In case of more than 3 reference points, give least-square solution.
if  (np>3) 
%Particular solution

    if W~=diag(ones(1,length(W)))
        C = W'*W;
        Xpdw =inv(A'*C*A)*A'*C*b; % Solution with Weights Matrix
    else
        Xpdw=pinv(A)*b; % Solution without Weights Matrix
    end
 
    % the matrix  inv(A'*A)*A' or inv(A'*C*A)*A'*C or pinv(A)
    % depend only on the reference points
    % it could be computed only once
    N1 = Xpdw;
    N2 = N1;
end