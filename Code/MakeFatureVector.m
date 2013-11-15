function [ FaeatureVector] = MakeFatureVector(Sequence,TypeOfFature)
%Features:
% 0 - Contour/Sequence
% 1 - Angular
% 2 - Shape Context

NumOfWPTS=size(Sequence,1);
FaeatureVector = cell(NumOfWPTS,2);

if (TypeOfFature == 0)
    FaeatureVector = Sequence;
    return;
end
if (TypeOfFature == 1)
    FaeatureVector = MultiResMSC(Sequence);%,2);
    return
end



if (TypeOfFature == 2)
    
    r_inner=1/8;
    r_outer=sqrt(2);
    mean_dist_global=[]; % use [] to estimate scale from the data
    nbins_theta=12;
    nbins_r=5;
    
    nsamp=size(Sequence,1);
    out_vec=zeros(1,nsamp);
    
    [FaeatureVector,mean_dist_1]=sc_compute((Sequence)',zeros(1,nsamp),mean_dist_global,nbins_theta,nbins_r,r_inner,r_outer,out_vec);
    return;
end

if (TypeOfFature == 3)
    nsamp=size(Sequence,1);
    FaturesValues = zeros(1,nsamp-1);
    for i=1:nsamp-1
        FaturesValues(i) = rad2deg(edgeAngle([Sequence(i,:) Sequence(i+1,:)]));
    end
    FaeatureVector = FaturesValues;
    return;
end

