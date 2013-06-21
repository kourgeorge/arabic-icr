function [ WordsList ] = GetTopKCandidatesFromLetterMatrix( LettersMatrix , k)
%GETWORDCANDIDATESFROMLETTERMATRIX Summary of this function goes here
%   Detailed explanation goes here

Words = [];
WordsList = GetPossibleWordsFromLettersMatrix_rec(LettersMatrix,1,Words);
WordsList = GetTopKWords(WordsList ,10);
end

function WordsRes = GetPossibleWordsFromLettersMatrix_rec(LettersMatrix,row,Words)

if (row>size(LettersMatrix,1))
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
            if (isempty(LettersMatrix(row,j).Label))
                continue;
            end
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

TopkWords = Asorted(1:min(k,size(WordsList,2)));

end

