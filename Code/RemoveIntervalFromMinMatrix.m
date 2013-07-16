function minScoresTable = RemoveIntervalFromMinMatrix(minScoresTable, startI, endI) 
%REMOVEINTERVALFROMMINMATRIX Summary of this function goes here
%   Detailed explanation goes here

for k=startI:endI-1
    minScoresTable(:,k) = NaN;
end

for k=startI+1:endI
    minScoresTable(k,:) = NaN;
end

for c=1:startI
    minScoresTable(endI:end,c)=NaN;
end

end

