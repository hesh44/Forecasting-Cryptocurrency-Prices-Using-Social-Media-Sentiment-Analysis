function [ tradingSignal ] = extractTradingSignal( price, zigzagIndex, zigzagValue, plotTradingSignal )
    
    
    %% CONVERSION TO TRADING SIGNAL
    [nmbRowsPrice nmbColumsPrice] = size(price);
    [nmbRowsZigZag nmbColumnsZigZag] = size(zigzagIndex);

    tradingSignal = NaN(nmbRowsPrice,1);
    tradingSignal(1,1) = 0;
    
    if price(zigzagIndex(1,1),1) > price(1,1)
        localMax = price(zigzagIndex(1,1),1);
        localMin = price(1,1);
        tradingSignal(1:zigzagIndex(1,1),1) = 1 - (price(1:zigzagIndex(1,1),1)-localMin)/(localMax-localMin);
        [rowIndex columnIndex] = find(tradingSignal<0);
        tradingSignal(rowIndex,1) = 0.05; % tradingSignal(red-1,1)
        [rowIndex columnIndex] = find(tradingSignal>1);
        tradingSignal(rowIndex,1) = 0.95;
    else
        localMax = price(1,1);
        localMin = price(zigzagIndex(1,1),1);
        tradingSignal(1:zigzagIndex(1,1),1) = 1-(price(1:zigzagIndex(1,1),1)-localMin)/(localMax-localMin);
        [rowIndex columnIndex] = find(tradingSignal<0);
        tradingSignal(rowIndex,1) = 0.025; 
        [rowIndex columnIndex] = find(tradingSignal>1);
        tradingSignal(rowIndex,1) = 0.975;
    end
    
    for itt = 2 : nmbRowsZigZag
        if price(zigzagIndex(itt,1),1) > price(zigzagIndex(itt-1,1),1)
            localMax = price(zigzagIndex(itt,1),1);
            localMin = price(zigzagIndex(itt-1,1),1);
            tradingSignal(zigzagIndex(itt-1,1):zigzagIndex(itt,1),1) = 1-(price(zigzagIndex(itt-1,1):zigzagIndex(itt,1),1)-localMin)/(localMax-localMin);
            [rowIndex columnIndex] = find(tradingSignal<0);
            tradingSignal(rowIndex,1) = 0.025;
            [rowIndex columnIndex] = find(tradingSignal>1);
            tradingSignal(rowIndex,1) = 0.975;
        else
            localMax = price(zigzagIndex(itt-1,1),1);
            localMin = price(zigzagIndex(itt,1),1);
            tradingSignal(zigzagIndex(itt-1,1):zigzagIndex(itt,1),1) = 1-(price(zigzagIndex(itt-1,1):zigzagIndex(itt,1),1)-localMin)/(localMax-localMin);
            [rowIndex columnIndex] = find(tradingSignal<0);
            tradingSignal(rowIndex,1) = 0.025;
            [rowIndex columnIndex] = find(tradingSignal>1);
            tradingSignal(rowIndex,1) = 0.975;
        end
    end
    
    
    %% ISCRTAVANJE SIGNALA   
    if plotTradingSignal == 1
        [nmbRowsTradingSignal nmbColumnsTradingSignal] = size(tradingSignal);
        priceStep = floor(nmbRowsPrice/50);
        tradingSignalStep = floor(nmbRowsTradingSignal/50);
        
        emaTradingSignal = indicator_EWMA(tradingSignal, 0.3333);

        figure1 = figure;
        
        axes1 = axes('Parent',figure1,...
            'Position',[0.03 0.37 0.96 0.58]);
        plot(axes1, price, 'r')
        hold on
        plot(axes1, zigzagIndex, zigzagValue, '--b', 'LineWidth', 2)
        hold off
        xlim(axes1,[0 nmbRowsPrice]);
        set(axes1, 'XTick', 0:priceStep:nmbRowsPrice)
        set(axes1, 'XGrid', 'on')
        box(axes1,'on');
        title('PRICE')
        
        axes2 = axes('Parent', figure1,...
            'Position', [0.03 0.04 0.96 0.26]);
        plot(axes2, tradingSignal, 'r')
        hold on
        plot(axes2, emaTradingSignal, '--b', 'LineWidth', 2)
        hold off
        xlim(axes2,[0 nmbRowsTradingSignal]);
        set(axes2, 'XTick', 0:tradingSignalStep:nmbRowsTradingSignal)
        set(axes2, 'XGrid', 'on')
        box(axes2,'on');
        title('TRADING SIGNAL')
        
    end
    
end

