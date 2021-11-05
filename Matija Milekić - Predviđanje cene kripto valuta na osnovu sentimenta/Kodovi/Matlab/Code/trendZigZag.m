function [ zigzagTrend ] = trendZigZag( priceVector, zigzagIndex, zigzagValue, plotResults )
%TRENDZIGZAG izvlaci smer trenda na osnovu ZigZag indikatora i iscrtava
%zajedno sa cenom i zigzag indikatorom
%   Detailed explanation goes here

priceLength = length(priceVector);
zigzagLength = length(zigzagIndex);
zigzagTrend(1:priceLength,1) = NaN;
for itt = 2 : zigzagLength
    startPeriod = zigzagIndex(itt-1,1)+1;
    endPeriod = zigzagIndex(itt,1);
    if zigzagValue(itt,1) > zigzagValue(itt-1,1)
        zigzagTrend(startPeriod:endPeriod,1) = 1;
    elseif zigzagValue(itt,1) < zigzagValue(itt-1,1)
        zigzagTrend(startPeriod:endPeriod, 1) = 0;
    elseif zigzagValue(itt,1) == zigzagValue(itt-1,1)
        zigzagTrend(startPeriod:endPeriod, 1) = 0.5;
    else
        disp('GRESKA| @trendZigZag !')
    end
end

if plotResults == 1
    trendLength = length(zigzagTrend);
    trendIndicator(1:trendLength,1) = NaN;
    for jtt = 2 : trendLength
        trendIndicator(jtt,1) = sum(2*zigzagTrend(2:jtt,1)-1);
    end
    
    priceStep = floor(priceLength/50);
    trendStep = floor(trendLength/50);
    
    figure1 = figure;
    
    axes1 = axes('Parent',figure1,...
        'Position',[0.03 0.37 0.96 0.58]);
    plot(axes1, priceVector, 'r')
    hold on
    plot(axes1, zigzagIndex, zigzagValue, 'b')
    hold off
    xlim(axes1,[0 priceLength]);
    set(axes1, 'XTick', 0:priceStep:priceLength)
    set(axes1, 'XGrid', 'on')
    box(axes1,'on');
    title(inputname(1))
    
    axes2 = axes('Parent', figure1,...
        'Position', [0.03 0.04 0.96 0.26]);
    plot(axes2, trendIndicator)
    xlim(axes2,[0 trendLength]);
    set(axes2, 'XTick', 0:trendStep:trendLength)
    set(axes2, 'XGrid', 'on')
    box(axes2,'on');
    title('Trend Indicator')
end

end

