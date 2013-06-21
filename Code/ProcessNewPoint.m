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
    
    Dx = max(Sequence(:,1)) - min(Sequence(:,1));
    Dy = max(Sequence(:,2)) - min(Sequence(:,2));
    for i=1:size(RecState.MinScoreTable,2)
        for j=i+1:min(i+RecParams.MaxIndecisiveCandidates,size(RecState.MinScoreTable,1))
            startPoint = RecState.CandidatePointsArray(i);
            endPoint = RecState.CandidatePointsArray(j);
            subSequence = RecState.Sequence(startPoint:endPoint,:);
            dx = max(subSequence(:,1)) - min(subSequence(:,1));
            dy = max(subSequence(:,2)) - min(subSequence(:,2));
            if (Dx*Dy>25*dx*dy)
                RecState.MinScoreTable(j,i) = 1.5*RecState.MinScoreTable(j,i);
            end
            
            if (j>i+2)
                RecState.MinScoreTable(j,i) = 1.5*RecState.MinScoreTable(j,i);
            end
        end
    end
    
    if (length(RecState.CandidatePointsArray)>4)
        CandidatePoints = [];
        for i=2:length(RecState.CandidatePointsArray)-1
            CandidatePoints = [CandidatePoints;Sequence(RecState.CandidatePointsArray(i),:)];
        end
        % p = polyfit(CandidatePoints(:,1),CandidatePoints(:,2),1);
        %PC = princomp(Sequence);
        %PC = PC(:,1);
        %slope=PC(2)/PC(1);
        
        [hi,cen] = hist(Sequence(:,2),10);
        [~,maxBin] = max(hi);
        maxBinPosition = cen(maxBin);
        for j=1:length(CandidatePoints)
            %p = [slope,0];
            %yfit = polyval(p,CandidatePoints(j,1));
            if (abs(maxBinPosition-CandidatePoints(j,2))>2*(max(cen(2)-cen(1),0.15)))
                RecState.MinScoreTable(:,j+1) = NaN;
                RecState.MinScoreTable(j+1,:) = NaN;
            end
        end
    end
    
    
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
    j=1;
    sumI = 0;
    traversalTable = RecState.MinScoreTable;
    while (find(~isnan(traversalTable)))
        [endI,startI]=find(traversalTable==min(min(traversalTable)));
        SPI(i) = startI;
        SPI(i+1) = endI;
        sumI = sumI + traversalTable(endI,startI);
        i=i+2;
        j=j+1;
        for k=startI:endI-1
            traversalTable(:,k) = NaN;
        end
        
        for k=startI+1:endI
            traversalTable(k,:) = NaN;
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
        
        [absoluteSiplifiedContour,proportionalSiplifiedContour] = SimplifyContour(Sequence(1:CurrPoint,:));
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
        
        [RecState,midPoint] = TryMergeCandidatePoints(RecState,midPoint);
        RecState = UpdateRecognitionTable(RecState,midPoint,RecParams,IsMouseUp);
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%    HELPER FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [RecState, newPoint] = TryMergeCandidatePoints(RecState,midPoint)
lastPointIndex = RecState.CandidatePointsArray(end);
newPoint = midPoint;
if (lastPointIndex==1)
    return;
end
sequence  = RecState.Sequence;

Res = ContainsInformation(sequence,lastPointIndex, midPoint);
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
    Res = ContainsInformation(ProcessedSequence,1, size(ProcessedSequence,1));
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
    Res = ContainsInformation(OrigSequence,LCP, currentPoint);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Res = IsClosingHS(ProcessedSequence, lowSlope,RecState,RecParams)

processedCurrPont = size(ProcessedSequence,1);
Res = RecState.HSStart~=-1 && (~lowSlope || (ProcessedSequence(processedCurrPont,1)>ProcessedSequence(processedCurrPont-1,1)));

OrigSequence = RecState.Sequence;
currentPoint = size(OrigSequence,1);
if (Res==false && RecState.HSStart~=-1)
    Res = ContainsInformation(OrigSequence,RecState.HSStart, currentPoint);
end

if (Res == false && RecState.HSStart~=-1)
    Slope = CalculateSlope(OrigSequence,RecState.HSStart,currentPoint);
    Res = ~LowSlope(Slope,RecParams);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Res = ContainsInformation(Sequence,startPoint, endPoint)

[abs] = SimplifyContour(Sequence(startPoint:endPoint,:));
Res = true;

if (size(abs,1)==2)
    Res = false;
end
if (size(abs,1)>3)
    Res=true;
end
if (size(abs,1)==3)
    v1 = abs(1,:)-abs(2,:);
    v2 = abs(3,:)-abs(2,:);
    theta = acos(dot(v1,v2)/(norm(v1)*norm(v2)));
    if (theta>(5*pi/6))
        Res = false;
    else
        Res = true;
    end
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

function Res = IsOnBaseline(RecState,RecParams)
Sequence = RecState.Sequence;
CurrPoint = size(RecState.Sequence,1);

Res = true;
if (RecState.LCCPI<2)
    return;
else
    CCParr =[];
    for i=1:RecState.LCCPI
        CCPI = RecState.CriticalCPs(i).Point;
        CCParr = [CCParr;Sequence(CCPI,:)];
    end
    if (~isempty(RecState.CandidateCP) && RecState.LCCPI>1)
        CCParr = [CCParr;Sequence(RecState.CandidateCP.Point,:)];
    end
    p = polyfit(CCParr(:,1),CCParr(:,2),1);
    yfit = polyval(p,Sequence(CurrPoint,1));
    %%%% Activate to see the baseline %%%%%%%
    %     figure
    %     scatter(Sequence(:,1),Sequence(:,2))
    %     t = (Sequence(1,1):-0.001:Sequence(CurrPoint,1));
    %     y = p(1)*t+p(2);
    %     hold on;
    %     plot(t,y)
    %     hold off;
    %     abs(yfit-Sequence(CurrPoint,2))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (abs(yfit-Sequence(CurrPoint,2))>RecParams.MaxDistFromBaseline)
        Res = false;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MidPoint = CalcuateHSMidPoint(HS)
MidPoint = round((HS(1)+HS(2))/2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LCCPP,LetterPosition]  = CalculateLCCP(RecState)
if ( RecState.LCCPI == 0)
    LCCPP = 1;
    if (nargout>1)
        LetterPosition = 'Ini';
    end
else
    LCCPP = RecState.CriticalCPs(RecState.LCCPI).Point;
    if (nargout>1)
        LetterPosition = 'Mid';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Point  = LastCandidatePoint(RecState)
Point = RecState.CandidatePointsArray(length(RecState.CandidatePointsArray));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RecState = DetermineSingleOrDouble (RecParams, RecState, Sequence, firstPoint, Letter1Point, Letter1Position , Letter2Point, Letter2Position, SingleLetterPosition )
Option1 = CreateOptionDouble(RecParams,Sequence,firstPoint,Letter1Point,Letter1Position,Letter1Point,Letter2Point,Letter2Position);
Option2 = CreateOptionSingle(RecParams,Sequence,firstPoint,Letter2Point,SingleLetterPosition);
Res = BetterOption(firstPoint, Option1, Option2, Sequence);
if (Res==1)
    RecState = AddCriticalPoint(RecState,Sequence,Option1.FirstPoint);
    RecState = AddCriticalPoint(RecState,Sequence,Option1.SecondPoint);
    
else
    RecState = AddCriticalPoint(RecState,Sequence,Option2.FirstPoint);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Option = CreateOptionDouble(RecParams,Sequence,Start1,End1,Position1,Start2,End2,Position2)
Option.OptionType = 'Double';
FirstPoint = CreateCheckPoint (RecParams,Sequence,Start1,End1,Position1);
Option.FirstPoint =  FirstPoint;
SecondPoint = CreateCheckPoint (RecParams,Sequence,Start2,End2,Position2);
Option.SecondPoint =  SecondPoint;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Option = CreateOptionSingle(RecParams,Sequence,Start,End,Position)
Option.OptionType = 'Single';
FirstPoint = CreateCheckPoint (RecParams,Sequence,Start,End,Position);
Option.FirstPoint =  FirstPoint;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BO = BetterOption(startPoint, DoubleLetterOption, SingleLetterOption, Sequence)

Double_FirstLetterMin = CalculateAvgCandidatesDistane (DoubleLetterOption.FirstPoint);
Double_SecondLetterMin = CalculateAvgCandidatesDistane (DoubleLetterOption.SecondPoint);

DoubleAvgDist = (Double_FirstLetterMin+Double_SecondLetterMin)/2;
SingleAvgDist = CalculateAvgCandidatesDistane (SingleLetterOption.FirstPoint);

%Condition = Double_FirstLetterMin<=SingleAvgDist && Double_SecondLetterMin<=SingleAvgDist;

subsequence1 = Sequence(startPoint:DoubleLetterOption.FirstPoint.Point,:);
subsequence2 = Sequence(DoubleLetterOption.FirstPoint.Point:size(Sequence,1),:);
sequence = Sequence(startPoint:size(Sequence,1),:);

sequenceLength  = SequenceLength ( sequence );
subSequenceLength1  = SequenceLength( subsequence1 );
subSequenceLength2  = SequenceLength( subsequence2 );

Condition2 = sequenceLength>5*subSequenceLength1 || sequenceLength>5*subSequenceLength2;

[abs] = SimplifyContour(subsequence2);
if (size(abs,1)<3)
    Condition2=true;
end

if (DoubleAvgDist<SingleAvgDist && ~Condition2)
    BO=1;
else
    BO=2;
end

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
function RecState = RecognizeAndAddCriticalPoint(RecParams,Sequence,RecState,StartPoint,EndPoint,LetterPos)
WarpedPoint= CreateCheckPoint (RecParams,Sequence,StartPoint,EndPoint,LetterPos);
RecState = AddCriticalPoint(RecState,Sequence,WarpedPoint);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = AddCriticalPoint(RecState,Sequence,WrappedPoint)
RecState.CriticalCPs = [RecState.CriticalCPs;WrappedPoint];
RecState.LCCPI = RecState.LCCPI + 1;
MarkOnSequence('CriticalCP',Sequence,WrappedPoint.Point);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BCP = BetterCP (CP1,CP2)
AvgCP1 = CalculateAvgCandidatesDistane(CP1);
AvgCP2 = CalculateAvgCandidatesDistane(CP2);
if (AvgCP1<AvgCP2)
    BCP = CP1;
else
    BCP = CP2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Avg = CalculateAvgCandidatesDistane (CandidateCP)
NumCandidates = size(CandidateCP.Candidates,1);
arr = [];
for k=1:NumCandidates
    arr = [arr;CandidateCP.Candidates{k,2}];
end
Avg = min (arr);
%Avg = mean (arr);

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
