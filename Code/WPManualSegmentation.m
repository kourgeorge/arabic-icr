function [ output_args ] = WPManualSegmentation( WPSequence )
%WPMANUALSEGMENTATION Summary of this function goes here
%   Detailed explanation goes here
% WPSequence = dlmread('');


global himage;
himage = figure;

% set(himage,'numbertitle','off');                % treu el numero de figura
% set(himage,'name','Progressive Recognizer Pen');% Name
% set(himage,'MenuBar','none');                   % remove the menu icon
% set(himage,'doublebuffer','on');                % two buffers graphics
% set(himage,'tag','PEN');                        % identify the figure
% set(himage,'Color',[0.95 0.95 0.95]);
% set(himage,'Pointer','crosshair');

% create the axis
h_axes = axes('position', [0 0 1 1]);
set(h_axes,'Tag','AXES');
%grid(h_axes,'on');
axis(h_axes,[0 1 0 1]);
%axis(h_axes,'off');
hold(h_axes,'on');

plot (WPSequence(:,1),WPSequence(:,2));
set(himage,'WindowButtonDownFcn',@mouse_down);

end



function mouse_down(hco,eventStruct)
p = get(h_axes,'CurrentPoint');
x = p(1,1);
y = p(1,2);

end

