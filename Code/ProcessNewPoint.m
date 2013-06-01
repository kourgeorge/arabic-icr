function RecState = ProcessNewPoint(RecParams,RecState,Sequence,IsMouseUp,UI )
%PROCESSNEWPOINT Summary of this function goes here
%   Detailed explanation goes here
global gUI;
gUI = UI;

CurrPoint = length(Sequence);
RecState.Sequence=Sequence;

if(IsMouseUp==true)
    if (RecState.LCCPI == 0)
        if (~isempty(RecState.CandidateCP))
            [IsMerged,MergedPoint] = TryToMerge(RecParams,Sequence,1,RecState.CandidateCP,CurrPoint);
            if (IsMerged)
                %[7] - CP(merged - old CP and the remainder)
                RecState = AddCriticalPoint(RecState,Sequence,MergedPoint);
            else
                %[5]- CP ->CP (of MU) => Ini, Fin || Iso
                Option1 = CreateOptionDouble(RecParams,Sequence,1,RecState.CandidateCP.Point,'Ini',RecState.CandidateCP.Point,CurrPoint,'Fin');
                Option2 = CreateOptionSingle(RecParams,Sequence,1,CurrPoint,'Iso');
                BO = BetterOption(1, Option1, Option2,RecState);
                if (BO==1)
                    %Add 2 Critical Points 'Ini','Fin'
                    RecState = AddCriticalPoint(RecState,Sequence,Option1.FirstPoint);
                    RecState = AddCriticalPoint(RecState,Sequence,Option1.SecondPoint);
                else
                    %Add 1 Critical Point 'Iso'
                    RecState = AddCriticalPoint(RecState,Sequence,Option2.FirstPoint);
                end
            end
        else
            %[6]- CP(MU) => Iso
            RecState = RecognizeAndAddCriticalPoint(RecParams,Sequence,RecState,1,CurrPoint,'Iso');
        end
    else %not the first letter
        if (~isempty(RecState.CandidateCP))
            %[1] - Critical CP -> CP -> CP (of MU)
            LCCPP = RecState.CriticalCPs(RecState.LCCPI).Point;
            Option1 = CreateOptionDouble(RecParams,Sequence,LCCPP,RecState.CandidateCP.Point,'Mid',RecState.CandidateCP.Point,CurrPoint,'Fin');
            Option2 = CreateOptionSingle(RecParams,Sequence,LCCPP,CurrPoint,'Fin');
            BO = BetterOption(LCCPP, Option1, Option2, RecState);
            if (BO==1)
                %Add 2 Critical Points 'Mid','Fin'
                RecState = AddCriticalPoint(RecState,Sequence,Option1.FirstPoint);
                RecState = AddCriticalPoint(RecState,Sequence,Option1.SecondPoint);
                
            else
                RecState = AddCriticalPoint(RecState,Sequence,Option2.FirstPoint);
            end
        else
            if (RecState.LCCPI==1)
                BLCCP.Point = 1;
            else
                BLCCP = RecState.CriticalCPs(RecState.LCCPI-1);
            end
            LCCP = RecState.CriticalCPs(RecState.LCCPI);
            [IsMerged,MergedPoint] = TryToMerge(RecParams,Sequence,BLCCP.Point,LCCP,CurrPoint);
            
            if (IsMerged)
                %[4]Critical CP -> New Critical CP(merged with remainder)
                %Remove the previous critical CP
                MarkOnSequence('CandidatePoint',Sequence,LCCP.Point);
                RecState.LCCPI = RecState.LCCPI-1;
                RecState.CriticalCPs = RecState.CriticalCPs(1:RecState.LCCPI);
                RecState = AddCriticalPoint(RecState,Sequence,MergedPoint);
            else
                %[2] - Critical CP -> CP(MU)
                RecState = RecognizeAndAddCriticalPoint(RecParams,Sequence,RecState,LCCP.Point,CurrPoint,'Fin');
            end
        end
    end
else    %Mouse not up
    if (rem(CurrPoint,RecParams.K)==0)
        
        [absoluteSiplifiedContour,proportionalSiplifiedContour] = SimplifyContour(Sequence(1:CurrPoint,:));
        resampledSequence = ResampleContour(proportionalSiplifiedContour,size(absoluteSiplifiedContour,1)*5);
        resSeqLastPoint = size(resampledSequence,1);
        
        Slope = CalculateSlope(resampledSequence,resSeqLastPoint-RecParams.PointEnvLength,resSeqLastPoint);
        SlopeRes = CheckSlope(Slope,RecParams);

        %scatter(Sequence(size(Sequence,1),1),Sequence(size(Sequence,1),2));
        
        %Update Horizontal Point
        if (RecState.HSStart ~= -1 && SlopeRes && resampledSequence(resSeqLastPoint,1)<resampledSequence(resSeqLastPoint-1,1))
            RecState.LastSeenHorizontalPoint = CurrPoint;
        end
        
        %Handle horizontal Segments
        if(IsFirstPointInHS(resampledSequence,SlopeRes,RecState,RecParams))
            RecState = StartNewHS(CurrPoint,RecState);
            MarkOnSequence('StartHorizontalIntervalPoint',Sequence,CurrPoint);
            return;
        elseif (IsClosingHS(resampledSequence,SlopeRes,RecState,RecParams))
            [HS,RecState] = EndHS(RecState);
            MarkOnSequence('EndHorizontalIntervalPoint',Sequence,RecState.LastSeenHorizontalPoint);
            midPoint=CalcuateHSMidPoint(HS);
        else
            return;
        end
        
        
        [LCCPP,LetterPosition] = CalculateLCCP(RecState);        %The execution will reach this point, only if IsClosingHS is true
        NewCheckPoint = CreateCheckPoint(RecParams,Sequence,LCCPP,midPoint,LetterPosition);
        
        if (isempty(RecState.CandidateCP))
            RecState.CandidateCP = NewCheckPoint;
            MarkOnSequence('CandidatePoint',Sequence,midPoint);
        else
            SCP = BetterCP (RecState.CandidateCP,NewCheckPoint); %SCP - Selected CheckPoint
            
            %update the Candidate point in RecState
            if (SCP.Point==RecState.CandidateCP.Point) %Candidate point was selected.
                LCCPP = RecState.CandidateCP.Point;
                RecState.CandidateCP =  CreateCheckPoint (RecParams,Sequence,LCCPP,midPoint,'Mid');
                MarkOnSequence('CandidatePoint',Sequence,midPoint);
            else
                RecState.CandidateCP = [];
            end
            % Add a new Critical Point
            RecState = AddCriticalPoint(RecState,Sequence,SCP);
            
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%    HELPER FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HS means Horiontal Sections.
function Res = IsFirstPointInHS(ProcessedSequence,Slope,RecState,RecParams)
processedCurrPont = size(ProcessedSequence,1);
[absoluteSiplifiedContour] = SimplifyContour(ProcessedSequence(1:processedCurrPont,:));  % this one is to avoid gettinf critical point on letters that start with a straight line like K and 3
Res = RecState.HSStart == -1 && Slope && ProcessedSequence(processedCurrPont,1)<ProcessedSequence(processedCurrPont-1,1) && ~(size(absoluteSiplifiedContour,1)==2);

if (Res==true)
    Res = Res && IsOnBaseline(RecState,RecParams);
end

OrigSequence = RecState.Sequence;
LCPP = CalculateLCP(RecState);


if (Res==true)
    minX = min(OrigSequence(LCPP:end-5,1));
    if (minX<OrigSequence(end,1))
        Res = false;
    end
end


if (Res==true)

    [abs] = SimplifyContour(OrigSequence(LCPP:end,:));
    if (size(abs,1)<3)
        Res = false;
    end
    if (size(abs,1)==3)
        v1 = abs(1,:)-abs(2,:);
        v2 = abs(3,:)-abs(2,:);
        theta = acos(dot(v1,v2)/(norm(v1)*norm(v2)));
        Res = (theta<(3*pi/4));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Res = IsClosingHS(ProcessedSequence, SlopeRes,RecState,RecParams)

processedCurrPont = size(ProcessedSequence,1);
Res = RecState.HSStart~=-1 && (~SlopeRes || ProcessedSequence(processedCurrPont,1)>ProcessedSequence(processedCurrPont-1,1));

OrigSequence = RecState.Sequence;
if (Res==false && RecState.HSStart~=-1)
    [abs] = SimplifyContour(OrigSequence(RecState.HSStart:end,:));
    if (size(abs,1)>2)
        Res=true;
    end
end

% OrigSequence = RecState.Sequence;
% Res = false;
% if (~SlopeRes && RecState.HSStart~=-1)
%     [abs] = SimplifyContour(OrigSequence(RecState.HSStart:RecState.LastSeenHorizontalPoint,:));
%     segmentSlope = CalculateSlope(abs,1,size(abs,1));
%     segmentSlopeRes = CheckSlope(segmentSlope,RecParams);
%     Res = segmentSlopeRes; %&& (size(abs,1)==2);
%     if (Res==false)
%         RecState.HSStart=-1;
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = StartNewHS(CurrPoint,RecState)
RecState.HSStart = CurrPoint;
RecState.LastSeenHorizontalPoint = CurrPoint;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [HS,RecState] = EndHS(RecState)
HS = [RecState.HSStart,RecState.LastSeenHorizontalPoint];
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
MidPoint = floor((HS(1)+HS(2))/2);
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
function LastCheckPoint  = CalculateLCP(RecState)

if (~isempty(RecState.CandidateCP))
    LastCheckPoint = RecState.CandidateCP.Point;
    return;
end
[LastCheckPoint,~]  = CalculateLCCP(RecState);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IsMerged,MergedPoint] = TryToMerge(RecParams,Sequence,LastCriticalPoint,Candidate,LastPoint)
global LettersDataStructure;

MergedPoint.Point = LastPoint;
SubSeq =Sequence(LastCriticalPoint:LastPoint,:);
if (LastCriticalPoint==1)
    RecognitionResults = RecognizeSequence(SubSeq , RecParams, 'Iso', LettersDataStructure);
else
    RecognitionResults = RecognizeSequence(SubSeq , RecParams, 'Fin', LettersDataStructure);
end
MergedPoint.Candidates = RecognitionResults;
MergedPoint.Sequence = SubSeq;
BCP = BetterCP (Candidate,MergedPoint);
if (BCP.Point==MergedPoint.Point)
    IsMerged = true;
else
    IsMerged = false;
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
function BO = BetterOption(startPoint, DoubleLetterOption, SingleLetterOption, RecState)

Double_FirstLetterMin = CalculateAvgCandidatesDistane (DoubleLetterOption.FirstPoint);
Double_SecondLetterMin = CalculateAvgCandidatesDistane (DoubleLetterOption.SecondPoint);

DoubleAvgDist = (Double_FirstLetterMin+Double_SecondLetterMin)/2;
SingleAvgDist = CalculateAvgCandidatesDistane (SingleLetterOption.FirstPoint);

%Condition = Double_FirstLetterMin<=SingleAvgDist && Double_SecondLetterMin<=SingleAvgDist;

Sequence = RecState.Sequence;

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
function res = CheckSlope(Slope,RecParams)
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
            %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'c.-','Tag','SHAPE','LineWidth',5);
            return;
        case 'CriticalCP'
            plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'r.-','Tag','SHAPE','LineWidth',5);
            return;
        case 'StartHorizontalIntervalPoint'
            %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'g.-','Tag','SHAPE','LineWidth',5);
            return;
        case 'EndHorizontalIntervalPoint'
            %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'k.-','Tag','SHAPE','LineWidth',5);
            return;
        otherwise
            return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
