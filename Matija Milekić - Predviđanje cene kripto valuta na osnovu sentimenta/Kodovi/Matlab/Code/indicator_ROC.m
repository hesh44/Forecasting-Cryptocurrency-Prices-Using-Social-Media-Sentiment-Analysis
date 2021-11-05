function [ ROCVector ] = indicator_ROC( inputVector, ROCLength )
%MOVSTD racuna pokretnu standardnu devijaciju
%   Detailed explanation goes here

inputLength = length(inputVector);
ROCVector(1:inputLength,1) = NaN;

for itt = ROCLength : inputLength
    ROCVector(itt,1) = ((inputVector(itt,1)-inputVector(itt-ROCLength+1,1))/inputVector(itt-ROCLength+1,1))*100;
end

end

