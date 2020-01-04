% Author  : chenxy
% Creation: 2019-12-07
% Function: 2D least square trilateration

function tag_pos = ls_trilat_2d(AncPos, Dist)

% AncPos: (2,N). 2-D Coordinates of N anchors
% Dist:   N distance. Should have the same units with AncPos
    
    assert(size(AncPos,1)==2)
    assert(size(AncPos,2)==length(Dist))
    
    Nanc = size(AncPos,2);
    % Shift the first anchor to (0,0)
    refAnc = AncPos(:,1);
    AncPos = AncPos - repmat(refAnc,1,Nanc);
        
    A = AncPos(:,2:end);
    A = A';
    
    b_ext = zeros(Nanc, 1);
    for k = 1:1:Nanc
        xk   = AncPos(1,k);
        yk   = AncPos(2,k);
        b_ext(k) = (Dist(1)^2 -  Dist(k)^2 + (xk^2 + yk^2))/2;
    end
    b = b_ext(2:end);
    
    tag_pos = inv(A' * A) * (A' * b);
    
    tag_pos = tag_pos + refAnc;

end