clc
close all

path = 'C:\Users\yEaSiN aRaFaT\Desktop\mat_classify';

data1 = fullfile(path, 'rgb_224');
data = imageDatastore(data1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

net = alexnet;

layer = 'fc8';
feature_train = activations(net, data, layer, 'OutputAs','rows');
feature_test = activations(net, data, layer, 'OutputAs','rows');

classifier = fitcecoc(feature_train, data.Labels);

predic = predict(classifier, feature_test);

accuracy = mean(predic == data.Labels);
accuracy = accuracy*100;

fprintf('Acuracy = %0.2f%%\n', accuracy);

num = numel(data.Labels);

TP=0;
TN=0;
FP=0;
FN=0;

for i = 1:num
    
    [I, info] = readimage(data, i);
    str1 = string(info.Label);
     
    str2 = string(predic(i));
    
    if str1 == "abnormal"
        if str2 == "abnormal"
            TP=TP+1;
        else
            FN=FN+1;
        end
        
    else 
        if str2 == "normal"
            TN=TN+1;
        else
            FP=FP+1;
        end
    end
  
end

  res = ((TP+TN)/(TP+TN+FP+FN))*100;
  
  fprintf('Acuracy = %0.2f%%\n\n', res);
  fprintf('True Positive = %0.2f\n', TP);
  fprintf('True Negative = %0.2f\n', TN);
  fprintf('False Positive = %0.2f\n', FP);
  fprintf('False Negative = %0.2f\n', FN);



