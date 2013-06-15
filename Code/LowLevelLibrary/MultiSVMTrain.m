function [ MultiSVMStruct ] = MultiSVMTrain( training, groupnames)
%MYMULTISVMTRAIN Summary of this function goes here
%   Detailed explanation goes here

classes=unique(groupnames);
numOfClasses = size(classes,1);
for itr=1:numOfClasses
    c1=(groupnames==classes(itr)); %highlight all the samples from class itr
    newClass=c1;
    svmStruct = svmtrain(training,newClass,'kernel_function','rbf');
    classSVM.SVM =  svmStruct;
    classSVM.Class = classes(itr);
    MultiSVMStruct(itr) = classSVM;
end
end

