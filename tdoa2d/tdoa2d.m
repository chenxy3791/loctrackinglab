function [OUT, OUT1, OUT2]=tdoa2d(anc_pos, dist21, dist31)

X21 = anc_pos(2,1) - anc_pos(1,1);
X31 = anc_pos(3,1) - anc_pos(1,1);
Y21 = anc_pos(2,2) - anc_pos(1,2);
Y31 = anc_pos(3,2) - anc_pos(1,2);
A = inv([X21,Y21;X31,Y31]);

B   = [dist21;dist31];

K1 = anc_pos(1,1)^2 + anc_pos(1,2)^2;
K2 = anc_pos(2,1)^2 + anc_pos(2,2)^2;
K3 = anc_pos(3,1)^2 + anc_pos(3,2)^2;
C  = 0.5*[dist21^2 - K2 + K1; dist31^2 - K3 + K1];

a = B'*A'*A*B - 1;
b = B'*A'*A*C + C'*A'*A*B;
c = C'*A'*A*C;

root1 = (-b + sqrt(b^2 - 4*a*c))/(2*a);
root2 = (-b - sqrt(b^2 - 4*a*c))/(2*a);

EMS1  = -A*(B*root1 + C);
EMS2  = -A*(B*root2 + C);

dist21ems1 = sqrt((anc_pos(2,1) - EMS1(1))^2 + (anc_pos(2,2) - EMS1(2))^2)-sqrt((anc_pos(1,1) - EMS1(1))^2 + (anc_pos(1,2) - EMS1(2))^2);
dist31ems1 = sqrt((anc_pos(3,1) - EMS1(1))^2 + (anc_pos(3,2) - EMS1(2))^2)-sqrt((anc_pos(1,1) - EMS1(1))^2 + (anc_pos(1,2) - EMS1(2))^2);

% Select from the two possible positions.
OUT1 = EMS1;
OUT2 = EMS2;
if sign(dist21)==sign(dist21ems1)&&sign(dist31)==sign(dist31ems1),
    OUT=EMS1;
else
    OUT=EMS2;
end

