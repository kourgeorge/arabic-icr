function [ num_removed_letters , output_word ] = SimplifyWord2( input_word )
%UNTITLED Summary of this function goes here
%   [num_removed_letters , output_word ] = SimplifyWord(
%   '&#x62c;&#x648;&#x631;&#x62c;')
output_word = [];
num_removed_letters = 0;
for i=1:size(input_word)
    simplifiedLetter = simplifyletter (input_word(i,:));
    if (strcmp(simplifiedLetter,''))
        num_removed_letters= num_removed_letters+1;
    else
        output_word = [output_word;simplifiedLetter];
    end
    
end
end

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
        output_letter = '638';
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
        
    otherwise
        output_letter = '';
        return;
        
end
end