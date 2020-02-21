function u = measure_pain(theta,thetaVector,measurement)
% get the measurement at any location on the boundary by interpolation

thetaDiff = theta - thetaVector;
ind = find(thetaDiff<=0,1,'first');

if isempty(ind)
    u = measurement(end)+(theta-thetaVector(end))/(thetaVector(1)+2*pi-thetaVector(end))*(measurement(1)-measurement(end));
elseif ind == 1
    u = measurement(1)+(theta-thetaVector(1))/(thetaVector(end)-2*pi-thetaVector(1))*(measurement(end)-measurement(1));
else
    u = measurement(ind-1)+(theta-thetaVector(ind-1))/(thetaVector(ind)+-thetaVector(ind-1))*(measurement(ind)-measurement(ind-1));
end