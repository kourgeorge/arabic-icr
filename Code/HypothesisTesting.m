function [ UnrecognizedWP , Recognition_RatekdTree] = HypothesisTesting( input_args )
clc;
% Test Parameters
FeatureType = 'Angular'
FeatureTypeNum = 1;
% FeatureType = 'ShapeContext'
% FeatureTypeNum = 2;
closest = 5 

%Recognition_RateLSH = HypothesisTestingLSH(FeatureType,FeatureTypeNum,closest)
[Recognition_RatekdTree,UnrecognizedWP] = HypothesisTestingKdtree(FeatureType,FeatureTypeNum,closest);

Recognition_RatekdTree

end


function Recognition_Rate = HypothesisTestingLSH( FeatureType ,FeatureTypeNum,closest)
%HYPOTHESISTESTING Summary of this function goes here
%   Detailed explanation goes here

tic;

LSHFilePath = ['C:\OCRData\LSH\',FeatureType];

%load TetsingWords folder
TestingWPFolder = 'C:\OCRData\TestingWords';

dirlist = dir(TestingWPFolder);
DirListLength = length(dirlist);

NumOfWords = DirListLength-2

WPmap = cell(NumOfWords,1);
WPSeqs = cell(NumOfWords,1);

for j = 3:DirListLength
    current_object = dirlist(j);
    FileName = current_object.name;
    WPTSeq = dlmread([TestingWPFolder,'\',FileName]);
    FileNameCell = {FileName};
    WPmap(j-2) = FileNameCell;
    WPSeqs(j-2) = {WPTSeq};
end

ClosestWPsCellArray = RecognizeWPsLSH( WPSeqs, LSHFilePath, FeatureTypeNum, closest );

Success = 0;
for i=1:NumOfWords
    %Get the corresponding cell array that contains the closest elements of WP i
    ClosestWPs=ClosestWPsCellArray{i};
    
    if (size(ClosestWPs,1)>0)
        ind = find(ismember(ClosestWPs, WPmap(i))==1);
        if (ind>0)
            Success=Success+1;
        end
    end
    
%     %Print:
%     disp('-------------------------------------')
%     disp(['The Word:' , WPmap(i)])
%     disp('The Recognition:')
%     for t=1:length(ClosestWPs)
%         disp(ClosestWPs(t))
%     end
    
end
toc
Recognition_Rate = (Success/NumOfWords*100);

end

function [Recognition_Rate,UnrecognizedWP] = HypothesisTestingKdtree( FeatureType ,FeatureTypeNum, closest)
%HYPOTHESISTESTING Summary of this function goes here
%   Detailed explanation goes here


tic;

LSHFilePath = ['C:\OCRData\kdTree\',FeatureType];

%load TetsingWords folder
TestingWPFolder = 'C:\OCRData\TestingWords';

dirlist = dir(TestingWPFolder);
DirListLength = length(dirlist);

NumOfWords = DirListLength-2;

WPmap = cell(NumOfWords,1);
WPSeqs = cell(NumOfWords,1);

for j = 3:DirListLength
    current_object = dirlist(j);
    FileName = current_object.name;
    WPTSeq = dlmread([TestingWPFolder,'\',FileName]);
    FileNameCell = {FileName};
    WPmap(j-2) = FileNameCell;
    WPSeqs(j-2) = {WPTSeq};
end

ClosestWPsCellArray = RecognizeWPskdTree( WPSeqs, LSHFilePath, FeatureTypeNum, closest );
UnrecognizedWP = [];
Success = 0;
for i=1:NumOfWords
    %Get the corresponding cell array that contains the closest elements of WP i
    ClosestWPs=ClosestWPsCellArray{i};
    
    if (size(ClosestWPs,1)>0)
        ind = find(ismember(ClosestWPs, WPmap(i))==1);
        if (ind>0)
            Success=Success+1;
        else
            UnrecognizedWP=[UnrecognizedWP; WPmap(i)];
            %     disp('-------------------------------------')
            %     disp(['The Word:' , WPmap(i)])
            %     disp('The Recognition:')
            %     for t=1:length(ClosestWPs)
            %         disp(ClosestWPs(t))
            %     end
        end
    end
    


%     %Print:
%     disp('-------------------------------------')
%     disp(['The Word:' , WPmap(i)])
%     disp('The Recognition:')
%     for t=1:length(ClosestWPs)
%         disp(ClosestWPs(t))
%     end
    
end
toc
Recognition_Rate = (Success/NumOfWords*100);

end
