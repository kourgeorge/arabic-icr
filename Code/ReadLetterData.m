function  LetterDS = ReadLetterData( LetterFolder,ResampleSize)
LetterDS.Ini = ReadLetterPositionSamples([LetterFolder,'\','Ini'],ResampleSize);
LetterDS.Mid = ReadLetterPositionSamples([LetterFolder,'\','Mid'],ResampleSize);
LetterDS.Fin = ReadLetterPositionSamples([LetterFolder,'\','Fin'],ResampleSize);
LetterDS.Iso = ReadLetterPositionSamples([LetterFolder,'\','Iso'],ResampleSize);
end