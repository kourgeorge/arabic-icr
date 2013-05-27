function [ResAngsOfCont]   = MultiResMSC( cont)%,NumOfRes )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%DTW Case
[AngsOfContDTW] = MSC_Circular(cont); %Good for DTW and less for EMD
%ResAngsOfCont = AngsOfContDTW;

%Emd Case 
cont = AverageCont(cont);  %Good for EMD but not for DTW
[AngsOfCont] = MSC_Circular(cont); %Good for DTW and less for EMD
AngsOfContEMD = [AngsOfContDTW; AngsOfCont]; 
ResAngsOfCont = AngsOfContEMD;




end

