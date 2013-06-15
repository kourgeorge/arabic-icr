function [ MostCentrallyObjectsMatrix , CentroidLabels ] = CalculateMostCentrallyObject( FeaturesMatrix , Labeling )
%CALCULATRCENTROID Computes the Most centrally object for each class.
%   Detailed explanation goes here

uniqueLabels = unique (Labeling);
numOfClasses = size(uniqueLabels,1);
CentroidLabels = uniqueLabels;
MostCentrallyObjectsMatrix = zeros(numOfClasses, size(FeaturesMatrix,2));
for i=1:numOfClasses
    %find the elements that belog to class i.
    class = find(ismember(Labeling, uniqueLabels(i))==1);
    numOfElementsInClass = size(class,1);
    centerOfMass = zeros(1, size(FeaturesMatrix,2));
    objects = zeros (numOfElementsInClass , size(FeaturesMatrix,2));
    %calc the centerOfMass
    for j=1:numOfElementsInClass
        objects(j,:) = FeaturesMatrix(class(j),:);
        centerOfMass = centerOfMass + FeaturesMatrix(class(j),:);        
    end
    centerOfMass = centerOfMass/numOfElementsInClass;
    %find the closest object to the centerOfMass
    distOfObjects = objects - repmat(centerOfMass,[numOfElementsInClass,1]);
    for j=1:numOfElementsInClass
        distOfObjectsNorm(j,:) = norm(distOfObjects(j,:),1);
    end
    [~,IndexOfCentralObject] = min(distOfObjectsNorm);
    MostCentrallyObjectsMatrix(i,:) = FeaturesMatrix(class(IndexOfCentralObject),:);
end
