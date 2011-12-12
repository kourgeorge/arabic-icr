function [ WordSeq ] = GenerateWord(LetterSamplesFolder, Word , Class)
% Summaty:
%   This function gets a connected component word as inglisg letters and 
%   output a 2-dimentional vector that describe the word part contour  
% Input:
%   Word - The word in english letters ex. 7L, 8BA
% Output
%   WordSeq - 2xN dimentional vector that include the connected component
%   sequence.
%   N - the number of points in the connected components.
%
% Test Case: WordSeq= GenerateWord( 'B7R' , 'sample1')

Dims = size(Word);  
Len = Dims(1,2); 


if (Len==1)
     Let = Word(1);
     WordSeq = GetLetSeq(LetterSamplesFolder,Let,'Iso',Class);
    return;
end

for i=1:Len
if (i==1)
     Let = Word (1);
     LetSeq = GetLetSeq(LetterSamplesFolder, Let,'Ini',Class);

     SeqLength = size(LetSeq,1);
     WordSeq = LetSeq;
end

if (i> 1 && i < Len) %Midial = 4
     Let = Word(i);
     LetSeq = GetLetSeq(LetterSamplesFolder, Let,'Mid',Class);
     
     %get the end point of the previous vector
     WordSeqLength = size(WordSeq,1);
     Endx = WordSeq(WordSeqLength,1);
     Endy = WordSeq(WordSeqLength,2);
     
     Startx = LetSeq(1,1); 
     Starty = LetSeq(1,2); 
     Diffx = Endx - Startx;
     Diffy = Endy - Starty;
     LetSeq(:,1) = LetSeq(:,1)+ Diffx;
     LetSeq(:,2) = LetSeq(:,2) + Diffy;
     WordSeq = [WordSeq ; LetSeq];
end

if (i==Len) %Initial =3
     Let = Word(Len);
     LetSeq = GetLetSeq(LetterSamplesFolder, Let,'Fin',Class);
     
     %get the end point of the previous vector
     WordSeqLength = size(WordSeq,1);
     Endx = WordSeq(WordSeqLength,1);
     Endy = WordSeq(WordSeqLength,2);
     
     Startx = LetSeq(1,1); 
     Starty = LetSeq(1,2); 
     Diffx = Endx - Startx;
     Diffy = Endy - Starty;
     LetSeq(:,1) = LetSeq(:,1)+ Diffx;
     LetSeq(:,2) = LetSeq(:,2) + Diffy;
     WordSeq = [WordSeq ; LetSeq];
end
end
end
