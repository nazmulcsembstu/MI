clc
close all

path = 'C:\Users\yEaSiN aRaFaT\Desktop\mat_classify';

data1 = fullfile(path, 'fool');
data = imageDatastore(data1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

[train, test] = splitEachLabel(data, 0.75, 'randomized');

newAlex = [
    imageInputLayer([227 227 3], 'Name','data')
    
    convolution2dLayer(11, 96, 'Stride',4, 'Padding',0, 'Name','conv1')
    reluLayer('Name','relu1')
    maxPooling2dLayer(3, 'Stride',2, 'Padding',0, 'Name','pool1')
    
    convolution2dLayer(5, 256, 'Stride',1, 'Padding',2, 'Name','conv2')
    reluLayer('Name','relu2')
    maxPooling2dLayer(3, 'Stride',2, 'Padding',0,'Name','pool2')
    
    convolution2dLayer(3, 256, 'Stride',1, 'Padding',1, 'Name','conv5')
    reluLayer('Name','relu5')
    maxPooling2dLayer(3, 'Stride',2, 'Padding',0, 'Name','pool5')
    
    fullyConnectedLayer(4096, 'Name','fc6')
    reluLayer('Name','relu6')
    dropoutLayer(0.5, 'Name','drop6')
    
    fullyConnectedLayer(4096, 'Name','fc7')
    reluLayer('Name','relu7')
    dropoutLayer(0.5, 'Name','drop7')
    
    fullyConnectedLayer(2, 'Name','fc8','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','prob')
    classificationLayer('Name','output')];

opt = trainingOptions('sgdm', 'Maxepoch', 30, 'InitialLearnRate', 0.001);
training = trainNetwork(train, newAlex, opt);

[YPred, probs] = classify(training, train);
accuracy = mean(YPred == train.Labels);
accuracy = accuracy*100;

fprintf('Acuracy = %0.2f%%\n', accuracy);

num = numel(train.Labels);

TP=0;
TN=0;
FP=0;
FN=0;

for i = 1:num
    
    [I, info] = readimage(train, i);
    
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
  fprintf('Acuracy = %0.2f%%\n\n', res);
  fprintf('True Positive = %0.2f\n', TP);
  fprintf('True Negative = %0.2f\n', TN);
  fprintf('False Positive = %0.2f\n', FP);
  fprintf('False Negative = %0.2f\n', FN);

