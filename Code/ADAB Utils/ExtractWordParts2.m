function [ WPs ] = ExtractWordParts2( input_word )
%COUNTWORDPARTS Summary of this function goes here
%   [ WPs ] = ExtractWordParts('&#x62d;&#x648;&#x631;&#x62d;')  %7or7
%   [ WPs ] = ExtractWordParts('&#x648;&#x631;&#x62f;')         &wrd 

WPs = [];
WP = [];
for i=1:size(input_word,1)
    letter = input_word(i,:);
    WP = [WP;letter];
    if (ending_letter(letter))
        WPs = [WPs;{WP}];
        WP = [];
    end
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

switch letter 
    %D
    case '62F'
        res = 1;
        return;
    %R
    case '631'
        res = 1;
        return;
    %A
    case '627'
        res = 1;
        return;
    %W
    case '648'
        res = 1;
        return;
    otherwise
        res = 0;
        return;
end
end
        