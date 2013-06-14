function [AngsOfCont] = MSCRing(cont)
C = mean(cont);
W = max(cont(:,1)) - min(cont(:,1));
H = max(cont(:,2)) - min(cont(:,2));
Up = max(W,H);
UL = [min(cont(:,1))  min(cont(:,2)) ];
UR = [max(cont(:,1))  min(cont(:,2)) ];
BL = [min(cont(:,1))  max(cont(:,2)) ];
BR = [max(cont(:,1))  max(cont(:,2)) ];
CC = UL+ [0.5*W 0.5*H];

NumofSteps=12;
StepAlpha = 2*pi/NumofSteps;




[l,c] = size(cont);
%ShiftCont = cont(2:l,:) ;
%ShiftCont(l,:) = cont(l,:) ;
Points = zeros(NumofSteps*2+1,2);
Points(1,:) = C;
Alpha=0;
Up= sqrt(Up);
for i=1:NumofSteps
    Alpha = Alpha + StepAlpha;
    x = Up*cos(Alpha);
    y = Up*sin(Alpha);
    Points(2*i+1,:) = C + [x y];
    x = Up^2*cos(Alpha);
    y = Up^2*sin(Alpha);
    Points(2*i,:) = C + [x y];
end

AngsOfCont = zeros(2*NumofSteps+1,l);
Up = Up^3;    
for k=1:2*NumofSteps+1
    for i = 1:l
    %u1 = cont(i-1,:);
        u = cont(i,:);
        
        A = atan(ComputeDist(u,Points(k))/Up);

        AngsOfCont(k,i) = A*180/pi;
    end   
end

AngsOfCont =AngsOfCont';
 
end