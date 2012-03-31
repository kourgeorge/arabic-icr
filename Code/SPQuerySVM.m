function Res = SPQuerySVM( SVMStructPath ,Sample)
%SPQUERYSVM Summary of this function goes here
%   Detailed explanation goes here
loadedSVMStruct = load(SVMStructPath);
SVMStruct = loadedSVMStruct.SVMStruct;
FeaturesRow = Sample;
Group = svmclassify(SVMStruct,FeaturesRow);
if (Group==1)
    Res = true;
else
    Res = false;
end
end

