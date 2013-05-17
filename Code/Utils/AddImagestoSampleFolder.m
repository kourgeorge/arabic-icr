function [ output_args ] = AddImagestoSampleFolder( SampleFolder )
%ADDIMAGESTOSAMPLEFOLDER Summary of this function goes here
%   AddImagestoSampleFolder( 'C:\OCRData\WPsLabeled' )


delete([SampleFolder,'\*.jpg']);
sampleFolderList = dir (SampleFolder);
for i=3:size(sampleFolderList,1)
    current_object = sampleFolderList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName,2);
    if (IsFile==1 && FileName(FileNameSize)=='m')
        seqFileName = [SampleFolder,'\',FileName];
        sequence = dlmread(seqFileName);
        maxX = max(sequence(:,1)); minX = min(sequence(:,1)); maxY = max(sequence(:,2)); minY = min(sequence(:,2));
        windowSize = max(maxX-minX,maxY-minY);
        ax = plot (sequence(:,1),sequence(:,2),'LineWidth',3);
        ylim([minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
        xlim([minX-0.1*windowSize minX+windowSize+0.1*windowSize]);
        imageFileName = [seqFileName,'.jpg'];
        saveas(ax,imageFileName,'jpg');
    end
end

