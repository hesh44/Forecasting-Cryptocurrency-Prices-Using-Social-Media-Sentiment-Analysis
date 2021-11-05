function [ zigzagIndex, zigzagValue ] = indicator_zigzag( inputVector, zigzagPercent, zigzagDays )
%ZIGZAG izracunava ZigZag indikator i iscrtava ga zajedno sa cenom
%   Detailed explanation goes here

inputLength = length(inputVector);

output = indicators(inputVector, 'zigzag', zigzagPercent);
zigzagIndex = output(:,1);
zigzagValue = output(:,2);

%% NOVI KOD
itt = 2;
while itt < length(zigzagIndex)
    if (zigzagIndex(itt) - zigzagIndex(itt-1)) < zigzagDays
        if zigzagValue(itt) > zigzagValue(itt-1)
            if zigzagValue(itt+1) >= zigzagValue(itt-1)
                zigzagIndex(itt:itt+1) = [];
                zigzagValue(itt:itt+1) = [];
            else
                zigzagIndex(itt-1:itt) = [];
                zigzagValue(itt-1:itt) = [];
            end
        else
            if zigzagValue(itt+1) <= zigzagValue(itt-1)
                zigzagIndex(itt:itt+1) = [];
                zigzagValue(itt:itt+1) = [];
            else
                zigzagIndex(itt-1:itt) = [];
                zigzagValue(itt-1:itt) = [];
            end
        end
    else
        itt = itt + 1;
    end
end

        

% %% PLOT
% t = 1:inputLength;
% inputStep = floor(inputLength/50);
% 
% figure1 = figure;
% axes1 = axes('Parent',figure1,...
%     'Position',[0.05 0.05 0.92 0.9]);
% plot(axes1, t, inputVector, 'r')
% hold on 
% plot(axes1, zigzagIndex, zigzagValue, 'b')
% hold off
% xlim(axes1,[0 inputLength]);
% set(axes1, 'XTick', 0:inputStep:inputLength)
% set(axes1, 'XGrid', 'on')
% box(axes1,'on');
% title(inputname(1))



end


