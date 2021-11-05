function [ ] = graph111( inputVector1, inputVector2, inputVector3)
%GRAPH111 iscrtava 3 ulazna vektora, svaki u okviru posebnog grafika 
%   Detailed explanation goes here

input1Length = length(inputVector1);
input2Length = length(inputVector2);
input3Length = length(inputVector3);
input1Step = floor(input1Length/50);
input2Step = floor(input2Length/50);
input3Step = floor(input3Length/50);

figure1 = figure;

axes1 = axes('Parent',figure1,...
    'Position',[0.03 0.70 0.95 0.26]);
plot(axes1, inputVector1)
xlim(axes1,[0 input1Length]);
set(axes1, 'XTick', 0:input1Step:input1Length)
set(axes1, 'XGrid', 'on')
box(axes1,'on');
title(inputname(1))

axes2 = axes('Parent', figure1,...
    'Position', [0.03 0.37 0.95 0.27]);
plot(axes2, inputVector2)
xlim(axes2,[0 input2Length]);
set(axes2, 'XTick', 0:input2Step:input2Length)
set(axes2, 'XGrid', 'on')
box(axes2,'on');
title(inputname(2))

axes3 = axes('Parent', figure1,...
    'Position', [0.03 0.04 0.95 0.27]);
plot(axes3, inputVector3)
xlim(axes3,[0 input3Length]);
set(axes3, 'XTick', 0:input3Step:input3Length)
set(axes3, 'XGrid', 'on')
box(axes3,'on');
title(inputname(3))

end

