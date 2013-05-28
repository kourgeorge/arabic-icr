function [theLetter] = ArabicAscii(filename,UPXtarget)
% This function to get the the WORD name from a file
strfortext=char(strcat(UPXtarget,filename,'.upx'));
xmlToMatlabStruct = theStruct(strfortext);
theLetter=xmlToMatlabStruct.Children(1,6).Children(1,2).Children(1,2).Children(1,2).Attributes.Value;