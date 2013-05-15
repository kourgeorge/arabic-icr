function RecState = SimulateOnlineRecognizer( sequence, loadDataStructure, showUI )
%SIMULATEONLINERECOGNIZER This funtion simulate the Online pen recognizer.
% a = dlmread(['C:\OCRData\GeneratedWords\<>.m']);
% Res = SimulateOnlineRecognizer(a,true,true)


%%%%%%%%%%%%%% Activate at first run  id not running from TestOnlineRecognizer %%%%%%%%%%%%%%%%%%%%%%%%
if (nargin<2 || loadDataStructure==true)
    global LettersDataStructure;
    LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RecParams = InitializeRecParams();
RecState = InitializeRecState();

sequence = NormalizeCont(sequence);

%%%%%%%%%%%%%%%%%%%%%%%%%% Sequence Pre-Processing %%%%%%%%%%%%%%%%%%
% NormalizedLetterSequence = NormalizeCont(sequence);
% SimplifiedLetterSequence = SimplifyContour( NormalizedLetterSequence);
% sequence = ResampleContour(SimplifiedLetterSequence,300);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%  Enable Gui  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin<3)
    UI = false;
else
    UI = showUI;
end

if (UI == true)
    himage = figure;
    h_axes = axes();
    set(h_axes,'Tag','AXES');
    maxX = max(sequence(:,1)); minX = min(sequence(:,1)); maxY = max(sequence(:,2)); minY = min(sequence(:,2));
    windowSize = max(maxX-minX,maxY-minY);
    ylim([minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
    xlim([minX-0.1*windowSize minX+windowSize+0.1*windowSize]);
    axis(h_axes,[minX-0.1*windowSize minX+windowSize+0.1*windowSize minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
    hold(h_axes,'on');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


len = size(sequence,1);
Sequence = [];
for k=1:len-1
    Sequence=[Sequence;sequence(k,:)];
    RecState = ProcessNewPoint(RecParams,RecState,Sequence,false,UI);
    if (UI == true)
        plot(h_axes,[sequence(k,1) sequence(k+1,1)],[sequence(k,2) sequence(k+1,2)],'b.-','Tag','SHAPE','LineWidth',3);
    end
end
RecState = ProcessNewPoint(RecParams,RecState,sequence,true,UI);
if (UI == true)
    GetCandidatesFromRecState( RecState )
    close (himage);
end

%%%%%%%%%%%%%%%%    Initialization Functions   %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = InitializeRecState()

RecState.LCCPI=0; % LastCriticalCheckPointIndex, the corrent root
RecState.CriticalCPs=[]; %Each cell contains the Candidates of the interval from the last CP and the last Point
RecState.CandidateCP=[]; %Holds the first candidate to be a Critical CP after the LCCP
RecState.HSStart = -1;
RecState.LastSeenHorizontalPoint = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RecParams = InitializeRecParams()
% Algorithm parameters
RecParams.Alg = {'EMD'}; %Res_DTW
RecParams.K = 5;
RecParams.PointEnvLength = 1;
RecParams.MaxSlopeRate = 0.6;
RecParams.MaxDistFromBaseline = 0.15;

