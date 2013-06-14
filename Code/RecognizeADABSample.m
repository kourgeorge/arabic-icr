function [ output_args ] = RecognizeADABSample( DataSetPath, filename )
%RECOGNIZEADABSAMPLE Summary of this function goes here
%   Detailed explanation goes here
%   RecognizeADABSample( 'C:\Users\kour\OCRData Old\Archieve\adab_database_v1.0\Data\set_1', '1232273782390' )

% 4. Find all words combinations from the found letters
% 5. check with the adab database and select the best matches
% 6. calculate Recognition score


% 1. Parse UPX
UPXpath = [DataSetPath,'\','upx\'];
[temping,EnglishWord] = parseUPX(filename,UPXpath);
arabAscii = ArabicAscii(filename,UPXpath);

% 2. Read inkml
WordSequenceCells = ConvertInkmlToSequence( DataSetPath, filename );
WordSequence = Struct2Sequece(WordSequenceCells);

% 4. for each stroke, recognize stroke (if it is an additional stroke, keep to the end)
[MainStrokesResults,AdditionalStrokesResults] = SimulateOnlineRecognizer( WordSequence, true, true);

%Get the letters from the recognition results 
LettersMatrix = GetLettersCandidatesMatrix (MainStrokesResults);

% Handle additional strokes
% RecResults = HandleAddionalStrokes( RecResults, AdditionalStrokes)

WordsList = GetPossibleWordsFromLettersMatrix (LettersMatrix);

end

function WordSequence = Struct2Sequece(Word)
WordSequence = [];
for i=1:size(Word,2)
    temp = Word{i};
    WordSequence  = [WordSequence;Inf,Inf;temp];
end
WordSequence = WordSequence(2:end,:);

end

function LettersMatrix = GetLettersCandidatesMatrix (RecResults)
LetterIndex = 1;
for i=1:size(RecResults,2)
    StrokeRecResults = RecResults(i);
    for j=1:length(StrokeRecResults.SegmentationPoints)
        LettersRecResults = StrokeRecResults.SegmentationPoints{j};
        LetterCandidates = LettersRecResults.Candidates;
        LetterCandidates = LetterCandidates(:,1:2);
        LetterCandidatesMat = cell2mat(LetterCandidates(:,2));
        SumCandidates = sum(LetterCandidatesMat);
        LetterCandidatesMat = bsxfun(@rdivide,repmat( SumCandidates,length(LetterCandidatesMat),1),LetterCandidatesMat);
        SumCandidates = sum(LetterCandidatesMat);
        LetterCandidatesMat = bsxfun(@ldivide,repmat( SumCandidates,length(LetterCandidatesMat),1),LetterCandidatesMat);
        
        for Candidateindex=1:length(LetterCandidatesMat)
            LetterCandidates{Candidateindex,2} = LetterCandidatesMat(Candidateindex);
            LetterInfo.Label = LetterCandidates{Candidateindex,1};
            LetterInfo.Score = LetterCandidates{Candidateindex,2};
            LettersMatrix(LetterIndex,Candidateindex) = LetterInfo; 
        end
        LetterIndex = LetterIndex +1;
    end
end
end

function WordsList = GetPossibleWordsFromLettersMatrix (LettersMatrix)
Words = [];
    WordsList = GetPossibleWordsFromLettersMatrix_rec(LettersMatrix,1,Words);
    WordsList = GetTopKWords(WordsList ,10);
end

function WordsRes = GetPossibleWordsFromLettersMatrix_rec(LettersMatrix,row,Words)

if (row>length(LettersMatrix))
    WordsRes = Words;
    return;
end
k=1;
if (length(Words)==0)
    for j=1:length(LettersMatrix(row,:))
        newWord.Label = LettersMatrix(row,j).Label;
        newWord.Score = LettersMatrix(row,j).Score;
        newWords(j) =  newWord;
    end
else
    for i=1:length(Words)
        for j=1:length(LettersMatrix(row,:))
            newWord.Label = [Words(i).Label,LettersMatrix(row,j).Label];
            newWord.Score = Words(i).Score*LettersMatrix(row,j).Score;
            newWords(k) =  newWord;
            k = k+1;
        end
    end
end
Words = newWords;
WordsRes = GetPossibleWordsFromLettersMatrix_rec(LettersMatrix,row+1,Words);
end

function TopkWords = GetTopKWords(WordsList ,k)

Afields = fieldnames(WordsList);
Acell = struct2cell(WordsList);
sz = size(Acell);            % Notice that the this is a 3 dimensional array.
                            % For MxN structure array with P fields, the size
                            % of the converted cell array is PxMxN
% Convert to a matrix
Acell = reshape(Acell, sz(1), []);      % Px(MxN)

% Make each field a column
Acell = Acell';                         % (MxN)xP

% Sort by first field "Score"
Acell = sortrows(Acell, -2);

% Put back into original cell array format
Acell = reshape(Acell', sz);

% Convert to Struct
Asorted = cell2struct(Acell, Afields, 1);

TopkWords = Asorted(1:k);

end