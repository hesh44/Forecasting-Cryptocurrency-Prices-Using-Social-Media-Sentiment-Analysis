function [ EMA ] = indicator_EWMA( inputVector, alpha )
%EWMA racuna Exponential Weighted Moving Average sa zadatim Alpha parametrom
%   Detailed explanation goes here

inputLength = length(inputVector);
EMA(1,1) = inputVector(1,1);

for itt = 2:inputLength
    EMA(itt,1) = alpha*inputVector(itt,1)+(1-alpha)*EMA(itt-1,1);
end

end

