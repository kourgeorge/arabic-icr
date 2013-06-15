function [ output_xml ] = CreateXML(letter, pos, points)
%CreateXML Summary of this function goes here
%   Detailed explanation goes here

docNode = com.mathworks.xml.XMLUtils.createDocument('root');
    docRootNode = docNode.getDocumentElement;
    docRootNode.setAttribute('Letter',letter);
    docRootNode.setAttribute('Position',pos);
    CoordinatesElement = docNode.createElement('Coordinates');
    
    for i=1:length(points)
       CoordElement = docNode.createElement('Coord');
       CoordElement.setAttribute('X',num2str(points(i,1),5));
       CoordElement.setAttribute('Y',num2str(points(i,2),5));
       
       CoordinatesElement.appendChild(CoordElement);   
    end
    docRootNode.appendChild(CoordinatesElement);

output_xml=docNode;


end

