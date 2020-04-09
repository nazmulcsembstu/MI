clc
close all

path = 'C:\Users\yEaSiN aRaFaT\Desktop\mat_classify';

data1 = fullfile(path, 'gr_28');
data = imageDatastore(data1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

new_net = [
    imageInputLayer([28 28 1], 'Name','data')
	
    convolution2dLayer(3, 16, 'Stride',1, 'Padding','same', 'Name','conv1')
    batchNormalizationLayer('Name','norm1')
    reluLayer('Name','relu1')
    
    maxPooling2dLayer(2, 'Stride',2, 'Name','pool1')
	
    convolution2dLayer(3, 32, 'Stride',1, 'Padding','same', 'Name','conv2')
    batchNormalizationLayer('Name','norm2')
    reluLayer('Name','relu2')
    
    maxPooling2dLayer(2, 'Stride',2, 'Name','pool2')
    
    convolution2dLayer(3, 64, 'Stride',1, 'Padding','same', 'Name','conv3')
    batchNormalizationLayer('Name','norm3')
    reluLayer('Name','relu3')
    
    maxPooling2dLayer(2, 'Stride',2, 'Name','pool3')
    
    convolution2dLayer(3, 128, 'Stride',1, 'Padding','same', 'Name','conv4')
    batchNormalizationLayer('Name','norm4')
    reluLayer('Name','relu4')
    
    maxPooling2dLayer(2, 'Stride',2, 'Name','pool4')
    
    fullyConnectedLayer(128, 'Name','fc1');
    reluLayer('Name','relu5')
    dropoutLayer(0.5, 'Name','drop1')
	
    fullyConnectedLayer(2, 'Name','fc2')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','output')];


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


layer = 'fc1';
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
  
  