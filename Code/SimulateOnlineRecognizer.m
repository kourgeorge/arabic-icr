function [ output_args ] = SimulateOnlineRecognizer( sequence )
%SIMULATEONLINERECOGNIZER Summary of this function goes here
%   Detailed explanation goes here

RecParams = InitializeRecParams();
RecState = InitializeRecState();

len = size(sequence,1);
Sequence = [];
for k=1:len-1
    Sequence=[Sequence;sequence(k,:)];
    RecState = ProcessNewPoint(RecParams,RecState,Sequence,false);
end
RecState = ProcessNewPoint(RecParams,RecState,Sequence,true);
DisplayCandidates (RecState);

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
RecParams.Alg = {'DTW' 'MSC' 'kdTree'};
RecParams.theta=0.04/5;
RecParams.K = 5;
RecParams.ST = 0.03; %Simplification algorithm tolerance
RecParams.MinLen = 0.4;
RecParams.MaxSlope = 0.4;
RecParams.PointEnvLength=2;
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
