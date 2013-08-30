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
    
    RecState = TryMergeLastPoint(RecState, CurrPoint, RecParams);
    
    RecState = UpdateRecognitionTable(RecState,CurrPoint,RecParams,IsMouseUp);
    
    RecState.MinScoreTable(RecState.MinScoreTable==0) = NaN;
    
    [ RecState ] = FilterCandidatePoints( RecState );
    
    [ SegmentationPointsForward, sumForward, FSPs] = ForwardSegmentationSelection( RecState.MinScoreTable,  RecState.RecognitionScoreTable);
    [ SegmentationPointsBackwards, sumBackward, BSPs] = BackwardSegmentationSelection( RecState.MinScoreTable,  RecState.RecognitionScoreTable);
    [ SegmentationPointsGreedy, sumGreedy, GSPs] = GreedySegmentationSelection( RecState.MinScoreTable,  RecState.RecognitionScoreTable); 
    [ SegmentationPointsYA, sumYA, YASPs] = YASegmentationSelection( RecState.MinScoreTable,  RecState.RecognitionScoreTable);

    ScoreForward = sumForward/(length(SegmentationPointsForward));
    ScoreBackwards = sumBackward/(length(SegmentationPointsBackwards));
    ScoreGreedy = sumGreedy/(length(SegmentationPointsGreedy));
    ScoreYA = sumYA/(length(SegmentationPointsYA));
    
    [~,bestSegmentationindex] = min([ScoreForward,ScoreBackwards,ScoreGreedy,ScoreYA]);
    AllSegmentations = [{SegmentationPointsForward},{SegmentationPointsBackwards},{SegmentationPointsGreedy},{SegmentationPointsYA}];
    
    RecState.SegmentationPoints = AllSegmentations{bestSegmentationindex};
    
    for i=1:length(RecState.SegmentationPoints)
        MarkOnSequence('SegmentationPoint',Sequence,RecState.SegmentationPoints{i}.Point);
    end
    
    
else    %Mouse not up
    if (rem(CurrPoint,RecParams.K)==0)
        
        resampledSequence = ResampleContour(Sequence,round(size(Sequence,1)/2));
        
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
            midPoint=CalcuateHSMidPoint(HS,RecState);
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
lastPointIndex = LastCandidatePoint(RecState);
newPoint = midPoint;
if (lastPointIndex==1)
    return;
end
sequence  = RecState.Sequence;

Res = ContainsInformation(sequence,lastPointIndex, midPoint, RecParams);
if (Res==false)
    HS = [RecState.CandidatePointsArray(end),midPoint];
    newPoint=CalcuateHSMidPoint(HS,RecState);
    RecState.CandidatePointsArray = RecState.CandidatePointsArray(1:end-1);
    MarkOnSequence('MergedCandidatePoint',RecState.Sequence,newPoint);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = TryMergeLastPoint (RecState, lastPoint, RecParams)
LastCandidate = LastCandidatePoint(RecState);
if (LastCandidate==1)
    return;
end
Res = ContainsInformation(RecState.Sequence,LastCandidate, lastPoint, RecParams);
if (Res==false)
    RecState.CandidatePointsArray = RecState.CandidatePointsArray(1:end-1);
    MarkOnSequence('MergedCandidatePoint',RecState.Sequence,lastPoint);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HS means Horiontal Sections.
function Res = IsFirstPointInHS(ProcessedSequence,lowSlope,RecState,RecParams)

Res = RecState.HSStart == -1 && lowSlope && ProcessedSequence(end,1)<ProcessedSequence(end-1,1);

if(Res==true)
    Res = ContainsInformation(ProcessedSequence,1, size(ProcessedSequence,1),RecParams);
end

OrigSequence = RecState.Sequence;
LCP = LastCandidatePoint(RecState);

% currentPoint = size(OrigSequence,1);
% if (Res==true)
%     Res = ContainsInformation(OrigSequence,LCP, currentPoint, RecParams);
% end

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

% We need to try closing the HF only after the there is no intersection, to
% minimize the effrct of
% OrigSequence = RecState.Sequence;
% LCP = LastCandidatePoint(RecState);
% if (Res==true)
%     minX = min(OrigSequence(LCP:end-5,1));
%     if (minX<OrigSequence(end,1))
%         Res = false;
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Res = ContainsInformation(Sequence,startPoint, endPoint, RecParams)

if (InformationMeasure( Sequence(startPoint:endPoint,:), RecParams.AbsoluteSimplificationEpsilon, RecParams.MaxSlopeRate  )>1)
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
function MidPoint = CalcuateHSMidPoint(HS,RecState)
if (HS(2)-HS(1)==1)
    MidPoint = HS(2);
    return;
end
originalHS = RecState.Sequence(HS(1):HS(2),:);
resampledSequence = ResampleContour(originalHS,5);
mid = resampledSequence(3,:);
D = pdist2(originalHS,mid,'euclidean');
[~,centerIndex] = min(D);
MidPoint = HS(1) + centerIndex;

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
            plot(findobj('Tag','AXES'),Sequence(Point-2:Point,1),Sequence(Point-2:Point,2),'g.-','Tag','SHAPE','LineWidth',5);
            return;
        otherwise
            return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
