function [MainStrokesResults,AdditionalStrokesResults,himage] = OnlineRecognizer( sequence, loadDataStructure, showUI )
%ONLINERECOGNIZER This funtion simulate the Online pen recognizer.
% a = dlmread(['C:\OCRData\WordPartFromUI.m']);
% Res = OnlineRecognizer(a,true,true)

global LettersDataStructure;
%%%%%%%%%%%%%% Activate at first run  id not running from TestOnlineRecognizer %%%%%%%%%%%%%%%%%%%%%%%%
if (nargin<2 || loadDataStructure==true)
    LettersDataStructure = load('C:\OCRData\LettersFeatures\LettersDS');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RecParams = InitializeRecParams();
%sequence = NormalizeCont(sequence);


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
    Contour = sequence;
    temp = Contour(:,1);
    Contourtemp(:,1) = temp(temp~=Inf('single'));
    temp=  Contour(:,2);
    Contourtemp(:,2) = temp(temp~=-Inf('single'));
    
    maxX = max(Contourtemp(:,1)); minX = min(Contourtemp(:,1)); maxY = max(Contourtemp(:,2)); minY = min(Contourtemp(:,2));
    windowSize = max(maxX-minX,maxY-minY);
    ylim([minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
    xlim([minX-0.1*windowSize minX+windowSize+0.1*windowSize]);
    axis(h_axes,[minX-0.1*windowSize minX+windowSize+0.1*windowSize minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
    hold(h_axes,'on');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get the indexes of [fin Fin] rows (which symbols Pen UP)
len = size(sequence,1);
InfIndexes = find (sequence(:,1) == Inf);
InfIndexes = [0;InfIndexes;len+1];
for j=1:length(InfIndexes)-1
    strokes{j} = sequence(InfIndexes(j)+1:InfIndexes(j+1)-1,:);
end
m = 0;
a = 0;
for j=1:size(strokes,2)
    RecState = InitializeRecState();
    stroke = strokes{j};
    strokeLen = size(stroke,1);
    Stroke = [];
    for k=1:strokeLen-1
        Stroke = [Stroke;stroke(k,:)];
        RecState = ProcessNewPoint(RecParams,RecState,Stroke,false,UI);
        if (UI == true)
            plot(h_axes,[stroke(k,1) stroke(k+1,1)],[stroke(k,2) stroke(k+1,2)],'b.-','Tag','SHAPE','LineWidth',3);
            scatter(h_axes, stroke(k,1),stroke(k,2));
        end
    end
    RecState = ProcessNewPoint(RecParams,RecState,stroke,true,UI);
    
    if (UI == true)
        %fprintf('%s',GetCandidatesFromRecState( RecState ));
    end
    
%     if (IsAdditionalStroke(stroke,RecState)==true)
%         a=a+1;
%         AdditionalStrokesResults(a) = RecState;
%         
%     else
        m=m+1;
        MainStrokesResults(m) =  RecState;
%     end
end
% 
% if (m>0)
%     [ MainStrokesResults, AdditionalStrokes ] = ExtractAdditionalStroke( MainStrokesResults , sequence); 
%     if (~isempty(AdditionalStrokes))
%         AdditionalStrokesResults = [AdditionalStrokesResults;AdditionalStrokes];
%     end
% end
if (a == 0 )
    AdditionalStrokesResults = [];
end
if (m == 0)
    MainStrokesResults = [];
end

if (UI == true)
%    clear h_axes;
%    close (himage);
end


%%%%%%%%%%%%%%%%    Initialization Functions   %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RecState = InitializeRecState()

RecState.CandidatePointsArray = [1];
RecState.RecognitionScoreTable = {};
RecState.SegmentationPoints = {};
RecState.MinScoreTable = [];
RecState.HSStart = -1;
RecState.LastSeenHorizontalPoint = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RecParams = InitializeRecParams()
% Algorithm parameters
RecParams.Alg = {'EMD'}; %Res_DTW
RecParams.K = 3;
RecParams.PointEnvLength =1;
RecParams.AbsoluteSimplificationEpsilon = 1/75;
RecParams.MaxSlopeRate = 0.6;
RecParams.MaxDistFromBaseline = 0.15;
RecParams.NumCandidates = 3;
RecParams.MaxIndecisiveCandidates = 4;


