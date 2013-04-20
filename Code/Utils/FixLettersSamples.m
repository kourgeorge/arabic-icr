function  FixedSamplesCount= FixLettersSamples( LettersFolder )
%FIXLETTERSSAMPLES Summary of this function goes here
%   FixLettersSamples( 'C:\OCRData\LettersSamplesTest')
count = 0;
ax = axes();
LettersFolderList = dir(LettersFolder);
for i = 3:length(LettersFolderList)
    current_object = LettersFolderList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 && FileName(LastCharacter)=='m')
        seqFileName = [LettersFolder,'\',FileName];
        imageFileName = [seqFileName(1:end-2),'.jpg'];
        sequence = dlmread(seqFileName);
        [~,indx]=ismember(sequence,[Inf,-Inf],'rows');
        InfIndexes = find(indx,1);
        if (sum(indx)==1 && InfIndexes<=0.5*size(sequence,1))
            newSequence = sequence(InfIndexes+1:end,:);
            delete(seqFileName);
            delete(imageFileName);
            dlmwrite(seqFileName,newSequence);
            plot (ax, newSequence(:,1),newSequence(:,2),'LineWidth',3);
            saveas(ax,imageFileName,'jpg');
            count=count+1;
        end
        if (sum(indx)==1 && InfIndexes>0.5*size(sequence,1))
            delete(seqFileName);
            delete(imageFileName);
            count=count+1;
        end
        if (sum(indx)>1 || size(sequence,1)<3)
            delete(seqFileName);
            delete(imageFileName);
            count=count+1;
        end
    end
    if (IsFile==0 && isempty(findstr('svn', FileName)))
        InnerCount = FixLettersSamples( [LettersFolder,'\',FileName] );
        count=count + InnerCount;
    end
end
FixedSamplesCount = count;