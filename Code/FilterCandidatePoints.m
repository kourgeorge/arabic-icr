function [ RecState ] = FilterCandidatePoints( RecState )
%FILTERCANDIDATEPOINTS Summary of this function goes here
%   Detailed explanation goes here

% 1. Filter in loops
% 2. Filter ajecent candidate points that there is no info berween them
% 3. 

%     Dx = max(Sequence(:,1)) - min(Sequence(:,1));
%     Dy = max(Sequence(:,2)) - min(Sequence(:,2));
%     for i=1:size(RecState.MinScoreTable,2)
%         for j=i+1:min(i+RecParams.MaxIndecisiveCandidates,size(RecState.MinScoreTable,1))
%             startPoint = RecState.CandidatePointsArray(i);
%             endPoint = RecState.CandidatePointsArray(j);
%             subSequence = RecState.Sequence(startPoint:endPoint,:);
%             dx = max(subSequence(:,1)) - min(subSequence(:,1));
%             dy = max(subSequence(:,2)) - min(subSequence(:,2));
%             if (Dx*Dy>25*dx*dy)
%                 RecState.MinScoreTable(j,i) = 1.5*RecState.MinScoreTable(j,i);
%             end
%
%             if (j>i+2)
%                 RecState.MinScoreTable(j,i) = 1.5*RecState.MinScoreTable(j,i);
%             end
%         end
%     end
%
if (length(RecState.CandidatePointsArray)>4)
    CandidatePoints = [];
    for i=2:length(RecState.CandidatePointsArray)-1
        CandidatePoints = [CandidatePoints;RecState.Sequence(RecState.CandidatePointsArray(i),:)];
    end
    [hi,cen] = hist(RecState.Sequence(:,2),10);
    [~,maxBin] = max(hi);
    maxBinPosition = cen(maxBin);
    for j=1:length(CandidatePoints)
        if (abs(maxBinPosition-CandidatePoints(j,2))>2*(max(cen(2)-cen(1),0.15)))
            RecState.MinScoreTable(:,j+1) = NaN;
            RecState.MinScoreTable(j+1,:) = NaN;
        end
    end
end


end

