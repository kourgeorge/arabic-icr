function newWord = RemoveAdditonalStrokes(rec,word)

xmin = rec(1);
xmax = xmin+rec(3);
ymin = rec(2);
ymax = ymin + rec(4);
XV = [xmin xmax xmax xmin];
YV = [ymin ymin ymax ymax];
numStrokes = 1;
for i=1:size(word,2)
    Currword = word{i};
    if(all(inpolygon(Currword(:,1)',Currword(:,2)',XV',YV')==1))
        k=1;
    else
        newWord(numStrokes)={Currword};
        numStrokes = numStrokes + 1;
    end
end
