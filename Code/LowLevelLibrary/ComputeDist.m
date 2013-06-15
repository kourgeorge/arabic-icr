function [Dist] = ComputeDist(V1,V2)
V1 = V1(:);
V2 = V2(:);
Dist = norm(V1 - V2, 2);
end