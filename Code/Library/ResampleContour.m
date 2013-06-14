function [ResCont] = ResampleContour(cont,NumofPoints)

% Perform resampling using splines.
cont = ResampleSequence( cont, NumofPoints*3 );

FirstCont = cont;
[l,c] = size(FirstCont);
step = l/NumofPoints;
ResCont = zeros(NumofPoints,c);
for i=1:NumofPoints
    nextP =  max(floor(i*step),1);
    ResCont(i,:) = FirstCont(nextP,:);
end
end

