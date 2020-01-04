% Test Trilateration algorithm 
% paper "An algebraic solution to the multilateration problem"
% Author: Norrdine, Abdelmoumen  (norrdine@hotmail.de)
% https://www.researchgate.net/publication/275027725_An_Algebraic_Solution_to_the_Multilateration_Problem
% note : Interim results may differ from the paper (depends on the choise of Z = null(A)).
% Numerical example: A. Solution based on three reference points: 

% Refined by chenxy @ 2019-11-22

clear all; close all; 

%Reference points
P1 =[ 27.297  -4.953  1.47]';
P2 =[ 25.475  -6.124  2.36]';
P3 =[ 22.590   0.524   1.2]';


%distances
s1 = 3.851; % distance to P1
s2 = 3.875; % distance to P2
s3 = 3.514; % distance to P3

P  = [P1 P2 P3]; % Reference points matrix, each column represents one anchor coordinate.
S  = [s1 s2 s3]; % Distance vector, distance from tag to each coordinate.

fprintf('\n Trilateration \n');
%[N1 N2] = Trilateration([P1 P2 P3],[s1 s2 s3], diag(ones(1,3)));
[N1 N2] = Trilateration(P,S, eye(3));

%Solutions
Nsol1 = N1(2:4,1); % Throw away the first item -- corresponding to (x^2+y^2+z^2)
Nsol2 = N2(2:4,1); % Throw away the first item -- corresponding to (x^2+y^2+z^2)
fprintf('\n Solutions: \n');
disp([Nsol1 Nsol2])

%Distances and Errors based on Nsol1
fprintf('\n Measured distances: \n');
disp([s1 s2 s3])
distancesToSolution = [norm(P1 - Nsol1) norm(P2 - Nsol1) norm(P3 - Nsol1) ];
fprintf('\n Estimated True distances (Distances to solution Nsol1:) \n');
disp(distancesToSolution)

fprintf('\n Difference between Estimated True minus measured distances \n');
disp([s1 s2 s3] - distancesToSolution)
fprintf('\n d: Measure of solvability (Nsol1): \n');
disp(N1(1) - sum(Nsol1.^2))

%Distances and Errors based on Nsol2
fprintf('\n Measured distances: \n');
disp([s1 s2 s3])
distancesToSolution = [norm(P1 - Nsol2) norm(P2 - Nsol2) norm(P3 - Nsol2) ];
fprintf('\n Estimated True distances (Distances to solution Nsol2:) \n');
disp(distancesToSolution)

fprintf('\n Difference between Estimated True minus measured distances \n');
disp([s1 s2 s3] - distancesToSolution)
fprintf('\n d: Measure of solvability (Nsol2): \n');
disp(N2(1) - sum(Nsol2.^2))
