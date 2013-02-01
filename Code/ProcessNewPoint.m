function RecState = ProcessNewPoint(RecParams,RecState,Sequence,IsMouseUp )
%PROCESSNEWPOINT Summary of this function goes here
%   Detailed explanation goes here

Alg = RecParams.Alg;
CurrPoint = length(Sequence);

if(IsMouseUp==true)
    if (RecState.LCCPI == 0)
        if (~isempty(RecState.CandidateCP))
            [IsMerged,MergedPoint] = TryToMerge(Alg,Sequence,1,RecState.CandidateCP,CurrPoint);
            if (IsMerged)
                %[7] - CP(merged - old CP and the remainder)
                RecState = AddCriticalPoint(RecState,Sequence,MergedPoint);
            else
                %[5]- CP ->CP (of MU) => Ini, Fin || Iso
                Option1 = CreateOptionDouble(Alg,Sequence,1,RecState.CandidateCP.Point,'Ini',RecState.CandidateCP.Point,CurrPoint,'Fin');
                Option2 = CreateOptionSingle(Alg,Sequence,1,CurrPoint,'Iso');
                BO = BetterOption(Option1, Option2);
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
            RecState = RecognizeAndAddCriticalPoint(Alg,Sequence,RecState,1,CurrPoint,'Iso');
        end
    else %not the first letter
        if (~isempty(RecState.CandidateCP))
            LCCP = RecState.CriticalCPs(RecState.LCCPI);
            [IsMerged,MergedPoint] = TryToMerge(Alg,Sequence,LCCP.Point,RecState.CandidateCP,CurrPoint);
            if (IsMerged)
                %[3]Critical CP -> CP(merged - old CP and the remainder)                
                RecState = AddCriticalPoint(RecState,Sequence,MergedPoint);
                %Reset the Candidate
                RecState.CandidateCP = [];
            else
                %[1] - Critical CP -> CP -> CP (of MU)
                LCCPP = RecState.CriticalCPs(RecState.LCCPI).Point;
                Option1 = CreateOptionDouble(Alg,Sequence,LCCPP,RecState.CandidateCP.Point,'Mid',RecState.CandidateCP.Point,CurrPoint,'Fin');
                Option2 = CreateOptionSingle(Alg,Sequence,LCCPP,CurrPoint,'Fin');
                BO = BetterOption(Option1, Option2);
                if (BO==1)
                    %Add 2 Critical Points 'Mid','Fin'
                    RecState = AddCriticalPoint(RecState,Sequence,Option1.FirstPoint);
                    RecState = AddCriticalPoint(RecState,Sequence,Option1.SecondPoint);

                else
                    RecState = AddCriticalPoint(RecState,Sequence,Option2.FirstPoint);
                end
            end
        else
            if (RecState.LCCPI==1)
                BLCCP.Point = 1;
            else
                BLCCP = RecState.CriticalCPs(RecState.LCCPI-1);
            end
            LCCP = RecState.CriticalCPs(RecState.LCCPI);
            [IsMerged,MergedPoint] = TryToMerge(Alg,Sequence,BLCCP.Point,LCCP,CurrPoint);
            
            if (IsMerged)
                %[4]Critical CP -> New Critical CP(merged with remainder)
                %Remove the previous critical CP
                MarkOnSequence('CandidatePoint',Sequence,LCCP.Point);                 
                RecState.LCCPI = RecState.LCCPI-1;
                RecState.CriticalCPs = RecState.CriticalCPs(1:RecState.LCCPI);
                %Add the new merged critical CheckPoint
                RecState = AddCriticalPoint(RecState,Sequence,MergedPoint);
            else
                %[2] - Critical CP -> CP(MU)
                RecState = RecognizeAndAddCriticalPoint(Alg,Sequence,RecState,LCCP.Point,CurrPoint,'Fin');
            end
        end
    end
else    %Mouse not up
    if (rem(CurrPoint,RecParams.K)==0)
        
        slope = CalculateSlope(Sequence,CurrPoint-RecParams.PointEnvLength,CurrPoint);
        SlopeRes = CheckSlope(slope);
        
        %Perform line simplification from the last Segmentation Point
        
        %Handle horizontal Segments
        if(IsFirstPointInHS(Sequence,CurrPoint,SlopeRes,RecState))
            RecState = StartNewHS(CurrPoint,RecState);
            MarkOnSequence('StartHorizontalIntervalPoint',Sequence,CurrPoint);
            return;        
        elseif (SlopeRes)
            RecState.LastSeenHorizontalPoint = CurrPoint;
            return;
        elseif (IsClosingHS(Sequence,CurrPoint,RecParams,RecState))
            MarkOnSequence('EndHorizontalIntervalPoint',Sequence,RecState.LastSeenHorizontalPoint);
            [HS,RecState] = EndHS(RecState);
            midPoint=CalcuateHSMidPoint(HS);
        else
            return;
        end
        
        [LCCPP,LetterPosition] = CalculateLCCP(RecState);     
        [NewCheckPoint,SumDist,CDist,minDist] = CreateCheckPointAndDistanceInfo(Alg,Sequence,LCCPP,midPoint,LetterPosition);
        
        %if this contour is not close to anything
%          if (minDist>RecParams.theta*SumDist)
%              display ('was rejected')
%              return;
%         end
%         
        if (isempty(RecState.CandidateCP))
            RecState.CandidateCP = NewCheckPoint;
            MarkOnSequence('CandidatePoint',Sequence,midPoint); 
        else
            SCP = BetterCP (RecState.CandidateCP,NewCheckPoint); %SCP - Selected CheckPoint
            
            %update the Candidate point in RecState
            if (SCP.Point==RecState.CandidateCP.Point) %Candidate point was selected.
                LCCPP = RecState.CandidateCP.Point;
                RecState.CandidateCP =  CreateCheckPoint (Alg,Sequence,LCCPP,midPoint,'Mid');
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
function Res = IsFirstPointInHS(Sequence,CurrPoint,SlopeRes,RecState)
Res = SlopeRes && Sequence(CurrPoint,1)<Sequence(CurrPoint-1,1) && RecState.HSStart == -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = StartNewHS(CurrPoint,RecState)
RecState.HSStart = CurrPoint;
RecState.LastSeenHorizontalPoint = CurrPoint;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Res = IsClosingHS(Sequence,CurrPoint,RecParams,RecState)
slope = CalculateSlope(Sequence,CurrPoint-RecParams.PointEnvLength,CurrPoint);
Res = (~CheckSlope(slope) || ~Sequence(CurrPoint,1)<Sequence(CurrPoint-1,1)) && RecState.HSStart~=-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [HS,RecState] = EndHS(RecState)
HS = [RecState.HSStart,RecState.LastSeenHorizontalPoint];
RecState.HSStart = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MidPoint = CalcuateHSMidPoint(HS)
MidPoint = floor((HS(1)+HS(2))/2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LCCPP,LetterPosition]  = CalculateLCCP(RecState)
if ( RecState.LCCPI == 0)
    LCCPP = 1;
    LetterPosition = 'Ini';
else
    LCCPP = RecState.CriticalCPs(RecState.LCCPI).Point;
    LetterPosition = 'Mid';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IsMerged,MergedPoint] = TryToMerge(Alg,Sequence,LastCriticalPoint,Candidate,LastPoint)
global LettersDataStructure;
MergedPoint.Point = LastPoint;
SubSeq =Sequence(LastCriticalPoint:LastPoint,:);
if (LastCriticalPoint==1)
    RecognitionResults = RecognizeSequence(SubSeq , Alg, 'Iso', LettersDataStructure);
else
    RecognitionResults = RecognizeSequence(SubSeq , Alg, 'Fin', LettersDataStructure);
end
MergedPoint.Candidates = RecognitionResults;
BCP = BetterCP (Candidate,MergedPoint);
if (BCP.Point==MergedPoint.Point)
    IsMerged = true;
else
    IsMerged = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Option = CreateOptionDouble(Alg,Sequence,Start1,End1,Position1,Start2,End2,Position2)
Option.OptionType = 'Double';
FirstPoint = CreateCheckPoint (Alg,Sequence,Start1,End1,Position1);
Option.FirstPoint =  FirstPoint;
SecondPoint = CreateCheckPoint (Alg,Sequence,Start2,End2,Position2);
Option.SecondPoint =  SecondPoint;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Option = CreateOptionSingle(Alg,Sequence,Start,End,Position)
Option.OptionType = 'Single';
FirstPoint = CreateCheckPoint (Alg,Sequence,Start,End,Position);
Option.FirstPoint =  FirstPoint;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BO = BetterOption(Option1, Option2)
switch Option1.OptionType
    case 'Single',
        Option1AvgDist = CalculateAvgCandidatesDistane (Option1.FirstPoint);
    case 'Double',
        Option1AvgDist = (CalculateAvgCandidatesDistane (Option1.FirstPoint)+CalculateAvgCandidatesDistane (Option1.SecondPoint))/2;
end

switch Option2.OptionType
    case 'Single',
        Option2AvgDist = CalculateAvgCandidatesDistane (Option2.FirstPoint);
    case 'Double',
        Option2AvgDist = (CalculateAvgCandidatesDistane (Option2.FirstPoint)+CalculateAvgCandidatesDistane (Option2.SecondPoint))/2;
end

if (Option1AvgDist<Option2AvgDist)
    BO=1;
else
    BO=2;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckPoint = CreateEmptyCheckPoint (Alg,Sequence,StartPoint,EndPoint,Position)
SubSeq = Sequence(StartPoint:EndPoint,:);
CheckPoint.Point = EndPoint;
CheckPoint.Candidates = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckPoint = CreateCheckPoint (Alg,Sequence,StartPoint,EndPoint,Position)
global LettersDataStructure;
SubSeq = Sequence(StartPoint:EndPoint,:);
RecognitionResults = RecognizeSequence(SubSeq , Alg, Position, LettersDataStructure);
CheckPoint.Point = EndPoint;
CheckPoint.Candidates = RecognitionResults;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [CheckPoint,SumDist,CDist,minDist] = CreateCheckPointAndDistanceInfo (Alg,Sequence,StartPoint,EndPoint,Position)
global LettersDataStructure;
SubSeq = Sequence(StartPoint:EndPoint,:);
[RecognitionResults,SumDist] = RecognizeSequence(SubSeq , Alg, Position, LettersDataStructure);
CheckPoint.Point = EndPoint;
CheckPoint.Candidates = RecognitionResults;
distances = [RecognitionResults{:,2}];
CDist = sum (distances);
minDist = min (distances);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = RecognizeAndAddCriticalPoint(Alg,Sequence,RecState,StartPoint,EndPoint,LetterPos)
WarpedPoint= CreateCheckPoint (Alg,Sequence,StartPoint,EndPoint,LetterPos);
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
function Res = IsCheckPoint(Sequence,CurrPoint,SimplifiedSequence,Slope)
%A candidate point is a Checkpoint only if all the below are valid:
%1. The current Sub sequence contains enough information
%2. Directional - > going "forward" in x axes
%3. The point environmnt is horizontal
%%%MaxSlope=RecParams.MaxSlope;
Res = (length(SimplifiedSequence)>2 && CheckSlope(Slope)&& Sequence(CurrPoint,1)<Sequence(CurrPoint-1,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = CheckSlope(Slope)
res = SPQuerySVM('C:\OCRData\Segmentation\SVM\SVMStruct',Slope)&& Slope<0.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SeqLen] = CalculateSequenceLength (Sequence,CurrPoint,RecState)
LCCPI=RecState.LCCPI;
if(LCCPI==0)
    SeqLen = SequenceLength(Sequence);
else
    LastCCP = RecState.CriticalCPs(LCCPI);
    sub_s= Sequence(LastCCP.Point:CurrPoint,:);
    SeqLen = SequenceLength(sub_s);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MidPoint = GetMidPoint(Sequence,Point1, Point2)
% P1=Sequence(Point1,:);
% P2=Sequence(Point2,:);
% MidPoint = [(P1(1)+P2(1))/2,(P1(2)+P2(2))/2];
MidPoint = (Point1+Point2)/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Simplified] = CalculateSimplifiedSequence (Sequence,CurrPoint,RecState,ST)
LCCPI=RecState.LCCPI;

if(LCCPI==0)
    Simplified  = dpsimplify(Sequence,ST);
else
    LastCCP = RecState.CriticalCPs(LCCPI);
    sub_s= Sequence(LastCCP.Point:CurrPoint,:);
    Simplified  = dpsimplify(sub_s,ST);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%    PRINTING/TEST FUNCTIONS   %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckAlternativeCondition(SequenceLength,SimplifiedSequence,Slope,MinLen,MaxSlope)
%for testing only - check when the second condition holds alone
if ((Slope<MaxSlope && (length(SimplifiedSequence)-1)*SequenceLength>MinLen) && ~(SequenceLength> MinLen && length(SimplifiedSequence)>3 && Slope<MaxSlope))
    len_simp_str=num2str(length(SimplifiedSequence));
    seqLen_str=num2str(SequenceLength);
    MinLen_str = num2str(MinLen);
    disp(['WARNING: length(simplified)= ',len_simp_str,'   seqLen = ',seqLen_str,'  >  ',MinLen_str]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DisplayUnsutisfiedConditions(seqLen,simplified,slope,MinLen,MaxSlope)
if (seqLen <= MinLen)
    display('Sub-Sequence length too Short')
end
if (length(simplified)<=2)
    display ('Sub-Sequence is too Simple')
end
if (slope>=MaxSlope)
    display ('The point environment is not Horizontal Enough')
end
display(' ')
display(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MarkOnSequence(Type,Sequence,Point)
switch Type
    case 'CandidatePoint',
        %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'c.-','Tag','SHAPE','LineWidth',10);
        return;
    case 'CriticalCP'
        %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'r.-','Tag','SHAPE','LineWidth',10);
        return;
    case 'StartHorizontalIntervalPoint'
        %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'g.-','Tag','SHAPE','LineWidth',10);
        return;
    case 'EndHorizontalIntervalPoint'
        %plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'k.-','Tag','SHAPE','LineWidth',10);
        return;
    otherwise
        return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
