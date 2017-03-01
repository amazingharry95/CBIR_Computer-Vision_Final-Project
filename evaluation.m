y = featureSelection();
filename = 'fitur.csv';
arr = csvread(filename);

afterFeatureSelection(300,10) = 0;
for x=1:9
    afterFeatureSelection(:,x) = arr(:,y(x));
end
afterFeatureSelection(:,10) = arr(:,17);
csvwrite('seleksiFitur.csv',afterFeatureSelection)