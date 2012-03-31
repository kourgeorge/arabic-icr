function GenerateSP_SVMStructFromFolder( FolderPath,SVMtargetPath )
%GENERATESP_SVMSTRUCTFROMFOLDER Summary of this function goes here
%   Detailed explanation goes here


if(~exist(SVMtargetPath,'dir'))
    mkdir(SVMtargetPath);
end
[ FeaturesMatrixIni,GroupingIni ] = CreateSPFeaturesFromFolder( [FolderPath,'Ini'] );
[ FeaturesMatrixMed,GroupingMed ] = CreateSPFeaturesFromFolder( [FolderPath,'Med'] );
FeaturesMatrix = [FeaturesMatrixIni;FeaturesMatrixMed];
Grouping = [GroupingIni;GroupingMed]
SVMStruct = svmtrain(FeaturesMatrix,Grouping);
save([SVMtargetPath,'\SVMStruct'], 'SVMStruct');
end

