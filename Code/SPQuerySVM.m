function [ Group ] = SPQuerySVM( SVMStructPath ,Sample)
%SPQUERYSVM Summary of this function goes here
%   Detailed explanation goes here
loadedSVMStruct = load(SVMStructPath);
SVMStruct = loadedSVMStruct.SVMStruct;
FeaturesRow = Sample;
Group = svmclassify(SVMStruct,FeaturesRow);
end

