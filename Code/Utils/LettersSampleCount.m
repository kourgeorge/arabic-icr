function LettersSampleCount(LettersFolder)
%LETTERSSAMPLECOUNT Summary of this function goes here
%   LettersSampleCount('C:\OCRData\data\LettersSamples')

sampleNum = 0;
LettersFolderList = dir(LettersFolder);
for i = 3:length(LettersFolderList)
    current_object = LettersFolderList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 && FileName(LastCharacter)=='m')   
            sampleNum=sampleNum+1;
    end
    if (IsFile==0 && isempty(findstr('svn', FileName)))
        LettersSampleCount( [LettersFolder,'\',FileName] );
    end
    
end
if (sampleNum>0)
    disp([LettersFolder,': ',num2str(sampleNum)])
end
