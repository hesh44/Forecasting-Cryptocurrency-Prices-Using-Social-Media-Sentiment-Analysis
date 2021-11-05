clear;clc;

disp('=========================================')
disp('.........................................')
disp('............. POCETAK RADA ..............')
disp('.........................................')

%% BAZA FIRMI

dataList = {'data'};

%% PODESAVANJE PROGRAMA

folderPath = 'C:\Users\Korisnik\Documents\MATLAB\Diplomski Matija';

printAndPlotResults = 1;
plotTradingSignal = 0;

%% PODESAVANJA STRATEGIJE

initialAccountBalance = 1000000;
lotPrcnt = 0.5; % deo portfolia sa kojim trgujemo
spreadAbs = 0.00;

%% PARAMETRI ZA OPTIMIZACIJU

zigzagPercent = 25;
zigzagDays =3;
stopLossPrcnt = 0.075;
consecutiveLossesThreshold = 3;

initialTrainingSampleSize = 75; 


%% OPTIMIZACIJA
period = 5;
maperiod = 3;
tradingSignalThreshold = 0.65;


%% NEURALNA MREZA

for dataID = 1 : length(dataList)
    
    disp('=========================================')
    disp('.........................................')
    disp('......... UCITAVANJE PODATAKA ...........')
    disp('.........................................')
    
    dataSymbol = dataList{dataID};
    disp(['............ podaci = ' dataSymbol ' ............'])
    disp('.........................................')
    
    pathData = [ folderPath '\Data\' dataSymbol '.xlsx'];
    sheet = 1;
    range = 'B2:M1000';
    [id, open, high, low, close, volume, mcap, dominance, comments, score, positiveSentiment, negativeSentiment ] ...
        = readData (dataSymbol, pathData, sheet, range);
    
    %% ULAZI
    volume2mcap = volume./mcap;
    commentsPerPost = comments/30;
    scorePerPost = score/30;    
    sentimentScore = positiveSentiment-negativeSentiment;
    sentimentRatio = positiveSentiment./negativeSentiment;
    
    dominance_ema = indicators(dominance, 'ema', maperiod);
    volume2mcap_ema = indicators(volume2mcap, 'ema', maperiod);
    commentsPerPost_ema = indicators(commentsPerPost, 'ema', maperiod);    
    scorePerPost_ema = indicators(scorePerPost, 'ema', maperiod);
    sentimentScore_ema = indicators(sentimentScore, 'ema', maperiod);
    sentimentRatio_ema = indicators(sentimentRatio, 'ema', maperiod);    
    
    % Stochastics - SSTO
    SSTO = indicators([high,low,close], 'ssto', period, maperiod);
    SSTOK = SSTO(:,1);
    SSTOK_ema = [NaN(period,1); indicators(SSTOK((period+1):end,:), 'ema', maperiod)];
    
    % Rate of Change - ROC
    ROC = indicators(close, 'roc', period);
    ROC_ema = [NaN(period,1); indicators(ROC((period+1):end,:), 'ema', maperiod)];
    
    % Relative Strength Index - RSI
    RSI = indicators(close, 'rsi', period);
    RSI_ema = [NaN(period,1); indicators(RSI((period+1):end,:), 'ema', maperiod)];
    
 %   inputData = [commentsPerPost, scorePerPost, sentimentScore, sentimentRatio, volume2mcap];
 %   inputData = [commentsPerPost, scorePerPost, sentimentScore, sentimentRatio, volume2mcap, dominance];
%     inputData = [commentsPerPost, scorePerPost, sentimentScore, sentimentRatio, volume2mcap, dominance, SSTOK, ROC, RSI];   
%     inputData = [commentsPerPost_ema, scorePerPost_ema, sentimentScore_ema, sentimentRatio_ema, volume2mcap_ema];
%     inputData = [commentsPerPost_ema, scorePerPost_ema, sentimentScore_ema, sentimentRatio_ema, volume2mcap_ema, dominance_ema];
    inputData = [commentsPerPost_ema, scorePerPost_ema, sentimentScore_ema, sentimentRatio_ema, volume2mcap_ema, dominance_ema, SSTOK_ema, ROC_ema, RSI_ema];   
    
    %% IZLAZI
    [zigzagIndex, zigzagValue] = indicator_zigzag(close, zigzagPercent, zigzagDays);
    tradingSignal = extractTradingSignal(close, zigzagIndex, zigzagValue, 0);

    %% NEURALNA MREZA
    net = feedforwardnet(15);  % 1 hidden layer
    
%     net.layers{1}.transferFcn = 'tansig';
    net.layers{1}.transferFcn = 'logsig';
    
    %     net.trainFcn = 'trainlm'; % Levenberg-Marquardt backpropagation
    %     net.trainFcn = 'trainrp'; % Resilient backpropagation
    %     net.trainFcn = 'trainbfg'; % BFGS quasi Newton backpropagation
    %     net.trainFcn = 'traingda'; % gradient descent adaptive backpropagation
    %     net.trainFcn = 'traingdm'; % gradient descent momentum backpropagation
    %     net.trainFcn = 'traingdx'; % gradient descent momentum adaptive backpropagation
    %
    %     view(network);
    
    
    %% STRATEGIJA
    
    % Vrednosti varijabli pre pocetka trgovanja
    currentTradingSignal(1:initialTrainingSampleSize,1) = 0;
    positionOpened(1:initialTrainingSampleSize,1) = 0;
    positionBalance(1:initialTrainingSampleSize,1) = 0;
    stopLossLevel(1:initialTrainingSampleSize,1) = NaN;
    balanceQuoteCur(1:initialTrainingSampleSize,1) = initialAccountBalance;
    balanceBaseCur(1:initialTrainingSampleSize,1) = 0;
    accountBalance(1:initialTrainingSampleSize,1) = initialAccountBalance;
    PL(1:initialTrainingSampleSize,1) = 0;
    ROI(1:initialTrainingSampleSize,1) = 0;
    maxAccountBalance(1:initialTrainingSampleSize,1) = initialAccountBalance;
    drawdown(1:initialTrainingSampleSize,1) = 0;
    
    longTradesCounter(1:initialTrainingSampleSize,1) = 0;
    shortTradesCounter(1:initialTrainingSampleSize,1) = 0;
    longTradeGains(1:initialTrainingSampleSize,1) = 0;
    longTradeLosses(1:initialTrainingSampleSize,1) = 0;
    shortTradeGains(1:initialTrainingSampleSize,1) = 0;
    shortTradeLosses(1:initialTrainingSampleSize,1) = 0;
    longTradesWon(1:initialTrainingSampleSize,1) = 0;
    longTradesLost(1:initialTrainingSampleSize,1) = 0;
    shortTradesWon(1:initialTrainingSampleSize,1) = 0;
    shortTradesLost(1:initialTrainingSampleSize,1) = 0;
    consecutiveLosses(1:initialTrainingSampleSize,1) = 0;
    
    strategyReport = [];
    
    [nmbRowsPrice nmbColumnsPrice] = size(close);
    [zigzagIndex, zigzagValue] = indicator_zigzag(close(1:initialTrainingSampleSize), zigzagPercent, zigzagDays);
    firstZigzagIndex = zigzagIndex(1,1);
    lastZigzagIndex = zigzagIndex(end,1);
    
    % Prvo treniranje mreze
    %     plotTradingSignal = 1;
    tradingSignal = extractTradingSignal(close(1:initialTrainingSampleSize), zigzagIndex, zigzagValue, plotTradingSignal);
    trainInputs = inputData(firstZigzagIndex:lastZigzagIndex,:)';
    trainTargets = tradingSignal(firstZigzagIndex:lastZigzagIndex)';
    [trainedNet, trainRecord] = train(net, trainInputs, trainTargets);
    
    
    %% Izvrsavanje strategije
    for row = initialTrainingSampleSize+1 : nmbRowsPrice
        
        
        
        %% Uslov za treniranje neuronske mreze
        if consecutiveLosses(row-1,1) >= consecutiveLossesThreshold
            
            [zigzagIndex, zigzagValue] = indicator_zigzag(close(1:row), zigzagPercent, zigzagDays);
            lastZigzagIndex = zigzagIndex(end,1);
            
            % Ekstrakcija targeta (trejding signal)
            tradingSignal = extractTradingSignal(close(1:row), zigzagIndex, zigzagValue, plotTradingSignal);
            
            % Priprema podataka za treniranje
            trainInputs = inputData(firstZigzagIndex:lastZigzagIndex,:)';
            trainTargets = tradingSignal(firstZigzagIndex:lastZigzagIndex)';
            
            % Treniranje mreze
            [trainedNet, trainRecord] = train(net, trainInputs, trainTargets); % MOGUCE POBOLJSANJE, MREZA SE SNIMA I PRENOSI PA SE NE TRENIRA ISPOCETKA
        end
        
        %% Predvidjanje signala
        simInput = inputData(row,:)';
        currentTradingSignal(row,1)  = sim(trainedNet, simInput); % u drugom koraku moze da se predvidja na osnovu high i low cena
        
        
        %% Trgovanje
        
        % Ukoliko smo dosli do kraja vremenske serije
        if positionOpened(row-1,1) == 0 % Ukoliko nije otvorena bilo kakva pozicija
            if row == nmbRowsPrice % ako smo dosli do kraja vremenske serije
                balanceQuoteCur(row,1) = balanceQuoteCur(row-1,1);
                balanceBaseCur(row,1) = balanceBaseCur(row-1,1);
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) + spreadAbs/2);
                stopLossLevel(row,1) = stopLossLevel(row-1,1);
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                positionOpened(row,1) = positionOpened(row-1,1);
                positionBalance(row,1) = positionBalance(row-1,1);
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                consecutiveLosses(row,1) = consecutiveLosses(row-1,1);
                
            elseif currentTradingSignal(row,1) >= tradingSignalThreshold % Uslov za kupovinu
                lotQuoteCur = lotPrcnt * balanceQuoteCur(row-1,1);
                positionPrice = open(row,1) + spreadAbs/2;
                balanceQuoteCur(row,1) = balanceQuoteCur(row-1,1) - lotQuoteCur;
                balanceBaseCur(row,1) = balanceBaseCur(row-1,1) + lotQuoteCur / positionPrice;
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) - spreadAbs/2);
                stopLossLevel(row,1) = open(row,1) * (1 - stopLossPrcnt);
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                positionOpened(row,1) = positionOpened(row-1,1) + lotPrcnt;
                positionBalance(row,1) = positionBalance(row-1,1) + lotQuoteCur;
                longTradesCounter(row,1) = longTradesCounter(row-1,1) + 1;
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                consecutiveLosses(row,1) = consecutiveLosses(row-1,1);
                
            elseif currentTradingSignal(row,1) <= (1-tradingSignalThreshold) % Uslov za prodaju
                lotQuoteCur = lotPrcnt * (balanceQuoteCur(row-1,1) - 2*positionBalance(row-1,1));
                positionPrice = open(row,1) - spreadAbs/2;
                balanceQuoteCur(row,1) =  balanceQuoteCur(row-1,1) + lotQuoteCur;
                balanceBaseCur(row,1) = balanceBaseCur(row-1,1) - lotQuoteCur / positionPrice;
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) + spreadAbs/2);
                stopLossLevel(row,1) = open(row,1) * (1 + stopLossPrcnt);
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                positionOpened(row,1) = positionOpened(row-1,1) - lotPrcnt;
                positionBalance(row,1) = positionBalance(row-1,1) + lotQuoteCur;
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1) + 1;
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                consecutiveLosses(row,1) = consecutiveLosses(row-1,1);
                
            else % ako nema nikakvog signala
                balanceQuoteCur(row,1) =  balanceQuoteCur(row-1,1);
                balanceBaseCur(row,1) = balanceBaseCur(row-1,1);
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) + spreadAbs/2);
                stopLossLevel(row,1) = stopLossLevel(row-1,1);
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                positionOpened(row,1) = positionOpened(row-1,1);
                positionBalance(row,1) = positionBalance(row-1,1);
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                consecutiveLosses(row,1) = consecutiveLosses(row-1,1);
            end
            
        elseif positionOpened(row-1,1) < 0 % Ukoliko je bila otvorena kratka pozicija
            if (currentTradingSignal(row,1) >= tradingSignalThreshold) || (open(row,1) > stopLossLevel(row-1,1)) || (row == nmbRowsPrice) % uslov za kupovinu, zatvaramo kratku poziciju
                positionPrice = open(row,1) + spreadAbs/2;
                lotQuoteCur = abs(balanceBaseCur(row-1,1)) * positionPrice;
                balanceQuoteCur(row,1) =  balanceQuoteCur(row-1,1) - lotQuoteCur;
                balanceBaseCur(row,1) = 0;
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) - spreadAbs/2);
                stopLossLevel(row,1) = NaN;
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                transactionProfit = positionBalance(row-1,1) - lotQuoteCur;
                
                positionOpened(row,1) = 0;
                positionBalance(row,1) = 0;
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                if transactionProfit > 0
                    shortTradeGains(row,1) = shortTradeGains(row-1,1) + transactionProfit;
                    shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                    shortTradesWon(row,1) = shortTradesWon(row-1,1) + 1;
                    shortTradesLost(row,1) = shortTradesLost(row-1,1);
                    consecutiveLosses(row,1) = 0;
                else
                    shortTradeGains(row,1) = shortTradeGains(row-1,1);
                    shortTradeLosses(row,1) = shortTradeLosses(row-1,1) + transactionProfit;
                    shortTradesWon(row,1) = shortTradesWon(row-1,1);
                    shortTradesLost(row,1) = shortTradesLost(row-1,1) + 1;
                    consecutiveLosses(row,1) = consecutiveLosses(row-1,1) + 1;
                end
                
            elseif currentTradingSignal(row,1) <= (1-tradingSignalThreshold) % Uslov za prodaju
                positionPrice = open(row,1) - spreadAbs/2;
                lotQuoteCur = lotPrcnt * (balanceQuoteCur(row-1,1) - 2*positionBalance(row-1,1));
                balanceQuoteCur(row,1) =  balanceQuoteCur(row-1,1) + lotQuoteCur;
                balanceBaseCur(row,1) = balanceBaseCur(row-1,1) - lotQuoteCur / positionPrice;
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) + spreadAbs/2);
                stopLossLevel(row,1) = open(row,1) * (1 + stopLossPrcnt);
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                positionOpened(row,1) = positionOpened(row-1,1) - lotPrcnt;
                positionBalance(row,1) = positionBalance(row-1,1) + lotQuoteCur;
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                consecutiveLosses(row,1) = consecutiveLosses(row-1,1);
                
            else % ako nema nikakvog signala
                balanceQuoteCur(row,1) =  balanceQuoteCur(row-1,1);
                balanceBaseCur(row,1) = balanceBaseCur(row-1,1);
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) + spreadAbs/2);
                stopLossLevel(row,1) = stopLossLevel(row-1,1);
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                positionOpened(row,1) = positionOpened(row-1,1);
                positionBalance(row,1) = positionBalance(row-1,1);
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                consecutiveLosses(row,1) = consecutiveLosses(row-1,1);
            end
            
        elseif positionOpened(row-1,1) > 0 % Ukoliko je otvorena duga pozicija
            if (currentTradingSignal(row,1) <= (1-tradingSignalThreshold)) || (open(row,1) < stopLossLevel(row-1,1)) || (row == nmbRowsPrice) % Uslov za prodaju, zatvaramo dugu poziciju
                positionPrice = open(row,1) - spreadAbs/2;
                lotQuoteCur = abs(balanceBaseCur(row-1,1)) * positionPrice;
                balanceQuoteCur(row,1) =  balanceQuoteCur(row-1,1) + lotQuoteCur;
                balanceBaseCur(row,1) = 0;
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) - spreadAbs/2);
                stopLossLevel(row,1) = NaN;
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                transactionProfit = lotQuoteCur - positionBalance(row-1,1);
                
                positionOpened(row,1) = 0;
                positionBalance(row,1) = 0;
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                if transactionProfit > 0
                    longTradeGains(row,1) = longTradeGains(row-1,1) + transactionProfit;
                    longTradeLosses(row,1) = longTradeLosses(row-1,1);
                    longTradesWon(row,1) = longTradesWon(row-1,1) + 1;
                    longTradesLost(row,1) = longTradesLost(row-1,1);
                    consecutiveLosses(row,1) = 0;
                else
                    longTradeGains(row,1) = longTradeGains(row-1,1);
                    longTradeLosses(row,1) = longTradeLosses(row-1,1) + transactionProfit;
                    longTradesWon(row,1) = longTradesWon(row-1,1);
                    longTradesLost(row,1) = longTradesLost(row-1,1) + 1;
                    consecutiveLosses(row,1) = consecutiveLosses(row-1,1) + 1;
                end
                
            elseif currentTradingSignal(row,1) >= tradingSignalThreshold % Uslov za kupovinu
                positionPrice = open(row,1) + spreadAbs/2;
                lotQuoteCur = lotPrcnt * balanceQuoteCur(row-1,1);
                balanceQuoteCur(row,1) =  balanceQuoteCur(row-1,1) - lotQuoteCur;
                balanceBaseCur(row,1) = balanceBaseCur(row-1,1) + lotQuoteCur / positionPrice;
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) + spreadAbs/2);
                stopLossLevel(row,1) = open(row,1) * (1 - stopLossPrcnt);
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                positionOpened(row,1) = positionOpened(row-1,1) + lotPrcnt;
                positionBalance(row,1) = positionBalance(row-1,1) + lotQuoteCur;
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                consecutiveLosses(row,1) = consecutiveLosses(row-1,1);
                
            else % ako nema nikakvog signala
                balanceQuoteCur(row,1) =  balanceQuoteCur(row-1,1);
                balanceBaseCur(row,1) = balanceBaseCur(row-1,1);
                accountBalance(row,1) = balanceQuoteCur(row,1) + balanceBaseCur(row,1) * (close(row,1) + spreadAbs/2);
                stopLossLevel(row,1) = stopLossLevel(row-1,1);
                
                % Maksimalna vrednost racuna
                if accountBalance(row,1) > accountBalance(row-1,1)
                    maxAccountBalance(row,1) = accountBalance(row,1);
                else
                    maxAccountBalance(row,1) = maxAccountBalance(row-1,1);
                end
                
                % Mere uspesnosti
                PL(row,1) = accountBalance(row,1) - initialAccountBalance;
                ROI(row,1) = PL(row,1) / initialAccountBalance;
                drawdown(row,1) = min(0, accountBalance(row,1) - maxAccountBalance(row,1)) / maxAccountBalance(row,1);
                
                % Informacije o otvaranju pozicije i statistike transakcija
                positionOpened(row,1) = positionOpened(row-1,1);
                positionBalance(row,1) = positionBalance(row-1,1);
                longTradesCounter(row,1) = longTradesCounter(row-1,1);
                shortTradesCounter(row,1) = shortTradesCounter(row-1,1);
                longTradeGains(row,1) = longTradeGains(row-1,1);
                longTradeLosses(row,1) = longTradeLosses(row-1,1);
                shortTradeGains(row,1) = shortTradeGains(row-1,1);
                shortTradeLosses(row,1) = shortTradeLosses(row-1,1);
                longTradesWon(row,1) = longTradesWon(row-1,1);
                longTradesLost(row,1) = longTradesLost(row-1,1);
                shortTradesWon(row,1) = shortTradesWon(row-1,1);
                shortTradesLost(row,1) = shortTradesLost(row-1,1);
                consecutiveLosses(row,1) = consecutiveLosses(row-1,1);
            end
        end
    end
end


%% NASTAVAK

% m2xdate(dateVector)

strategyReport = [id open high low close currentTradingSignal ...
    positionOpened stopLossLevel positionBalance balanceQuoteCur balanceBaseCur accountBalance PL ROI drawdown ...
    longTradesCounter shortTradesCounter longTradeGains longTradeLosses shortTradeGains shortTradeLosses ...
    longTradesWon longTradesLost shortTradesWon shortTradesLost];

% SUMARNI REZULTATI
totalLongTrades = longTradesCounter(end,1);
totalShortTrades = shortTradesCounter(end,1);
totalTrades = totalLongTrades + totalShortTrades;
totalLongTradesWon = longTradesWon(end,1);
totalShortTradesWon = shortTradesWon(end,1);
sumLongTradeGains = longTradeGains(end,1);
sumLongTradeLosses = longTradeLosses(end,1);
sumShortTradeGains = shortTradeGains(end,1);
sumShortTradeLosses = shortTradeLosses(end,1);

if totalTrades > 0
    tradesWonPrcnt = ((totalLongTradesWon + totalShortTradesWon) / totalTrades) * 100;
    totalPL = PL(end,1);
    totalROI = ROI(end,1);
    totalProfitFactor = (sumLongTradeGains + sumShortTradeGains) / -(sumLongTradeLosses + sumShortTradeLosses);
    maxDrawdown = min(drawdown(:,1));
    avgProfitPerTrade = accountBalance(end,1) / totalTrades;
else
    tradesWonPrcnt = 0;
    totalPL = 0;
    totalROI = 0;
    totalProfitFactor = 0;
    maxDrawdown = 0;
    avgProfitPerTrade = 0;
end

if longTradesCounter(end,1) > 0 
    longTradesWonPrcnt = (totalLongTradesWon / totalLongTrades) * 100;
    avgProfitPerLongTrade = (sumLongTradeGains + sumLongTradeLosses) / totalLongTrades;
    profitFactorLong = sumLongTradeGains / -sumLongTradeLosses;
else
    longTradesWonPrcnt = 0;
    avgProfitPerLongTrade = 0;
    profitFactorLong = 0;
end

if shortTradesCounter(end,1) > 0 
    shortTradesWonPrcnt = (totalShortTradesWon / totalShortTrades) * 100;
    avgProfitPerShortTrade = (sumShortTradeGains + sumShortTradeLosses) / totalShortTrades;
    profitFactorShort = sumShortTradeGains / -sumShortTradeLosses;
else
    shortTradesWonPrcnt = 0;
    avgProfitPerShortTrade = 0;
    profitFactorShort = 0;
end

strategyResults = [totalTrades tradesWonPrcnt ...
    totalPL totalROI totalProfitFactor maxDrawdown avgProfitPerTrade...
    totalLongTrades longTradesWonPrcnt avgProfitPerLongTrade profitFactorLong...
    totalShortTrades shortTradesWonPrcnt avgProfitPerShortTrade profitFactorShort];


%% DISP RESULTS

disp(['Total trades = ' num2str(totalTrades)])
disp(['Total trades won = ' num2str(tradesWonPrcnt) ' %'])
disp(['PL = ' num2str(totalPL)])
disp(['ROI = ' num2str(totalROI)])
disp(['Profit factor = ' num2str(totalProfitFactor)])
disp(['Maximal drawdown = ' num2str(maxDrawdown)  ' %'])
disp(['Average profit per trade = ' num2str(avgProfitPerTrade)])
disp(['Long trades = ' num2str(totalLongTrades)])
disp(['Long trades won = ' num2str(longTradesWonPrcnt) ' %'])
disp(['Long trades average profit = ' num2str(avgProfitPerLongTrade)])
disp(['Long trades profit factor = ' num2str(profitFactorLong)])
disp(['Short trades = ' num2str(totalShortTrades)])
disp(['Short trades won = ' num2str(shortTradesWonPrcnt) ' %'])
disp(['Short trades average profit = ' num2str(avgProfitPerShortTrade)])
disp(['Short trades profit factor = ' num2str(profitFactorShort)])


%% PRINT RESULTS

printPath = [folderPath '\Results\strategyResults.xlsx'];
zaglavlje = {'TOTAL TRADES', 'TRADES WON', 'PL', 'ROI', 'PROFIT FACTOR', 'MAX DRAWDOWN', 'AVG PL PER TRADE', ...
    'LONG TRADES', 'LONG TRADES WON', 'LONG AVG PL', 'LONG PF', ...
    'SHORT TRADES', 'SHORT TRADES WON', 'SHORT AVG PL', 'SHORT PF',};
rangeLetter = number2range(length(zaglavlje));

if xlswrite(printPath, zaglavlje, 1, ['A1:' rangeLetter '1'])
else
    disp('GRESKA @strategy! | Upis zaglavlja rezultata neuspesan!')
end

if xlswrite(printPath, strategyResults, 1, ['A2:' rangeLetter '2'])
    disp('@strategy | Rezultati uspesno upisani u Excel..')
else
    disp('GRESKA @strategy! | Upis rezultata strategije neuspesan!')
end


%% PRINT & PLOT REPORT

if printAndPlotResults == 1    
    
    % Iscrtavanje grafika
    graph111(close, currentTradingSignal, accountBalance)    
    
    % Upis izvestaja u Excel
    printPath = [folderPath '\Results\strategyReport.xlsx'];
    zaglavlje = {'DATE', 'OPEN', 'HIGH', 'LOW', 'CLOSE', 'TRADING SIGNAL', ...
        'POSITION OPENED', 'STOPLOSS LVL', 'POSITION BALANCE', 'BALANCE QUOTE', 'BALANCE BASE', 'ACCOUNT BALANCE', 'PL', 'ROI', 'DRAWDOWN',...
        'LONG TRADES COUNTER', 'SHORT TRADE COUNTER', 'LONG TRADE GAINS', 'LONG TRADE LOSSES', 'SHORT TRADE GAINS', 'SHORT TRADE LOSSES',...
        'LONG TRADE WON', 'LONG TRADE LOST', 'SHORT TRADE WON', 'SHORT TRADE LOST'};
    rangeLetter = number2range(length(zaglavlje));
    
    if xlswrite(printPath, zaglavlje, 1, ['A1:' rangeLetter '1'])
    else
        disp('GRESKA @strategy! | Upis zaglavlja izvestaja neuspesan!')
    end
    
    if xlswrite(printPath, strategyReport, 1, ['A2:' rangeLetter num2str(2+length(strategyReport)-1)])
        disp('@strategy | Izvestaj uspesno upisan u Excel..')
    else
        disp('GRESKA @strategy! | Upis izvestaja strategije neuspesan!')
    end     
end

    