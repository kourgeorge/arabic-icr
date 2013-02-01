function  LetterDS = ReadLetterData( LetterFolder,ResampleSize)
%%% This functions as an input a folder that contains a single all samples of a letter in all its possition, and return a data structure
%%% that contains all the samples in all positions after resampling and
%%% simplifying.
LetterDS.Ini = ReadLetterPositionSamples([LetterFolder,'\','Ini'],ResampleSize);
LetterDS.Mid = ReadLetterPositionSamples([LetterFolder,'\','Mid'],ResampleSize);
LetterDS.Fin = ReadLetterPositionSamples([LetterFolder,'\','Fin'],ResampleSize);
LetterDS.Iso = ReadLetterPositionSamples([LetterFolder,'\','Iso'],ResampleSize);
end