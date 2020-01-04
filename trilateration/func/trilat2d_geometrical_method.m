function tagPos = trilat2d_geometrical_method(P1, P2, P3, DistA, DistB, DistC)

    % P1 = [xA; yA; zA];
    % P2 = [xB; yB; zB];
    % P3 = [xC; yC; zC];
    
    %% Transformation
    % from wikipedia https://en.wikipedia.org/wiki/Trilateration
    % transform to get anchor 1 at origin
    % transform to get anchor 2 on x axis
    d  = norm(P2 - P1);   
    ex = (P2 - P1) / d;                             % x-axis unit vector in new coodinates
    i  = dot(ex, (P3 - P1));
    ey = (P3 - P1 - i*ex) / (norm(P3 - P1 - i*ex)); % y-axis unit vector in new coodinates
    ez = cross(ex, ey);                             % z-axis unit vector in new coodinates
    
    j  = dot(ey, (P3 - P1));
    
    %% Estimation
    % from wikipedia https://en.wikipedia.org/wiki/Trilateration
    % plug and chug using above values
    x = ((DistA^2) - (DistB^2) + (d^2))/(2*d);      % Tag coordinate in new coordinate system
    y = (((DistA^2) - (DistC^2) + (i^2) + (j^2))/(2*j)) - ((i/j)*x); 
                                                    % Tag coordinate in new coordinate system
                                                    % But why so cumbersome?

    z = sqrt(DistA^2 - x^2 - y^2);  % In 2d location case, this should be zero.
    %assert ( abs(z) < 1e-6);

    %% Transform back to coodinates in the original coordinate system.
    tagPos = P1 + x*ex + y*ey + z*ez;
    
    % Only take (x,y) of tagPos as output.
    tagPos = tagPos(1:2);
end