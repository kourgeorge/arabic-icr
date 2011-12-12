function [ CandidateWPs ] = RecognizeWP(WPContour, LexiconWPFeatureVectorFolder, FeatureType, MetricType ,NumOfClosest )
%RECOGNIZEWP: Given a WP contour, the function return the closest points
%using the given FeatureType and MetricType in the featured lexicon
%folder.(LexiconWPFeatureVectorFolder). 
%   Detailed explanation goes here


if ~(exist(LexiconWPFeatureVectorFolder,'dir'))
    return;
end

switch (FeatureType)
    case 'Angular',
        LexiconFolder = [LexiconWPFeatureVectorFolder,'\Angular'];
        InputWPFeatureVector = CreateFeatureVectorFromContour(WPContour,1);
    case 'ShapeContext',
        LexiconFolder = [LexiconWPFeatureVectorFolder,'\ShapeContext'];
        InputWPFeatureVector = CreateFeatureVectorFromContour(WPContour,2);
    case 'Contour',
        LexiconFolder = LexiconWPFeatureVectorFolder;
        InputWPFeatureVector = WPContour;
end


dirlist = dir(LexiconFolder);
Num=0;
CandidateWPs =  [];
 h = waitbar(0,('Recognizing...'));
for i = 1:length(dirlist)
    current_object = dirlist(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 & FileName(LastCharacter)=='m')
        CandidateWPTFeaureVector  = dlmread([LexiconFolder,'\',FileName]);
        switch (MetricType)
            case 'DTW',
                [p,q,D,Diff,WarpingPath] = DTWContXY(InputWPFeatureVector,CandidateWPTFeaureVector);
                
            case 'Res_DTW'
                %%%% Restricted DTW Demo  %%%%%%
                [m1,n1] = size(InputWPFeatureVector);
                [m2,n2] = size(CandidateWPTFeaureVector);
                r=abs(m2-m1)+5;
                Diff = Cons_DTW(InputWPFeatureVector,CandidateWPTFeaureVector,r);
                
            case 'App_EMD',
                [f,Diff] = EmdContXY(InputWPFeatureVector,CandidateWPTFeaureVector);
        end
        WPcell={FileName,Diff};
        CandidateWPs=[CandidateWPs ; WPcell];
        Num=Num+1;
        prog = i/(length(dirlist));
        waitbar(prog,h);
    end
end
close (h);
CandidateWPs = sortcell(CandidateWPs,[2,1]);
CandidateWPs = CandidateWPs(1:NumOfClosest,:);

