function RecState = SimulateOnlineRecognizer( sequence, loadDataStructure, showUI )
%SIMULATEONLINERECOGNIZER This funtion simulate the Online pen recognizer.
% a = dlmread(['C:\OCRData\WordPartFromUI.m']);
% Res = SimulateOnlineRecognizer(a,true,true)


%%%%%%%%%%%%%% Activate at first run  id not running from TestOnlineRecognizer %%%%%%%%%%%%%%%%%%%%%%%%
if (nargin<2 || loadDataStructure==true)
  global LettersDataStructure;
  LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RecParams = InitializeRecParams();
RecState = InitializeRecState();


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
    axis(h_axes,[-1 1 -1 1]);
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
    GetCandidatesFromRecState( RecState );
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
RecParams.MaxSlopeRate = 0.5;
RecParams.MaxDistFromBaseline = 0.15;

