function [ classification ] = MultiSVMClassify( MultiSVMStruct, tst )
%MYMULTISVMCLASSIFY Summary of this function goes here
%   Detailed explanation goes here
classification = [];
NumOfClasses = length(MultiSVMStruct);
for i=1:NumOfClasses
    classSVM = MultiSVMStruct(i);
    svmStruct = classSVM.SVM; 
    classes = svmclassify(svmStruct,tst(:)');
    if classes == 1
        classification = [classification; classSVM.Class];
    end
end

