function [AngsOfCont] = MSC(cont)
cont = NormalizeCont(cont);
C = mean(cont);
W = max(cont(:,1)) - min(cont(:,1));
H = max(cont(:,2)) - min(cont(:,2));
%Up = max(W,H);
% UL = [min(cont(:,1))  min(cont(:,2)) ];
% UR = [max(cont(:,1))  min(cont(:,2)) ];
% BL = [min(cont(:,1))  max(cont(:,2)) ];
% BR = [max(cont(:,1))  max(cont(:,2)) ];
% CC = UL+ [0.5*W 0.5*H];

BL = [min(cont(:,1))  min(cont(:,2)) ];
BR = [max(cont(:,1))  min(cont(:,2)) ];
UL = [min(cont(:,1))  max(cont(:,2)) ];
UR = [max(cont(:,1))  max(cont(:,2)) ];
CC = BL+ [0.5*W 0.5*H];


NumofSteps=5;
StepX = W/NumofSteps;
StepY = H/NumofSteps;

Up = (H+W);

[l,c] = size(cont);
%ShiftCont = cont(2:l,:) ;
%ShiftCont(l,:) = cont(l,:) ;
Points = zeros(4*NumofSteps+1,2);
Points(1,:) = C;
for i=1:NumofSteps
    Points(i+1,:) = UL + [(i-1)*StepX  0];
    Points(i+NumofSteps+1,:) = UR + [0 (i-1)*StepY ];
    Points(i+2*NumofSteps+1,:) = BR - [(i-1)*StepX 0];
    Points(i+3*NumofSteps+1,:) = BL - [0 (i-1)*StepY];
end

AngsOfCont = zeros(4*NumofSteps+1,l);
    
for k=1:4*NumofSteps+1
    for i = 1:l
    %u1 = cont(i-1,:);
        u = cont(i,:);
        
        A = atan(ComputeDist(u,Points(k))/Up);

        AngsOfCont(k,i) = A*180/pi;
        AngsOfCont(k,i) = (AngsOfCont(k,i) ^3)/1000 ;
        
    end   
end
AngsOfCont =AngsOfCont';
end