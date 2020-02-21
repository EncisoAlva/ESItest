function R = measure_beta_romberg_pain(r,j,a,b,M,thetaVector,measurement)
% Kincaid, p. 504

h = b-a;

theta = a;
u = measure_pain(theta,thetaVector,measurement);
f_a = u*r^j*exp(1i*theta*j);

theta = b;
u = measure_pain(theta,thetaVector,measurement);
f_b = u*r^j*exp(1i*theta*j);

R(1,1) = h*(f_a+f_b)/2;

for n = 2 : M
    h = h/2;
    f = [];
    for k = 1 : 2^(n-2)
        theta = a + (2*k-1)*h;
        u = measure_pain(theta,thetaVector,measurement);
        f(end+1) = u*r^j*exp(1i*theta*j);
    end
    R(n,1) = 0.5*R(n-1,1)+h*sum(f);
    for m = 2 : n
        R(n,m) = R(n,m-1) + (R(n,m-1)-R(n-1,m-1))/(4^(m-1)-1);
    end
end

