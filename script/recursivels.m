% Author : chenxy
% Created: 2019-12-06
% Reference: http://www.cs.tut.fi/~tabus/course/ASP/LectureNew10.pdf
% 'mu' is an ingradient added by me, for comparison with lms.

% Assuming: y(k) = w(k) * x(k), i.e, 1st-order linear relation between y and x.
function [w, err, k] = recursivels(u,d,lambda,w0,u_sig2, mu)
       
    % Initialization.
    P0_inv = 1/(100 * u_sig2);
    
    nsamples = length(u);
    assert(length(d) == nsamples);

    w   = zeros(nsamples,1);
    err = zeros(nsamples,1);
    Pinv= zeros(nsamples,1);
    
    for n = 1:1:nsamples
        if n==1
            Pinv_prev = P0_inv;
            w_prev    = w0;
        else
            Pinv_prev = Pinv(n-1);        
            w_prev    = w(n-1);
        end
        
        %% k(n)   = u(n)/(lambda*Pinv_prev + u(n)*u(n));
        %% err(n) = d(n) - w_prev * u(n);
        %% w(n)   = w_prev + err(n)*k(n);
        %% Pinv(n)= lambda*Pinv_prev + u(n)*u(n);
        Pinv(n)= lambda*Pinv_prev + u(n)*u(n);
        k(n)   = u(n)/Pinv(n);
        err(n) = d(n) - w_prev * u(n);
        w(n)   = w_prev + err(n)*k(n)*mu;
        
    end
            
end