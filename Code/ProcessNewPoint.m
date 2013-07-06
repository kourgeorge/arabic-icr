function RecState = ProcessNewPoint(RecParams,RecState,Sequence,IsMouseUp,UI )
%PROCESSNEWPOINT Summary of this function goes here
%   Detailed explanation goes here
global gUI;
gUI = UI;

CurrPoint = length(Sequence);
RecState.Sequence=Sequence;

if(IsMouseUp==true)
    
    if (size(Sequence,1)<2 || SequenceLength(Sequence) < 0.03)
        CheckPoint.Point = size(Sequence,1);
        CheckPoint.Sequence = Sequence;
        return
    end
    
    
    RecState = UpdateRecognitionTable(RecState,CurrPoint,RecParams,IsMouseUp);
    RecState.MinScoreTable(RecState.MinScoreTable==0) = NaN;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Filter Candidates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
%     if (length(RecState.CandidatePointsArray)>4)
%         CandidatePoints = [];
%         for i=2:length(RecState.CandidatePointsArray)-1
%             CandidatePoints = [CandidatePoints;Sequence(RecState.CandidatePointsArray(i),:)];
%         end
%         % p = polyfit(CandidatePoints(:,1),CandidatePoints(:,2),1);
%         %PC = princomp(Sequence);
%         %PC = PC(:,1);
%         %slope=PC(2)/PC(1);
%         
%         [hi,cen] = hist(Sequence(:,2),10);
%         [~,maxBin] = max(hi);
%         maxBinPosition = cen(maxBin);
%         for j=1:length(CandidatePoints)
%             %p = [slope,0];
%             %yfit = polyval(p,CandidatePoints(j,1));
%             if (abs(maxBinPosition-CandidatePoints(j,2))>2*(max(cen(2)-cen(1),0.15)))
%                 RecState.MinScoreTable(:,j+1) = NaN;
%                 RecState.MinScoreTable(j+1,:) = NaN;
%             end
%         end
%     end
%     
%     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start to end traversal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    k = 1;
    i = 1;
    sumForward = 0;
    while (k<=size(RecState.MinScoreTable,2))
        [~,minIndex] = min (RecState.MinScoreTable(:,k));
        SegmentationPointsForward(i) = RecState.RecognitionScoreTable(minIndex,k);
        sumForward = sumForward + RecState.MinScoreTable(minIndex,k);
        SPF(i) = RecState.RecognitionScoreTable{minIndex,k}.Point;
        i=i+1;
        k=minIndex;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end to start traversal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    k = size(RecState.MinScoreTable,1);
    i = 1;
    sumBackward = 0;
    while (k>1)
        [~,minIndex] = min (RecState.MinScoreTable(k,:));
        SegmentationPointsBackwards(i) = RecState.RecognitionScoreTable(k,minIndex);
        sumBackward = sumBackward + RecState.MinScoreTable (k,minIndex);
        SPB(i) = RecState.RecognitionScoreTable{k,minIndex}.Point;
        i=i+1;
        k=minIndex;
    end
    
    SPB = fliplr(SPB);
    SegmentationPointsBackwards = fliplr(SegmentationPointsBackwards);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inteligant traversal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    i=1;
    sumI = 0;
    traversalTable = RecState.MinScoreTable;
    while (find(~isnan(traversalTable)))
        [endI,startI]=find(traversalTable==min(min(traversalTable)));
        SPI(i) = startI;
        SPI(i+1) = endI;
        sumI = sumI + traversalTable(endI,startI);
        i=i+2;
        for k=startI:endI-1
            traversalTable(:,k) = NaN;
        end
        
        for k=startI+1:endI
            traversalTable(k,:) = NaN;
        end
        
        for c=1:startI
            traversalTable(endI:end,c)=NaN;
        end
    end
    SPI = unique(SPI);
    for i=1:length(SPI)-1
        SegmentationPointsInteligent(i) = RecState.RecognitionScoreTable(SPI(i+1),SPI(i));
    end
    
    for i=1:length(SegmentationPointsInteligent)
        SP(i) = SegmentationPointsInteligent{i}.Point;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inteligant traversal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    [~,indx] = min([sumI/(length(SP)),sumForward/(length(SPF)),sumBackward/(length(SPB))]);
    FinalSegmentation = [{SegmentationPointsInteligent},{SegmentationPointsForward},{SegmentationPointsBackwards}];
    
    RecState.SegmentationPoints = FinalSegmentation{indx};
    
    for i=1:length(RecState.SegmentationPoints)
        MarkOnSequence('SegmentationPoint',Sequence,RecState.SegmentationPoints{i}.Point);
    end
    
else    %Mouse not up
    if (rem(CurrPoint,RecParams.K)==0)
        
        [absoluteSiplifiedContour,proportionalSiplifiedContour] = SimplifyContour(Sequence(1:CurrPoint,:), RecParams.AbsoluteSimplificationEpsilon);
        resampledSequence = ResampleContour(proportionalSiplifiedContour,size(absoluteSiplifiedContour,1)*5);
        resSeqLastPoint = size(resampledSequence,1);
        Slope = CalculateSlope(resampledSequence,resSeqLastPoint-RecParams.PointEnvLength,resSeqLastPoint);
        SlopeRes = LowSlope(Slope,RecParams);
        
        %Update Horizontal Point
        if (RecState.HSStart ~= -1 && SlopeRes && resampledSequence(resSeqLastPoint,1)<resampledSequence(resSeqLastPoint-1,1))
            RecState.LastSeenHorizontalPoint = CurrPoint;
        end
        
        %Handle horizontal Segments
        if(IsFirstPointInHS(resampledSequence,SlopeRes,RecState,RecParams))
            RecState = StartNewHS(CurrPoint-1,RecState);
            MarkOnSequence('StartHorizontalIntervalPoint',Sequence,CurrPoint);
            return;
        elseif (IsClosingHS(resampledSequence,SlopeRes,RecState,RecParams))
            [HS,RecState] = EndHS(RecState,RecParams);
            midPoint=CalcuateHSMidPoint(HS);
        else
            return;
        end
        
        [RecState,midPoint] = TryMergeCandidatePoints(RecState,midPoint,RecParams);
        RecState = UpdateRecognitionTable(RecState,midPoint,RecParams,IsMouseUp);
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%    HELPER FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [RecState, newPoint] = TryMergeCandidatePoints(RecState, midPoint, RecParams)
lastPointIndex = RecState.CandidatePointsArray(end);
newPoint = midPoint;
if (lastPointIndex==1)
    return;
end
sequence  = RecState.Sequence;

Res = ContainsInformation(sequence,lastPointIndex, midPoint, RecParams);
if (Res==false)
    HS = [RecState.CandidatePointsArray(end),midPoint];
    newPoint=CalcuateHSMidPoint(HS);
    RecState.CandidatePointsArray = RecState.CandidatePointsArray(1:end-1);
    MarkOnSequence('MergedCandidatePoint',RecState.Sequence,newPoint);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HS means Horiontal Sections.
function Res = IsFirstPointInHS(ProcessedSequence,lowSlope,RecState,RecParams)

Res = RecState.HSStart == -1 && lowSlope && ProcessedSequence(end,1)<ProcessedSequence(end-1,1);
if(Res==true)
    Res = ContainsInformation(ProcessedSequence,1, size(ProcessedSequence,1),RecParams);
end
if (Res==true)
    %    Res = Res && IsOnBaseline(RecState,RecParams);
end
OrigSequence = RecState.Sequence;
LCP = LastCandidatePoint(RecState);
% if (Res==true)
%     minX = min(OrigSequence(LCP:end-5,1));
%     if (minX<OrigSequence(end,1))
%         Res = false;
%     end
% end
currentPoint = size(OrigSequence,1);
if (Res==true)
    Res = ContainsInformation(OrigSequence,LCP, currentPoint, RecParams);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Res = IsClosingHS(ProcessedSequence, lowSlope,RecState,RecParams)

processedCurrPont = size(ProcessedSequence,1);
Res = RecState.HSStart~=-1 && (~lowSlope || (ProcessedSequence(processedCurrPont,1)>ProcessedSequence(processedCurrPont-1,1)));

OrigSequence = RecState.Sequence;
currentPoint = size(OrigSequence,1);
if (Res==false && RecState.HSStart~=-1)
    Res = ContainsInformation(OrigSequence,RecState.HSStart, currentPoint, RecParams);
end

if (Res == false && RecState.HSStart~=-1)
    Slope = CalculateSlope(OrigSequence,RecState.HSStart,currentPoint);
    Res = ~LowSlope(Slope,RecParams);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Res = ContainsInformation(Sequence,startPoint, endPoint, RecParams)

if (InformationMeasure( Sequence(startPoint:endPoint,:), RecParams.AbsoluteSimplificationEpsilon )>1)
    Res = true;
else
    Res = false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = UpdateRecognitionTable(RecState,midPoint,RecParams,IsMouseUp)

RecState.CandidatePointsArray = [RecState.CandidatePointsArray,midPoint];
newPointIndex = size(RecState.CandidatePointsArray,2);
CandidatePointsArray = RecState.CandidatePointsArray;

ScoreTable = RecState.RecognitionScoreTable;
minTable = RecState.MinScoreTable;
for i=max(1,newPointIndex-RecParams.MaxIndecisiveCandidates):newPointIndex-1
    if (IsMouseUp)
        if (i == 1) Pos = 'Iso'; else Pos = 'Fin'; end
    else
        if (i == 1) Pos = 'Ini'; else Pos = 'Mid'; end
    end
    c = CreateCheckPoint (RecParams,RecState.Sequence,CandidatePointsArray(i),CandidatePointsArray(newPointIndex),Pos);
    Candidates = c.Candidates;
    minTable(newPointIndex,i) = min ([Candidates{:,2}]);
    ScoreTable(newPointIndex,i)= {c};
end
RecState.RecognitionScoreTable = ScoreTable;
RecState.MinScoreTable = minTable;
MarkOnSequence('CandidatePoint',RecState.Sequence,midPoint);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = StartNewHS(CurrPoint,RecState)
RecState.HSStart = CurrPoint;
RecState.LastSeenHorizontalPoint = CurrPoint;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [HS,RecState] = EndHS(RecState,RecParams)
HS = [RecState.HSStart,size(RecState.Sequence,1)-RecParams.K];
RecState.HSStart = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MidPoint = CalcuateHSMidPoint(HS)
MidPoint = round((HS(1)+HS(2))/2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Point  = LastCandidatePoint(RecState)
Point = RecState.CandidatePointsArray(length(RecState.CandidatePointsArray));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckPoint = CreateCheckPoint (RecParams,Sequence,StartPoint,EndPoint,Position)
global LettersDataStructure;
SubSeq = Sequence(StartPoint:EndPoint,:);
RecognitionResults = RecognizeSequence(SubSeq , RecParams, Position, LettersDataStructure);
CheckPoint.Point = EndPoint;
CheckPoint.Candidates = RecognitionResults;
CheckPoint.Sequence = SubSeq;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = LowSlope(Slope,RecParams)
res = Slope<RecParams.MaxSlopeRate && Slope>=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%    PRINTING/TEST FUNCTIONS   %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MarkOnSequence(Type,Sequence,Point)
global gUI;
if (gUI==true)
    switch Type
        case 'CandidatePoint',
            plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'c.-','Tag','SHAPE','LineWidth',5);
            return;
        case 'SegmentationPoint'
            plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'r.-','Tag','SHAPE','LineWidth',5);
            return;
        case 'StartHorizontalIntervalPoint'
            %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'g.-','Tag','SHAPE','LineWidth',5);
            return;
        case 'EndHorizontalIntervalPoint'
            %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'k.-','Tag','SHAPE','LineWidth',5);
            return;
        case 'MergedCandidatePoint'
            plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'k.-','Tag','SHAPE','LineWidth',5);
            return;
        otherwise
            return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
