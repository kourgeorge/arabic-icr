function [AngsOfCont] = MSC_Ring(cont, ringAltitude, numOfSteps, ringRadius)
%MSC_Ring Computes the MSC feature from a single resolution.
%   Detailed explanation goes here

C = mean(cont);
l = size(cont,1);
Step = 2*pi/numOfSteps;

Points = zeros(numOfSteps+1,2);
Points(1,:) = C;

% Create Views 
for i=1:numOfSteps
    Alpha = i*Step;
    Points(i+1,:) = [sin(Alpha)*ringRadius cos(Alpha)*ringRadius] + C;
end


AngsOfCont = zeros(numOfSteps+1,l);
for k=1:numOfSteps+1
    for i = 1:l
        u = cont(i,:);
        A = atan(ComputeDist(u,Points(k))/ringAltitude);
        AngsOfCont(k,i) = A*180/pi;
        AngsOfCont(k,i) = (AngsOfCont(k,i) ^3)/1000 ;
    end   
end

AngsOfCont =AngsOfCont';

end