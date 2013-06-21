function [ output_args ] = RecognizeADABSample( DataSetPath, filename )
%RECOGNIZEADABSAMPLE Summary of this function goes here
%   Detailed explanation goes here
%   RecognizeADABSample( 'C:\Users\kour\OCRData Old\Archieve\adab_database_v1.0\Data\set_1', '1232016825158' )

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

WordsList = GetTopKCandidatesFromLetterMatrix (LettersMatrix , 10);

end

