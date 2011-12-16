function [ WPs ] = ExtractWordParts( input_word )
%COUNTWORDPARTS Summary of this function goes here
%   [ WPs ] = ExtractWordParts('&#x62d;&#x648;&#x631;&#x62d;')  %7or7
%   [ WPs ] = ExtractWordParts('&#x648;&#x631;&#x62f;')         &wrd 

WPs = [];
parts = regexp(input_word,';','split');
parts = parts(1,1:size(parts,2)-1);
ending_positions = ending_letters_position(parts);
ind = 1;
for i=1:size(ending_positions,1)
    letter = parts(ind);
    WP = letter{1};
    ind = ind+1;
    for j=ind:ending_positions(i)
       letter = parts(ind);
       WP = [WP,';',letter{1}];
       ind = ind+1;
    end
    WPs = [WPs;{WP}];
end
end

function positions = ending_letters_position(parts)
positions = [];
for i=1:size(parts,2)
    letter  = parts(i);
    if (ending_letter(letter))
        positions = [positions ; i];
    end
end

%if the last letter is not an ending letter then make it an ending letter
last_letter = parts(size(parts,2));
if (~ending_letter(last_letter))
    positions = [positions ; size(parts,2)];
end
end

function res =  ending_letter (letter)
letter = letter{1};
switch letter 
    %D
    case '&#x62f'
        res = 1;
        return;
    %R
    case '&#x631'
        res = 1;
        return;
    %A
    case '&#x627'
        res = 1;
        return;
    %W
    case '&#x648'
        res = 1;
        return;
    otherwise
        res = 0;
        return;
end
end
        