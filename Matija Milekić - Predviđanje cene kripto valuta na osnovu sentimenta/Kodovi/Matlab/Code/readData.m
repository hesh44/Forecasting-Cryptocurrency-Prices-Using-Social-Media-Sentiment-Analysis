function [ id, open, high, low, close, volume, mcap, dominance, comments, score, positiveSentiment, negativeSentiment ] ...
    = readData ( ticker, filePath, sheet, range )

% UCITAVANJE PODATAKA IZ FAJLA
[numPodaci, txtPodaci, allPodaci] = xlsread(filePath, sheet, range);

% datum = datenum(datum);
id = numPodaci(:,1);
open = numPodaci(:,2);
high = numPodaci(:,3);
low = numPodaci(:,4);
close = numPodaci(:,5);
volume = numPodaci(:,6);
mcap = numPodaci(:,7);
dominance = numPodaci(:,8);
comments = numPodaci(:,9);
score = numPodaci(:,10);
positiveSentiment = numPodaci(:,11);
negativeSentiment = numPodaci(:,12);

end
