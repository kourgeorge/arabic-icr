function Dist = ERPContXY( s1 , s2 )
%ERP Summary of this function goes here
%   Usage:
%           a = dlmread(['C:\OCRData\GeneratedWordsMed\sample2\_8_.m']);
%           b = dlmread(['C:\OCRData\GeneratedWordsMed\sample3\_8_.m']);
%           Dst = ERP( a , b )

s1 = Norm(s1);
s2 = Norm(s2);

g = [0,0];
l1 = size(s1,1);
l2 = size(s2,1);

mat = zeros(l1+1,l2+1);

mat(1,:) = inf;
mat(:,1) = inf;
mat(1,1) = 0;
for i=2:l1+1
    for j=2:l2+1
        p1 = mat(i-1,j-1)+ DISTerp(s1(i-1,:),s2(j-1,:));
        p2 = mat(i,j-1)+ DISTerp(s1(i-1,:),g);
        p3 = mat(i-1,j)+ DISTerp(s2(j-1,:),g);
        mat(i,j) = min ([p1,p2,p3]);
    end
end
Dist = mat(l1+1,l2+1);
end

function R = Rest (Sequence)
R = Sequence(2:end,:);
end

function d = DISTerp (r,s)
    d = lpnorm(r',s',1);
end

function NormS = Norm (Seq)
MeanXY = mean(Seq);
s = std(Seq);
NormS = Seq - repmat(MeanXY,size(Seq,1),1);
NormS(:,1) = NormS(:,1)/s(1);
NormS(:,2) = NormS(:,2)/s(2);
end

