function [arabascii,theLetter] = parseUPX(filename,UpxTarget)
strfortext=[UpxTarget,'\upx\',filename,'.upx'];
xmlToMatlabStruct = theStruct(strfortext);
arabascii=xmlToMatlabStruct.Children(1,6).Children(1,2).Children(1,2).Children(1,2).Attributes.Value;
%arabascii = regexp(xmlToMatlabStruct.Children(1,6).Children(1,2).Children(1,2).Children(1,2).Attributes.Value,';','split');
theLetter = [];
arabascii = double(arabascii);
arabascii = dec2hex(arabascii);
len = size(arabascii);
j=1;
for i=1 : len(1)
        simplifiedLetter = simplifyletter(arabascii(j,:));
        
   switch simplifiedLetter
         case ''
          theLetter=[theLetter ' '];
       case '627'
          theLetter=[theLetter 'A'];
          
      case '628'
          theLetter=[theLetter 'B'];
          
      case '62D'
          theLetter=[theLetter '7'];   
          
       case '62F'
          theLetter=[theLetter 'D'];   

       case '631'
          theLetter=[theLetter 'R'];   
            
       case '633'
          theLetter=[theLetter 'S'];   
            
       case '635'
          theLetter=[theLetter '8'];   
                  
       case '637'
          theLetter=[theLetter '6'];   
                  
       case '639'
          theLetter=[theLetter '3'];   
                   
        case '641'
          theLetter=[theLetter 'F'];
          
        case '644'
          theLetter=[theLetter 'L'];   
           
        case '643'
          theLetter=[theLetter 'K'];   
            
        case '645'
          theLetter=[theLetter 'M'];   
             
        case '646'
          theLetter=[theLetter 'N'];   
              
       case '648'
          theLetter=[theLetter 'W'];   
          
       case '64A'
          theLetter=[theLetter 'Y'];   
               
      case '647'
          theLetter=[theLetter 'H'];   
      case '621'
          theLetter=[theLetter 'E'];
       otherwise
           theLetter=theLetter;
       
          
   end
   j=j+1;
end
theLetter = strrep(theLetter,'LA','X');



function output_letter = simplifyletter (input_letter)

switch input_letter
    %A
    case '622'
        output_letter = '627';
    case '623'
        output_letter = '627';
    case '625'
        output_letter = '627';
    case '627'
        output_letter = '627';
    case '671'
        output_letter = '627';
        return
        %B
    case '628'
        output_letter = '628';
    case '62A'
        output_letter = '628';
    case '62B'
        output_letter = '628';
        return
        %7
    case '62D'
        output_letter = '62D';
    case '62C'
        output_letter = '62D';
    case '62E'
        output_letter = '62D';
        return
        %D
    case '62F'
        output_letter = '62F';
    case '630'
        output_letter = '62F';
        return
        %R
    case '631'
        output_letter = '631';
    case '632'
        output_letter = '631';
        return
        %S
    case '633'
        output_letter = '633';
    case '634'
        output_letter = '633';
        return
        %8
    case '635'
        output_letter = '635';
    case '636'
        output_letter = '635';
        return
        %6
    case '637'
        output_letter = '637';
    case '638'
        output_letter = '637';
        return
        %3
    case '639'
        output_letter = '639';
    case '63A'
        output_letter = '639';
        return
        %F
    case '641'
        output_letter = '641';
    case '642'
        output_letter = '641';
        return
        %L
    case '644'
        output_letter = '644';
        return
        %K
    case '643'
        output_letter = '643';
        return
        %M
    case '645'
        output_letter = '645';
        return
        %N
    case '646'
        output_letter = '646';
        return
        %W
    case '648'
        output_letter = '648';
    case '624'
        output_letter = '648';
        return
        %Y
    case '64A'
        output_letter = '64A';
    case '649'
        output_letter = '64A';
    case '626'
        output_letter = '64A';
        return
        %H
    case '647'
        output_letter = '647';
    case '629'
        output_letter = '647';
        return
    case '020'
        output_letter = '';
        return
        %E
    case '621'
        output_letter = '621';
        return;
    otherwise
         output_letter = '999';
         return;
        
end