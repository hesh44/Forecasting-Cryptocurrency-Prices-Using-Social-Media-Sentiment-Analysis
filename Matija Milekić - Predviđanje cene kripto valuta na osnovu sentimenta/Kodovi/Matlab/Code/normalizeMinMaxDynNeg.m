function [ normInputVector ] = normalizeMinMaxDynNeg( inputVector, normalizationWindow )
%NORMALIZEMINMAXDYN normira ulazni vektor u odnosu na definisani vremenski prozor
%   Detailed explanation goes here

inputLength = length(inputVector);
normInputVector(1:inputLength,1) = NaN;

for itt = normalizationWindow : inputLength
    
    localMax = max(inputVector((itt-normalizationWindow+1):itt));
    localMin = min(inputVector((itt-normalizationWindow+1):itt));
    
    if inputVector(itt,1) < 0
        if localMin < 0
            normInputVector(itt,1) = inputVector(itt,1)/ abs(localMin);
        else
            normInputVector(itt,1) = -1;
        end
    else
        if localMax >= 0
            normInputVector(itt,1) = inputVector(itt,1)/ localMax;
        else
            normInputVector(itt,1) = 1;
        end
    end
    
end

end

