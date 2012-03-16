function GenerateSP_SVMStructFromFolder( FolderPath,SVMtargetPath )
%GENERATESP_SVMSTRUCTFROMFOLDER Summary of this function goes here
%   Detailed explanation goes here


if(~exist(SVMtargetPath,'dir'))
    mkdir(SVMtargetPath);
end
[ FeaturesMatrix,Grouping ] = CreateSPFeaturesFromFolder( FolderPath );
SVMStruct = svmtrain(FeaturesMatrix,Grouping);
save([SVMtargetPath,'\SVMStruct'], 'SVMStruct');
end

