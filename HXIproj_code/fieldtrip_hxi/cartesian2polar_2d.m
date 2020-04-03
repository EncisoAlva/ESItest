function [r,theta] = cartesian2polar_2d(X)

x = X(:,1);
y = X(:,2);

r = mean(sqrt(sum(X.^2,2)));

theta = atan2(y,x);

for i = 1 : length(theta)
   curr_angle = theta(i);
   if curr_angle < 0
       theta(i) = curr_angle+2*pi;
   end
end
