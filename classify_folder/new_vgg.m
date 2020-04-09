clc
close all

path = 'C:\Users\yEaSiN aRaFaT\Desktop\mat_classify';

data1 = fullfile(path, 'rgb_28');
data = imageDatastore(data1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

[train, test] = splitEachLabel(data, 0.25, 'randomized');

new_net = [
    imageInputLayer([28 28 3], 'Name','data')
	
    convolution2dLayer(3, 16, 'Stride',1, 'Padding',1, 'Name','conv1')
    batchNormalizationLayer('Name','norm1')
    reluLayer('Name','relu1')
	
    maxPooling2dLayer(2, 'Stride',2, 'Name','pool1')
	
    convolution2dLayer(3, 32, 'Stride',1, 'Padding',1, 'Name','conv2')
    batchNormalizationLayer('Name','norm2')
    reluLayer('Name','relu2')
	
    maxPooling2dLayer(2, 'Stride',2, 'Name','pool2')
	
    convolution2dLayer(3, 64, 'Stride',1, 'Padding',1, 'Name','conv3')
    batchNormalizationLayer('Name','norm3')
    reluLayer('Name','relu3')
    
    fullyConnectedLayer(512, 'Name','fc1');
    reluLayer('Name','relu5')
    dropoutLayer(0.5, 'Name','drop1')
	
    fullyConnectedLayer(2, 'Name','fc2')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','output')];


opt = trainingOptions('sgdm', 'Maxepoch', 30, 'InitialLearnRate', 0.001);
training = trainNetwork(train, new_net, opt);

[YPred, probs] = classify(training, data);
accuracy = mean(YPred == data.Labels);
accuracy = accuracy*100;

fprintf('Acuracy of softmax = %0.2f%%\n\n', accuracy);


% layer = 'fc1';
% feature_train = activations(training, data, layer, 'OutputAs','rows');
% feature_test = activations(training, data, layer, 'OutputAs','rows');
% 
% classifier = fitcecoc(feature_train, data.Labels);
% 
% predic = predict(classifier, feature_test);
% 
% accuracy = mean(predic == data.Labels);
% accuracy = accuracy*100;
% 
% fprintf('Acuracy of SVM = %0.2f%%\n\n', accuracy);

%layer = new_net(1:end-2);

%layer = 2;
%name = new_net.Layers(layer).Name

%layer = 'fc2';
%feature_train = activations(new_net, train, layer, 'OutputAs','rows');



% [YPred, probs] = classify(training, test);
% accuracy = mean(YPred == test.Labels);
% accuracy = accuracy*100;
% 
% fprintf('Acuracy = %0.2f%%\n\n', accuracy);

%{
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
  fprintf('Acuracy = %0.2f%%\n\n', res);
  fprintf('True Positive = %0.2f%%\n', TP);
  fprintf('True Negative = %0.2f%%\n', TN);
  fprintf('False Positive = %0.2f%%\n', FP);
  fprintf('False Negative = %0.2f%%\n', FN);
%}

%{
%layer = 'conv4';
%feature_train = activations(new_alex, data, layer, 'OutputAs','rows');

%feature_test = activations(met, data, layer, 'OutputAs','rows');
%classifier = fitcecoc(feature, data.Labels);

%predic = predict(classifier, feature_test);

%accuracy = mean(predic == data.Labels);
%}
    