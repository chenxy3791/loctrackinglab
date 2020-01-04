% Trilateration algorithm
% paper "An algebraic solution to the multilateration problem"
% Author: Norrdine, Abdelmoumen  (norrdine@hotmail.de)
% https://www.researchgate.net/publication/275027725_An_Algebraic_Solution_to_the_Multilateration_Problem
% usage: [Nmat] = RecTrilateration(P,S,W) 
% P = [P1 P2 P3 P4 ..] Reference points matrix
% S = [s1 s2 s3 s4 ..] distance matrix.
% W : Weights Matrix (Statistics).
% Nmat : calculated solution, each column represents a solution.
%     N01   -- Return from RecTrilateration(np=3) ~= Trilateration(np=3)
%     N02   -- Return from RecTrilateration(np=3) ~= Trilateration(np=3)
%     Updated solution after the first round of iteration
%     Updated solution after the second round of iteration
%     ......
%     Xpdw  -- Least Square solution with all 'np' reference anchors.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY!!
function Nmat = RecTrilateration(P,S,W)
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
% They should be very close, if rank(A)==3 (?)
if (np==3)
    warning off;
    Xp= A\b;  % Gaussian elimination
    % or Xp=pinv(A)*b; 
    % the matrix  inv(A'*A)*A' or inv(A'*C*A)*A'*C or pinv(A)
    % depend only on the reference points
    % it could be computed only once
    xp = Xp(2:4,:);
    Z = null(A); % Notice the difference from "Z = null(A, 'r')" in Trilateration().
    z = Z(2:4,:);
    if rank (A)==3
        %Polynom coeff.
        a2 = z(1)^2 + z(2)^2 + z(3)^2 ;
        a1 = 2*(z(1)*xp(1) + z(2)*xp(2) + z(3)*xp(3))-Z(1);
        a0 = xp(1)^2 +  xp(2)^2+  xp(3)^2-Xp(1);
        p = [a2 a1 a0];
        t = roots(p);

        %Solutions
        N1 = Xp + t(1)*Z;
        N2 = Xp + t(2)*Z;
        Nmat(:,1) = N1;
        Nmat(:,2) = N2;
    end
end

A0 = A(1:3,:); % Unused. Commented out by chenxy
if  (np>3)
    P10   =P(:,1:3); S10=S(:,1:3); W0=W(1:3,1:3);
    N0mat = RecTrilateration(P10,S10,W0);
    N01   = N0mat(:,1);
    N02   = N0mat(:,2);

    %select N0
    C = W'*W;
    Xpdw =inv(A'*C*A)*A'*C*b;
    % the matrix  inv(A'*A)*A' or inv(A'*C*A)*A'*C or pinv(A)
    % depend only on the reference points
    % it could be computed only once
    NormErrorXpdw = Xpdw(1)-norm(Xpdw(2:4))^2; % Unused.
    
    % Select from N01 and N02 depending on who is closer to the first candidate Xpdw.
    if (norm(Xpdw(2:4)-N01(2:4))<norm(Xpdw(2:4)-N02(2:4)))
        N0 = N01;
    else
        N0 = N02;
    end
    
    Nmat(:,1)= N01;
    Nmat(:,2)= N02;
    
    %% W0 = W(1:3,1:3);      % Unused. Commented out by chenxy
    %% C0 = W0*W0';          % Unused. Commented out by chenxy
    %% P_0 = inv(A0'*C0*A0); % Unused. Commented out by chenxy
    %%                       
    %% %Start solution       
    %% invP_i_1 = inv(P_0);  % Unused. Commented out by chenxy
    %% xi_1 = N0;            % Unused. Commented out by chenxy
      
    % Recursive Least square (Introduction to applied Math Strang pp 147)
    
    % Matlab help for lsrec().
    % [x,P] = lsrec(x0,W) initializes a recursive solution by returning the
    % initial solution x = x0 having a scalar weight 0 < W <= 1. If x0 is a
    % very good first estimate, use W near 1. If x0 is a poor first estimate
    % use W near 0.  If W is not given, W = 1e-12 is used. P is a matrix of size
    % length(x0)-by-length(x0) that is required for future recursive calls.
    
    x0 = N0;
    [x,P] = lsrec(x0,1);     % Generate the initial solution.
    for i=1:np-3
        An = A(i+3,:);       
        % Wn = W(i+3,i+3);     % Unused. Commented out by chenxy
        yn = b(i+3);
        [xn,Pn] = lsrec(yn,An,1,x,P);
        x=xn; P=Pn;
        Nmat(:,i+2) = xn;
    end
    Nmat(:,i+3)= Xpdw;
end