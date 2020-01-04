function [x,y] = spiralline2d(vRadial,vAngle,t,angle0,r0)
%spiralline Spiral line generator.
%   vRadial: Velocity in radial direction, m/s.
%   vAngle : Angular velocity, randian/s.
%   t      : time vector, second.
%   angle0 : Initial angle, in radian
%   r0     : Initial radial


    s =  r0 + vRadial * t;
    angle = angle0 + t * vAngle;
    x = s .* cos (angle);
    y = s .* sin (angle);   
    
    x = x(:); % Output as column vector.
    y = y(:); % Output as column vector.
end

