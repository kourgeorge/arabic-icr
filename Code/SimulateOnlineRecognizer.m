function RecState = SimulateOnlineRecognizer( sequence )
%SIMULATEONLINERECOGNIZER This funtion simulate the Online pen recognizer.
% a = dlmread(['C:\OCRData\GeneratedWords\sample.m']);
% Res = SimulateOnlineRecognizer( a )

RecParams = InitializeRecParams();
RecState = InitializeRecState();

%Sequence Pre-Processing = Normalization->Simplification->Resampling
NormalizedLetterSequence = NormalizeCont(sequence);
SimplifiedLetterSequence = SimplifyContour( NormalizedLetterSequence);
sequence = ResampleContour(SimplifiedLetterSequence,300);
RecState.Sequence = sequence;
len = size(sequence,1);
%figure;
Sequence = [];
for k=1:len-1
    Sequence=[Sequence;sequence(k,:)];
    RecState = ProcessNewPoint(RecParams,RecState,Sequence,false,false);
end
RecState = ProcessNewPoint(RecParams,RecState,Sequence,true,false);

%Comment out when TestOnlineRecognizer is running 
%GetCandidatesFromRecState( RecState );

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
RecParams.Alg = {'EMD' 'MSC'};
RecParams.theta=0.04/5;
RecParams.K = 5;
RecParams.ST = 0.03; %Simplification algorithm tolerance
RecParams.PointEnvLength=2;

