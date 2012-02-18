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
    case 'ShapeContext',
        LexiconFolder = [LexiconWPFeatureVectorFolder,'\ShapeContext'];
    case 'Contour',
        InputWPFeatureVector = WPContour;
end

dirlist = dir(LexiconFolder);
CandidateWPs =  [];
for i = 1:length(dirlist)
    current_object = dirlist(i);
    Name = current_object.name;
    if (current_object.isdir && ~strcmp(Name,'.')  &&  ~strcmp(Name,'..'))
        ClosestWPInFolder = RecognizeWPFromFolder( WPContour, [LexiconFolder,'\',Name], FeatureType, MetricType ,NumOfClosest );
        CandidateWPs=[CandidateWPs ; ClosestWPInFolder];
    end
end
CandidateWPs = sortcell(CandidateWPs,[2,1]);
CandidateWPs = CandidateWPs(1:NumOfClosest,:);

