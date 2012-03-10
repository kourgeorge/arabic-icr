function ProgressiveRecognizerPen (DataFolder, Closest)
% Pen-Like data processing template
% pen.m is a GUI ready to use
%       the GUI calls a function called "process_data"

global in_writing;
global himage;

global folder kNN;
folder = DataFolder;
kNN = Closest;

ClearAll();

in_writing = 0;

% create the new figure
himage = figure;

set(himage,'numbertitle','off');                % treu el numero de figura
set(himage,'name','Progressive Recognizer Pen');% Name
set(himage,'MenuBar','none');                   % remove the menu icon
set(himage,'doublebuffer','on');                % two buffers graphics
set(himage,'tag','PEN');                        % identify the figure
set(himage,'Color',[0.95 0.95 0.95]);
set(himage,'Pointer','crosshair');

% create the axis
h_axes = axes('position', [0 0 1 1]);
set(h_axes,'Tag','AXES');
box(h_axes,'on');
%grid(h_axes,'on');
axis(h_axes,[0 1 0 1]);
%axis(h_axes,'off');
hold(h_axes,'on');

line([0 1],[0.3 0.3],'Color','black','LineWidth',2);
line([0 1],[0.5 0.5],'Color','black','LineWidth',2);
line([0 1],[0.7 0.7],'Color','black','LineWidth',2);

% ######  MENU  ######################################
h_opt = uimenu('Label','&Options');
uimenu(h_opt,'Label','Clear','Callback',@ClearAll);
uimenu(h_opt,'Label','Exit','Callback','closereq;','separator','on');


% create the text
h_text = uicontrol('Style','edit','Units','normalized','Position',[0 0.9 1 0.10],'FontSize',10,'HorizontalAlignment','left','Enable','inactive','Tag','TEXT');

set(himage,'WindowButtonDownFcn',@movement_down);
set(himage,'WindowButtonUpFcn',@movement_up);
set(himage,'WindowButtonMotionFcn',@movement);
uiwait;

% #########################################################################

% #########################################################################
function ClearAll(hco,eventStruct)

global x_pen y_pen RecState;

clc;

% erase previous drawing
delete(findobj('Tag','SHAPE'));
delete(findobj('Tag','BOX'));

% delete previous data
x_pen = [];
y_pen = [];

% if necessary
himage = findobj('tag','PEN');

%Initialize parameters for the progressive recognition algorithm
RecState.LCCPI=0; % LastCriticalCheckPointIndex, the corrent root
RecState.CriticalCPs=[]; %Each cell contains the Candidates of the interval from the last CP and the last Point
RecState.CandidateCP=[]; %Holds the first candidate to be a Critical CP after the LCCP

% #########################################################################
% #########################################################################

function movement_down(hco,eventStruct)

global in_writing x_pen y_pen;
%Enter to state 1 as in the first phase we will try to recognize only 1
%stroke word parts.


% toggle
in_writing = 1;

% restore point
h_axes = findobj('Tag','AXES');
p = get(h_axes,'CurrentPoint');
x = p(1,1);
y = p(1,2);

% cumulative data
x_pen = [x_pen x];
y_pen = [y_pen y];

set(findobj('Tag','TEXT'),'String','Current State: 1 ');

% draw
plot(h_axes,x,y,'b.','Tag','SHAPE','LineWidth',3);
% #########################################################################

% #########################################################################
function movement_up(hco,eventStruct)
global in_writing x_pen y_pen;

% toggle
in_writing = 0;

h_axes = findobj('Tag','AXES');

% analysis of what has been pressed
% delete box above
delete(findobj('Tag','BOX'));

% marcar un requadre
x_i = min(x_pen);
x_f = max(x_pen);
x_d = max([1 (x_f - x_i)]);
y_i = min(y_pen);
y_f = max(y_pen);
y_d = max([1 (y_f - y_i)]);
plot(h_axes,[x_i x_f x_f x_i x_i],[y_i y_i y_f y_f y_i],'K:','MarkerSize',22,'Tag','BOX');
process_data(x_pen,y_pen,true);
%close;
% #########################################################################

% #########################################################################
function movement(hco,eventStruct)

global in_writing x_pen y_pen;

if in_writing
    % button pressing
    
    h_axes = findobj('Tag','AXES');
    
    p = get(h_axes,'CurrentPoint');
    x = p(1,1);
    y = p(1,2);
    
    
    if ((y < 0) || (y > 1) || (x < 0) || (x > 1))
        % do nothing
        return;
    end
    
    if ((x ~= x_pen(end)) || (y ~= y_pen(end)))
        % next point
        x_pen = [x_pen x];
        y_pen = [y_pen y];
        
        plot(h_axes,[x_pen(end-1) x],[y_pen(end-1) y],'b.-','Tag','SHAPE','LineWidth',3);
    end
    process_data(x_pen,y_pen,false);
end

% #########################################################################

function simulate(sequence)
len = size(sequence,2);
for k=1:len-1
    process_data(sequence(k,1),sequence(k,2),false);
end
process_data(sequence(len,1),sequence(k,2),true);


% #########################################################################
function process_data(x_pen,y_pen,IsMouseUp)
% x_pen, y_pen are the current point locations
global RecState;

Sequence(:,1) = x_pen;
Sequence(:,2) = y_pen;


Alg = {'EMD' 'MSC' 'kdTree'};

% Algorithm parameters
RecParams.theta=0.144;
RecParams.K = 20;
RecParams.ST = 0.05; %Simplification algorithm tolerance
RecParams.MinLen = 0.4;
RecParams.MaxSlope = 0.3;
RecParams.PointEnvLength=5;

Old_LCCPI = RecState.LCCPI;

RecState = ProcessNewPoint(Alg,RecParams,RecState,Sequence,IsMouseUp);

%Update the heading in the Pen Window
if (Old_LCCPI < RecState.LCCPI || IsMouseUp==true)
    UpdateHeading(RecState);
end

%Output all the candidates.
if (IsMouseUp==true)
    DisplayCandidates(RecState)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%   CORE FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState=ProcessNewPoint(Alg,RecParams,RecState,Sequence,IsMouseUp)
CurrPoint = size(Sequence,1);
if(IsMouseUp==true)
    if (RecState.LCCPI == 0)
        if (~isempty(RecState.CandidateCP))
            [IsMerged,MergedPoint] = TryToMerge(Alg,Sequence,1,RecState.CandidateCP,CurrPoint);
            if (IsMerged)
                %[7] - CP(merged - old CP and the remainder)
                RecState = AddCriticalPoint(RecState,MergedPoint);
            else
                %[5]
                Option1 = CreateOptionDouble(Alg,Sequence,1,RecState.CandidateCP.Point,'Ini',RecState.CandidateCP.Point,CurrPoint,'Fin');
                Option2 = CreateOptionSingle(Alg,Sequence,1,CurrPoint,'Iso');
                BO = BetterOption(Option1, Option2);
                if (BO==1)
                    %Add 2 Critical Points 'Ini','Fin'
                    RecState = AddCriticalPoint(RecState,Option1.FirstPoint);
                    MarkOnSequence('CriticalCP',Sequence,Option1.FirstPoint.Point);
                    RecState = AddCriticalPoint(RecState,Option1.SecondPoint);
                    MarkOnSequence('CriticalCP',Sequence,Option1.SecondPoint.Point);
                else
                    %Add 1 Critical Point 'Iso'
                    RecState = AddCriticalPoint(RecState,Option2.FirstPoint);
                    MarkOnSequence('CriticalCP',Sequence,Option2.FirstPoint.Point);
                end
            end
        else
            %[6]
            SubSeq = Sequence;
            LetterPos = 'Iso';
            RecState = RecognizeAndAddCriticalPoint(Alg,RecState,SubSeq,CurrPoint,LetterPos);
        end
    else %not the first letter
        if (~isempty(RecState.CandidateCP))
            LCCP = RecState.CriticalCPs(RecState.LCCPI);
            [IsMerged,MergedPoint] = TryToMerge(Alg,Sequence,LCCP.Point,RecState.CandidateCP,CurrPoint);
            if (IsMerged)
                %[3]Critical CP -> CP(merged - old CP and the remainder)                
                RecState = AddCriticalPoint(RecState,MergedPoint);
                MarkOnSequence('CriticalCP',Sequence,MergedPoint.Point);
                %Reset the Candidate
                RecState.CandidateCP = [];
            else
                %[1]Critical CP -> CP -> CP (of MU)
                LCCPP = RecState.CriticalCPs(RecState.LCCPI).Point;
                Option1 = CreateOptionDouble(Alg,Sequence,LCCPP,RecState.CandidateCP.Point,'Med',RecState.CandidateCP.Point,CurrPoint,'Fin');
                Option2 = CreateOptionSingle(Alg,Sequence,LCCPP,CurrPoint,'Fin');
                BO = BetterOption(Option1, Option2);
                if (BO==1)
                    %Add 2 Critical Points 'Med','Fin'
                    RecState = AddCriticalPoint(RecState,Option1.FirstPoint);
                    MarkOnSequence('CriticalCP',Sequence,Option1.FirstPoint.Point);
                    RecState = AddCriticalPoint(RecState,Option1.SecondPoint);
                    MarkOnSequence('CriticalCP',Sequence,Option1.SecondPoint.Point);
                else
                    RecState = AddCriticalPoint(RecState,Option2.FirstPoint);
                    MarkOnSequence('CriticalCP',Sequence,Option2.FirstPoint.Point);
                end
            end
        else
            BLCCP = RecState.CriticalCPs(RecState.LCCPI-1);
            LCCP = RecState.CriticalCPs(RecState.LCCPI);
            [IsMerged,MergedPoint] = TryToMerge(Alg,Sequence,BLCCP.Point,LCCP,CurrPoint);
            if (IsMerged)
                %[4]Critical CP -> New Critical CP(merged with remainder)
                %Remove the previous critical CP
                MarkOnSequence('CandidateCP',Sequence,LCCP.Point);                
                RecState.LCCPI = RecState.LCCPI-1;
                RecState.CriticalCPs = RecState.CriticalCPs(1:RecState.LCCPI);
                %Add the new merged critical CheckPoint
                RecState = AddCriticalPoint(RecState,MergedPoint);
                MarkOnSequence('CriticalCP',Sequence,MergedPoint.Point);
            else
                %[2] - Critical CP -> CP(MU)
                SubSeq = Sequence(LCCP.Point:CurrPoint,:);
                LetterPos = 'Fin';
                RecState = RecognizeAndAddCriticalPoint(Alg,RecState,SubSeq,CurrPoint,LetterPos);
                MarkOnSequence('CriticalCP',Sequence,CurrPoint);
            end
        end
    end
else    %Mouse not up
    if (rem(CurrPoint,RecParams.K)==0)
        MarkOnSequence('CandidatePoint',Sequence,CurrPoint);
        
        %Calculate Decision Parameters
        simplified = CalculateSimplifiedSequence (Sequence,CurrPoint,RecState,RecParams.ST);
        seqLen = CalculateSequenceLength (Sequence,CurrPoint,RecState);
        slope = CalculateSlope(Sequence,CurrPoint,RecParams.PointEnvLength);
        
        %CheckAlternativeCondition(seqLen,simplified,slope,RecParams.MinLen,RecParams.MaxSlope);
        
        % set LCCPP,SubSeq
        if ( RecState.LCCPI == 0)
            LCCPP = 0;
            SubSeq = Sequence;
            LetterPosition = 'Ini';
        else
            LCCP = RecState.CriticalCPs(RecState.LCCPI);
            LCCPP = LCCP.Point;
            SubSeq= Sequence(LCCPP:CurrPoint,:);
            LetterPosition = 'Med';
        end
        
        if (~isempty(RecState.CandidateCP))
            sub_s= Sequence(RecState.CandidateCP.Point:CurrPoint,:);
            Simplified  = dpsimplify(sub_s,RecParams.ST);
            if (size(Simplified,1)>2)
                MoreInfo = true;
            else
                MoreInfo = false;
            end
        else
            MoreInfo = true;
        end
        
        
        if (IsCheckPoint(seqLen,simplified,slope,RecParams) && Sequence(CurrPoint,1)<Sequence(CurrPoint-1,1) && MoreInfo)
            MarkOnSequence('CheckPoint',Sequence,CurrPoint);
            
            RecognitionResults = RecognizeSequence(SubSeq , Alg, LetterPosition);
            if (isempty(RecState.CandidateCP))
                RecState.CandidateCP.Candidates = RecognitionResults;
                RecState.CandidateCP.Point = CurrPoint;
            else
                currCP.Candidates=RecognitionResults;
                currCP.Point = CurrPoint;
                SCP = BetterCP (RecState.CandidateCP,currCP); %SCP - Selected CheckPoint
                RecState.CriticalCPs = [RecState.CriticalCPs;SCP];
                RecState.LCCPI = RecState.LCCPI + 1;
                MarkOnSequence('CriticalCP',Sequence,SCP.Point);
                if (SCP.Point<CurrPoint)
                    %If the Old Candidate have been selected New candidate is from the new critical CP.
                    LCCP = RecState.CriticalCPs(RecState.LCCPI);
                    LCCPP = LCCP.Point;
                    SubSeq= Sequence(LCCPP:CurrPoint,:);
                    LetterPosition = 'Med';
                    currCP.Candidates = RecognizeSequence(SubSeq , Alg, LetterPosition);
                    currCP.Point = CurrPoint;
                    RecState.CandidateCP = currCP;
                else
                    RecState.CandidateCP = [];
                end
            end
        else
            %Notify which condition didn't hold.
            %DisplayUnsutisfiedConditions(seqLen,simplified,slope,RecParams.MinLen,RecParams.MaxSlope);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%    HELPER FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [IsMerged,MergedPoint] = TryToMerge(Alg,Sequence,LastCriticalPoint,Candidate,LastPoint)
MergedPoint.Point = LastPoint;
SubSeq =Sequence(LastCriticalPoint:LastPoint,:);
if (LastCriticalPoint==0)
    RecognitionResults = RecognizeSequence(SubSeq , Alg, 'Iso');
else
    RecognitionResults = RecognizeSequence(SubSeq , Alg, 'Fin');
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
function CheckPoint = CreateCheckPoint (Alg,Sequence,StartPoint,EndPoint,Position)
SubSeq = Sequence(StartPoint:EndPoint,:);
RecognitionResults = RecognizeSequence(SubSeq , Alg, Position);
CheckPoint.Point = EndPoint;
CheckPoint.Candidates = RecognitionResults;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = RecognizeAndAddCriticalPoint(Alg,RecState,SubSeq,CurrPoint,LetterPos)
RecognitionResults = RecognizeSequence(SubSeq, Alg, LetterPos);
WarpedPoint.Candidates=RecognitionResults;
WarpedPoint.Point = CurrPoint;
RecState = AddCriticalPoint(RecState,WarpedPoint);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = AddCriticalPoint(RecState,WrappedPoint)
RecState.CriticalCPs = [RecState.CriticalCPs;WrappedPoint];
RecState.LCCPI = RecState.LCCPI + 1;

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
sum=0;
NumCandidates = size(CandidateCP.Candidates,1);
for k=1:NumCandidates
    sum = sum + CandidateCP.Candidates{k,2};
end
Avg = sum/NumCandidates;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Res = IsCheckPoint(SequenceLength,SimplifiedSequence,Slope,RecParams)
%A candidate point is a Checkpoint only if all the below are valid:
%1. The current Sub sequence is longer than MinLen
%2. The current Sub sequence contains enough information
%3. The point environmnt is horizontal
MinLen=RecParams.MinLen;
MaxSlope=RecParams.MaxSlope;
Res = (SequenceLength> MinLen && length(SimplifiedSequence)>3 && Slope<MaxSlope) || (Slope<MaxSlope && length(SimplifiedSequence)*SequenceLength>MinLen);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Slope] = CalculateSlope(Sequence,CurrPoint,PointEnvLength)
start_env= Sequence(CurrPoint-PointEnvLength,:);
end_env= Sequence(CurrPoint,:);
Slope = abs((end_env(2)-start_env(2))/-(end_env(1)-start_env(1))); %Arabic is written right to left

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
        plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'c.-','Tag','SHAPE','LineWidth',7);
        return;
    case 'CheckPoint'
        plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'g.-','Tag','SHAPE','LineWidth',10);
        return;
    case 'CriticalCP'
        plot(findobj('Tag','AXES'),Sequence(Point-1:Point,1),Sequence(Point-1:Point,2),'r.-','Tag','SHAPE','LineWidth',10);
        return;
    otherwise
        return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UpdateHeading (RecState)
LCCPI=RecState.LCCPI;
stat_str= num2str(LCCPI);
str = '';
if (LCCPI==0)
    %Do nothing
elseif (LCCPI==1)
    LCCP = RecState.CriticalCPs(LCCPI);
    CurrCan = LCCP.Candidates;
    for i=1:length(CurrCan)
        str = [str,'  ',CurrCan{i,1}{1}];
    end
    endIndex = num2str(LCCP.Point);
    set(findobj('Tag','TEXT'),'String',['[Current State: ', stat_str,']  ',' Interval: 0 - ',  endIndex, ' Candidates: ' str]);
else
    LCCP = RecState.CriticalCPs(LCCPI);
    CurrCan = LCCP.Candidates;
    for i=1:length(CurrCan)
        str = [str,'  ',CurrCan{i,1}{1}];
    end
    BLCCP = RecState.CriticalCPs(LCCPI-1);
    startIndex = num2str(BLCCP.Point);
    endIndex = num2str(LCCP.Point);
    set(findobj('Tag','TEXT'),'String',['[Current State: ' stat_str, ']  ','   Previous State:- ',' Interval: ' , startIndex, ' - ',  endIndex, '   Candidates: ' str]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DisplayCandidates (RecState)
for i=1:RecState.LCCPI
    if (i==1)
        startIndex = num2str(0);
    else
        BLCCPP = RecState.CriticalCPs(i-1).Point;
        startIndex = num2str(BLCCPP);
    end
    LCCP =  RecState.CriticalCPs(i);
    LCCPP = LCCP.Point;
    endIndex = num2str(LCCPP);
    i_str = num2str(i);
    disp (['State : ',i_str,',  ',startIndex,' - ',endIndex])
    CurrCan = LCCP.Candidates(:,1);
    str = '';
    for j=1:size(CurrCan,1)
        str = [str,' ',CurrCan{j}{1}];
    end
    disp(['Candidates:  ',str])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     EOF      %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%