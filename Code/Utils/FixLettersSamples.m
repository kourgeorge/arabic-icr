function  FixedSamplesCount= FixLettersSamples( LettersFolder )
%FIXLETTERSSAMPLES Summary of this function goes here
%   FixLettersSamples('C:\OCRData\data\LettersSamples')
% Rename the files.
% delete all image file and create new one.
% remove Inf points from the sample
% Print statistics of the sampleset

count = 0;
sampleNum = 0;
Sequences = [];
% Clean directory from image files
delete([LettersFolder,'\*.jpg']);
% get all files names (only .m files exist at this point.)
names = {names(~[names.isdir]).name};

% Rename all files names
for n = 1:numel(names)
    oldname = [LettersFolder '\' names{n}];
    newname = [LettersFolder '\old' names{n}];
    movefile(oldname,newname);
end

LettersFolderList = dir(LettersFolder);
for i = 3:length(LettersFolderList)
    current_object = LettersFolderList(i);
    IsFile=~[current_object.isdir];
    FileName = current_object.name;
    FileNameSize = size(FileName);
    LastCharacter = FileNameSize(2);
    if (IsFile==1 && FileName(LastCharacter)=='m')        
        seqFileName = [LettersFolder,'\',FileName];
        sequence = dlmread(seqFileName);
        delete(seqFileName);
        [~,indx]=ismember(sequence,[Inf,-Inf],'rows');
        InfIndexes = find(indx,1);
        if (sum(indx)==1 && InfIndexes<=0.5*size(sequence,1))
            newSequence = sequence(InfIndexes+1:end,:);
            count=count+1;
        elseif (sum(indx)==1 && InfIndexes>0.5*size(sequence,1))
            count=count+1;
            continue;
        elseif (sum(indx)>1 || size(sequence,1)<3)
            count=count+1;
            continue;
        else 
            newSequence = sequence;
        end
        sampleNum=sampleNum+1;
        Sequences = [Sequences ; {newSequence}];

    end
    if (IsFile==0 && isempty(findstr('svn', FileName)))
        folderName = [LettersFolder,'\',FileName];
        InnerCount = FixLettersSamples( folderName );
        count=count + InnerCount;
    end
end
if (sampleNum>0)
    [UniqueSequences,~,~] = uniquecell(Sequences);
    UniqueSampleNum = length(UniqueSequences);
    disp([LettersFolder,': ',num2str(UniqueSampleNum)])
    for j=1:UniqueSampleNum
        newSequence = UniqueSequences{j};
        sampleName = [LettersFolder,'\sample',num2str(j)];
        sequenceFileName = [sampleName,'.m'];
        imageFileName = [sampleName,'.jpg'];
        dlmwrite(sequenceFileName,newSequence);
        maxX = max(newSequence(:,1)); minX = min(newSequence(:,1)); maxY = max(newSequence(:,2)); minY = min(newSequence(:,2)); 
        windowSize = max(maxX-minX,maxY-minY); 
        ax = plot (newSequence(:,1),newSequence(:,2),'LineWidth',3);
        ylim([minY-0.1*windowSize minY+windowSize+0.1*windowSize]);
        xlim([minX-0.1*windowSize minX+windowSize+0.1*windowSize]);
        saveas(ax,imageFileName,'jpg');
    end
    
end
FixedSamplesCount = count;