function Sequence = ProgressiveRecognizerPen (DataFolder, Closest)
% Pen-Like data processing template
% pen.m is a GUI ready to use
%       the GUI calls a function called "process_data"

global in_writing;
global himage;

global folder kNN;

folder = DataFolder;
kNN = Closest;

ClearAll();

in_writing = 0;

% create the new figure
himage = figure;

set(himage,'numbertitle','off');                % treu el numero de figura
set(himage,'name','Progressive Recognizer Pen');% Name
set(himage,'MenuBar','none');                   % remove the menu icon
set(himage,'doublebuffer','on');                % two buffers graphics
set(himage,'tag','PEN');                        % identify the figure
set(himage,'Color',[0.95 0.95 0.95]);
set(himage,'Pointer','crosshair');

% create the axis
h_axes = axes('position', [0 0 1 1]);
set(h_axes,'Tag','AXES');
box(h_axes,'on');
%grid(h_axes,'on');
axis(h_axes,[0 1 0 1]);
%axis(h_axes,'off');
hold(h_axes,'on');

line([0 1],[0.3 0.3],'Color','black','LineWidth',2);
line([0 1],[0.5 0.5],'Color','black','LineWidth',2);
line([0 1],[0.7 0.7],'Color','black','LineWidth',2);

% ######  MENU  ######################################
h_opt = uimenu('Label','&Options');
uimenu(h_opt,'Label','Clear','Callback',@ClearAll);
uimenu(h_opt,'Label','Exit','Callback','closereq;','separator','on');


% create the text
h_text = uicontrol('Style','edit','Units','normalized','Position',[0 0.9 1 0.10],'FontSize',10,'HorizontalAlignment','left','Enable','inactive','Tag','TEXT');

set(himage,'WindowButtonDownFcn',@movement_down);
set(himage,'WindowButtonUpFcn',@movement_up);
set(himage,'WindowButtonMotionFcn',@movement);
uiwait;

% #########################################################################

% #########################################################################
function ClearAll(hco,eventStruct)

global x_pen y_pen Stat LastIndexes Candidates;

% erase previous drawing
delete(findobj('Tag','SHAPE'));
delete(findobj('Tag','BOX'));

% delete previous data
x_pen = [];
y_pen = [];

% if necessary
himage = findobj('tag','PEN');

%Initialize parameters for the progressive recognition algorithm
Stat=1;
Candidates = {};
LastIndexes=[];
LastIndexes(1)=1;

% #########################################################################

% #########################################################################
function movement_down(hco,eventStruct)

global in_writing x_pen y_pen;
%Enter to state 1 as in the first phase we will try to recognize only 1
%stroke word parts.


% toggle
in_writing = 1;

% restore point
h_axes = findobj('Tag','AXES');
p = get(h_axes,'CurrentPoint');
x = p(1,1);
y = p(1,2);

% cumulative data
x_pen = [x_pen x];
y_pen = [y_pen y];

set(findobj('Tag','TEXT'),'String','Current State: 1 ');

% draw
plot(h_axes,x,y,'b.','Tag','SHAPE','LineWidth',3);
% #########################################################################

% #########################################################################
function movement_up(hco,eventStruct)
global in_writing x_pen y_pen Candidates;

% toggle
in_writing = 0;

h_axes = findobj('Tag','AXES');

% analysis of what has been pressed
% delete box above
delete(findobj('Tag','BOX'));

% marcar un requadre
x_i = min(x_pen);
x_f = max(x_pen);
x_d = max([1 (x_f - x_i)]);
y_i = min(y_pen);
y_f = max(y_pen);
y_d = max([1 (y_f - y_i)]);
plot(h_axes,[x_i x_f x_f x_i x_i],[y_i y_i y_f y_f y_i],'K:','MarkerSize',22,'Tag','BOX');
process_data(x_pen,y_pen,true);
%close;
% #########################################################################

% #########################################################################
function movement(hco,eventStruct)

global in_writing x_pen y_pen;

if in_writing
    % button pressing
    
    h_axes = findobj('Tag','AXES');
    
    p = get(h_axes,'CurrentPoint');
    x = p(1,1);
    y = p(1,2);
    
    
    if ((y < 0) || (y > 1) || (x < 0) || (x > 1))
        % do nothing
        return;
    end
    
    if ((x ~= x_pen(end)) || (y ~= y_pen(end)))
        % next point
        x_pen = [x_pen x];
        y_pen = [y_pen y];
        
        plot(h_axes,[x_pen(end-1) x],[y_pen(end-1) y],'b.-','Tag','SHAPE','LineWidth',3);
    end
    process_data(x_pen,y_pen,false);
end

% #########################################################################


% #########################################################################
function process_data(x_pen,y_pen,IsMouseUp)
% x_pen, y_pen are the current point locations
global LastIndexes Candidates Stat;

Sequence(:,1) = x_pen;
Sequence(:,2) = y_pen;

[len,m] = size(Sequence);
Alg = {'EMD' 'MSC' 'kdTree'};

% Algorithm parameters
theta=0.144; %0.144
K = 20;
ST = 0.05; %Simplification algorithm tolerance
MinLen = 0.6;
MaxSlope = 0.1;
EnvLength=5;

old_state = Stat;
if(IsMouseUp==true)
    [Stat ,LastIndexes,Candidates] = ProgressiveRecognition( Alg, Stat, Sequence, LastIndexes, Candidates, theta, IsMouseUp );
else
    if (rem(len,K)==0)
        if(Stat==1)
            seqLen = SequenceLength(Sequence);
            simplified  = dpsimplify(Sequence,ST);
        else
            sub_s= Sequence(LastIndexes(Stat-1):len,:);
            seqLen = SequenceLength(sub_s);
            simplified  = dpsimplify(sub_s,ST);
        end
        %Mark every K points
        plot(findobj('Tag','AXES'),Sequence(len-1:len,1),Sequence(len-1:len,2),'c.-','Tag','SHAPE','LineWidth',3);
        
        %Slope calculation
        start_env= Sequence(len-EnvLength,:);
        end_env= Sequence(len,:);
        slope = abs((end_env(2)-start_env(2))/(end_env(1)-start_env(1)));
        
        %Try to recognize a letter only if all the following holds: 
        %1. The current Sub sequence is longer than MinLen
        %2. The current Sub sequence contains enough information
        %3. The point environmnt is horizontal
        if ((slope<MaxSlope && (length(simplified)-1)*seqLen>MinLen) && ~(seqLen> MinLen && length(simplified)>3 && slope<MaxSlope))  %need to make sure this condition is good enough
            len_simp_str=num2str(length(simplified));
            seqLen_str=num2str(seqLen);
            MinLen_str = num2str(MinLen);
            disp(['WARNING: length(simplified)= ',len_simp_str,'   seqLen = ',seqLen_str,'  >  ',MinLen_str]);            
        end
        if ((seqLen> MinLen && length(simplified)>3 && slope<MaxSlope) || (slope<MaxSlope && length(simplified)*seqLen>MinLen))
            [Stat ,LastIndexes,Candidates] = ProgressiveRecognition( Alg, Stat, Sequence, LastIndexes, Candidates, theta, IsMouseUp );
            %Mark the points where the ProgressiveRecognition algorithm was performed.
            plot(findobj('Tag','AXES'),Sequence(len-1:len,1),Sequence(len-1:len,2),'g.-','Tag','SHAPE','LineWidth',7);
            if (old_state < Stat)
                %Mark the points where there were a state transition.
                plot(findobj('Tag','AXES'),Sequence(len-1:len,1),Sequence(len-1:len,2),'r.-','Tag','SHAPE','LineWidth',7);
            end
        else
            %Notify which condition didn't hold.
            if (seqLen <= MinLen)
                display('Sub-Sequence length too Short')
            end
            if (length(simplified)<=2)
                display ('Sub-Sequence is too Simple') 
            end
            if (slope>=MaxSlope)
                display ('The point environment is not Horizontal Enough')
            end
            display(' ') 
            display(' ')
        end
    end
end

%Handle the Title
if (old_state < Stat || IsMouseUp==true)
    stat_str= num2str(Stat);
    str = '';
    if (Stat>1)
        CurrCan = Candidates{Stat-1};
        for i=1:length(CurrCan)
            str = [str,'  ',CurrCan{i}];
        end
        if (Stat==2)
            endIndex = num2str(LastIndexes(Stat-1));
            set(findobj('Tag','TEXT'),'String',['[Current State: ', stat_str,']  ','   Previous State:- ',' Interval: 0 - ',  endIndex, ' Candidates: ' str]);
        else
            startIndex = num2str(LastIndexes(Stat-2));
            endIndex = num2str(LastIndexes(Stat-1));
            set(findobj('Tag','TEXT'),'String',['[Current State: ' stat_str, ']  ','   Previous State:- ',' Interval: ' , startIndex, ' - ',  endIndex, '   Candidates: ' str]);
        end
    else
        CurrCan = Candidates{Stat};
        for i=1:length(CurrCan)
            str = [str,'  ',CurrCan{i}];
        end
        endIndex = num2str(LastIndexes(Stat));
        set(findobj('Tag','TEXT'),'String',['[Current State: ', stat_str,']  ',' Interval: 0 - ',  endIndex, ' Candidates: ' str]);
    end
end

%Output all the candidates.
if (IsMouseUp==true)
    for i=1:Stat-1
        if (i==1)
            startIndex = num2str(0);
        else
            startIndex = num2str(LastIndexes(i-1));
        end
        endIndex = num2str(LastIndexes(i));
        i_str = num2str(i);
        disp (['State : ',i_str,',  ',startIndex,' - ',endIndex])
        CurrCan = Candidates{i};
        str = '';
        for j=1:length(CurrCan)
            str = [str,' ',CurrCan{j}];
        end
        disp(['Candidates:  ',str])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%