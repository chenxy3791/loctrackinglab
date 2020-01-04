function [w, err] = lms(u,y,mu, w0)
        
    nsamples = length(u);
    assert(length(y) == nsamples);

    w   = zeros(nsamples,1);
    err = zeros(nsamples,1);    
    
    for n = 1:1:nsamples
        if n==1
            w_prev    = w0;
        else
            w_prev    = w(n-1);
        end
        
        err(n) = y(n) - w_prev * u(n);
        w(n)   = w_prev + 2*mu*err(n)*u(n);
    end
        
end