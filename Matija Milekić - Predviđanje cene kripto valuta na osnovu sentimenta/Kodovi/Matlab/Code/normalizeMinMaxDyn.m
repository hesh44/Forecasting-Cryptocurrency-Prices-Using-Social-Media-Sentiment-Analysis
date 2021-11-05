function [ normInputVector ] = normalizeMinMaxDyn( inputVector, normalizationWindow )
%NORMALIZEMINMAXDYN normira ulazni vektor u odnosu na definisani vremenski prozor
%   Detailed explanation goes here

inputLength = length(inputVector);
normInputVector(1:inputLength,1) = NaN;

for itt = normalizationWindow : inputLength
    localMax = max(inputVector((itt-normalizationWindow+1):itt));
    localMin = min(inputVector((itt-normalizationWindow+1):itt));
    normInputVector(itt,1) = (inputVector(itt,1) - localMin)/(localMax - localMin);
end

end

