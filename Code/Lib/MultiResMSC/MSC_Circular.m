function [AngsOfCont] = MSC_Circular(cont)
cont = NormalizeCont(cont);
C = mean(cont);

[l,c] = size(cont);

W = max(cont(:,1)) - min(cont(:,1));
H = max(cont(:,2)) - min(cont(:,2));
%Up = max(W,H);
UL = [min(cont(:,1))  min(cont(:,2)) ];

%l=l+4;
NumofSteps=12;

Step = 2*pi/NumofSteps;
Up = max(W,H);

%ShiftCont = cont(2:l,:) ;
%ShiftCont(l,:) = cont(l,:) ;
Points = zeros(NumofSteps+1,2);
Points(1,:) = C;
if (H == 0.0)
    H=0;
end
if (W == 0.0)
    H=0;
end


for i=1:NumofSteps
    Alpha = i*Step;
    Points(i+1,:) = [sin(Alpha)*H cos(Alpha)*W] +[H W];
end

AngsOfCont = zeros(NumofSteps,l);
    
for k=1:NumofSteps+1
    for i = 1:l
    %u1 = cont(i-1,:);
        u = cont(i,:);
        
        %A = atan(ComputeDist(u,Points(k))/Up);
        A = atan(ComputeDist(u,Points(k))/Up);
        AngsOfCont(k,i) = A*180/pi;
        AngsOfCont(k,i) = (AngsOfCont(k,i) ^3)/1000 ;
        
    end   
end

AngsOfCont =AngsOfCont';
end