clc
close all

path = 'C:\Users\yEaSiN aRaFaT\Desktop\data_ecg';

data1 = fullfile(path, 'rgb_227');
data = imageDatastore(data1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

net=alexnet;

layersTransfer = net.Layers(1:end-3);

new_net = [
    layersTransfer
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];


opt = trainingOptions('sgdm', 'Maxepoch', 50, 'InitialLearnRate', 0.001);
training = trainNetwork(data, new_net, opt);

[YPred, probs] = classify(training, data);
accuracy = mean(YPred == data.Labels);
accuracy = accuracy*100;

fprintf('Acuracy of softmax = %0.2f%%\n\n', accuracy);

num = numel(data.Labels);

TP=0;
TN=0;
FP=0;
FN=0;

for i = 1:num
    
    [I, info] = readimage(data, i);
    
    str1 = string(info.Label);

    out = classify(training, I);
    str2 = string(out);
    
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
  fprintf('Acuracy of softmax = %0.2f%%\n\n', res);
  fprintf('True Positive = %0.2f%%\n', TP);
  fprintf('True Negative = %0.2f%%\n', TN);
  fprintf('False Positive = %0.2f%%\n', FP);
  fprintf('False Negative = %0.2f%%\n\n\n', FN);


layer = 'fc8';
feature_train = activations(training, data, layer, 'OutputAs','rows');
feature_test = activations(training, data, layer, 'OutputAs','rows');

classifier = fitcecoc(feature_train, data.Labels);

predic = predict(classifier, feature_test);

accuracy = mean(predic == data.Labels);
accuracy = accuracy*100;

fprintf('Acuracy of SVM = %0.2f%%\n\n', accuracy);

num = numel(data.Labels);

TP=0;
TN=0;
FP=0;
FN=0;

for i = 1:num
    
    [I, info] = readimage(data, i);
    
    str1 = string(info.Label);
    
    imageFeatures = activations(training, I, layer, 'OutputAs', 'rows');

    out = predict(classifier, imageFeatures);
    str2 = string(out);
    
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
  fprintf('Acuracy of SVM= %0.2f%%\n\n', res);
  fprintf('True Positive = %0.2f%%\n', TP);
  fprintf('True Negative = %0.2f%%\n', TN);
  fprintf('False Positive = %0.2f%%\n', FP);
  fprintf('False Negative = %0.2f%%\n', FN);
  
