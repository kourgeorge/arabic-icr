function [ conts] = AverageCont(cont)
conts(:,1)=conv(cont(:,1),[0.1; 0.1;0.4; 0.1; 0.1]);
conts(:,2)=conv(cont(:,2),[0.1 ;0.1;0.4; 0.1; 0.1]);
conts = conts(3:end-2,:);
end

