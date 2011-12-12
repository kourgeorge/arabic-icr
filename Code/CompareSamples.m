function [AvgDists,Dists, MinDist,MinAvgDist] = CompareSamples(  FeatVecTest,FeatVecTemlates,CompareType,TempSize,TestSize)
TempSize = min(size(FeatVecTemlates,1),TempSize );
TestSize = min(size(FeatVecTest,1),TestSize);


Dists= zeros(TestSize,TempSize);
AvgDists= zeros(TestSize,TempSize);
for i=1:TestSize
    for j=1:TempSize
                NextWPFVS =  FeatVecTemlates{j,1};
% my change               CurWordTemp = FeatVecTemlates{j,2};
               SamplesSize = size(    NextWPFVS ,1);
               Diffs = zeros(SamplesSize,1);
               fprintf('%d : %d \n',i,j);
               for k=1: SamplesSize
                    if (CompareType == 1 || CompareType == 5)
                            %[p,q,D,Diffs(k),WarpingPath] = DTWContXY(FeatVecTest{i},NextWPFVS{k});
                               CurWordTest = FeatVecTest{i,1}; %2->1
                          %      [ PtsUpTemp,PtsDnTemp ] = CountDotsUpDN( CurWordTemp);
                          %      [ PtsUpTest,PtsDnTest ] = CountDotsUpDN( CurWordTest);
                          %      if (PtsUpTemp ~= PtsUpTest || PtsDnTemp~=PtsDnTest)
                          %          Diffs1= 10000;
                          %      else
                          %          Ratio=size(CurWordTest,1)/size(CurWordTemp,1);
                          %          if (Ratio > 0.7 || Ratio < 1.3)
                                            [p,q,D,Diffs1,WarpingPath] = DTWContXY(FeatVecTest{i,1},NextWPFVS);
                          %          else
                          %                  Diffs1= 10000;
                          %          end
                          %      end

                            %[p,q,D,Diffs2,WarpingPath] = DTWContXY(NextWPFVS{k},FeatVecTest{i,1});
                           Diffs(k) = Diffs1;%+Diffs2;
                    end
               
                    if (CompareType == 2 || CompareType == 5 )
                               CurWordTest = FeatVecTest{i,2};
                                [ PtsUpTemp,PtsDnTemp ] = CountDotsUpDN( CurWordTemp);
                                [ PtsUpTest,PtsDnTest ] = CountDotsUpDN( CurWordTest);
                                if (PtsUpTemp ~= PtsUpTest || PtsDnTemp~=PtsDnTest)
                                    Diffs1= 10000;
                                else
                                    Ratio=size(CurWordTest,2)/size(CurWordTemp,2);
                                    if (Ratio > 0.8 || Ratio < 1.2)
                                           [f,Diffs1] = EmdContXY(FeatVecTest{i,1},NextWPFVS{k});
                                    else
                                            Diffs1= 10000;
                                    end
                                end
                               %[f,Diffs2] = EmdContXY(NextWPFVS{k},FeatVecTest{i,1});
                               Diffs(k)=Diffs1;%2+Diffs1;
                    end
                    if (CompareType == 3 || CompareType == 5 )
                               [f,Diffs1] = EmdHOG(FeatVecTest{i,1},NextWPFVS{k});
                               %[f,Diffs2] = EmdContXY(NextWPFVS{k},FeatVecTest{i,1});
                               Diffs(k)=Diffs1;%2+Diffs1;
                    end
                    
                    if (CompareType == 4 || CompareType == 5 )
                               [f,Diffs1] = EmdGray(FeatVecTest{i,1},NextWPFVS{k});
                               %[f,Diffs2] = EmdContXY(NextWPFVS{k},FeatVecTest{i,1});
                               Diffs(k)=Diffs1;%2+Diffs1;
                    end
                    
               end
               % [p,q,D,Diff,WarpingPath] = DTWContXYShapeConext(Simcontours1{i},Simcontours2{j});
                
            %end
            %AvgDists(i,j) =sum(Diffs)/size(Diffs,1);
            AvgDists(i,j) = WAverage( Diffs );
            %Dists(i,j) =MyMinFun(Diffs);
            Dists(i,j) =min(Diffs);
    end
    %if min(Dists(i,:))<=10*threshold
       [ MinDist{i,1},MinDist{i,2}]  =min(Dists(i,:));
       MinDist{i,3} = FeatVecTest{i,2};
       MinDist{i,4} =FeatVecTemlates{MinDist{i,2},2} ;
       
       [ MinAvgDist{i,1},MinAvgDist{i,2}]  =min(AvgDists(i,:));
       MinAvgDist{i,3} = FeatVecTest{i,2};
       MinAvgDist{i,4} =FeatVecTemlates{MinAvgDist{i,2},2} ;
               
%        MinDist{i,3}=BoundingBoxes1(i,:);
 %       MinDist{i,4}=ResSimcontours1{i};
    %else
    %    MinDist{i,1}=100;
    %    MinDist{i,2}=i;    
    %    MinDist{i,3}=[0 0 0 0];
%         MinDist{i,4}=0;
%    end
%    AvgDist(i)=sum(Dists(i,:))/(l2);
end
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


end

