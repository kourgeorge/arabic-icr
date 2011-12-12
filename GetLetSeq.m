function [ LetterSequence ] = GetLetSeq(LetterSamplesFolder, Letter, Pos, Class )
%GETLETSEQ Summary of this function goes here
%   This functiona get a letter as an input parameter and looks in the
%   filesystem for the sequence description of the letter, convert it to a
%   2 dimentaional array and return it
%
% Test Case: LetSeq = GetLetSeq('7','Mid','sample1')

SamplesFolder =LetterSamplesFolder;

FontFile=[SamplesFolder,'\',Letter,'\',Pos,'\',Class,'.m'];
LetterSequence = dlmread(FontFile);
end

