clc
close all

path = 'C:\Users\yEaSiN aRaFaT\Desktop';

data1 = fullfile(path, 'over');
data = imageDatastore(data1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

k = 5;

partStores{k} = [];

for i = 1:k
   temp = partition(data, k, i);
   partStores{i} = temp.Files;
end

idx = crossvalind('Kfold', k, k);

% res_sf1 = 0;
% res_sf2 = 0;
% sn_sf = 0;
% sp_sf = 0;
% pp_sf = 0;
% 
% res_sv1 = 0;
% res_sv2 = 0;
% sn_sv = 0;
% sp_sv = 0;
% pp_sv = 0;

for i = 1:k
    test_idx = (idx == i);
    train_idx = ~test_idx;

    test = imageDatastore(partStores{test_idx}, 'IncludeSubfolders', true, 'LabelSource', 'foldernames')
    train = imageDatastore(cat(1, partStores{train_idx}), 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
    
%     new_net = [
%     imageInputLayer([28 28 1], 'Name','data')
% 	
%     convolution2dLayer(3, 16, 'Stride',1, 'Padding','same', 'Name','conv1')
%     batchNormalizationLayer('Name','norm1')
%     reluLayer('Name','relu1')
%     
%     maxPooling2dLayer(2, 'Stride',2, 'Name','pool1')
% 	
%     convolution2dLayer(3, 32, 'Stride',1, 'Padding','same', 'Name','conv2')
%     batchNormalizationLayer('Name','norm2')
%     reluLayer('Name','relu2')
%     
%     maxPooling2dLayer(2, 'Stride',2, 'Name','pool2')
%     
%     convolution2dLayer(3, 64, 'Stride',1, 'Padding','same', 'Name','conv3')
%     batchNormalizationLayer('Name','norm3')
%     reluLayer('Name','relu3')
%     
%     maxPooling2dLayer(2, 'Stride',2, 'Name','pool3')
%     
%     convolution2dLayer(3, 128, 'Stride',1, 'Padding','same', 'Name','conv4')
%     batchNormalizationLayer('Name','norm4')
%     reluLayer('Name','relu4')
%     
%     maxPooling2dLayer(2, 'Stride',2, 'Name','pool4')
%     
%     fullyConnectedLayer(128, 'Name','fc1');
%     reluLayer('Name','relu5')
%     dropoutLayer(0.5, 'Name','drop1')
% 	
%     fullyConnectedLayer(2, 'Name','fc2')
%     softmaxLayer('Name','softmax')
%     classificationLayer('Name','output')];
%     
% opt = trainingOptions('sgdm', 'Maxepoch', 50, 'InitialLearnRate', 0.001);
% training = trainNetwork(train, new_net, opt);
% 
% [YPred, probs] = classify(training, test);
% accuracy = mean(YPred == test.Labels);
% 
% fprintf('Acuracy of sofmax = %0.2f%%\n', accuracy*100);

%res_sf1 = res_sf1 + accuracy;

% num = numel(test.Labels);
% 
% TP=0;
% TN=0;
% FP=0;
% FN=0;
% 
% for j = 1:num
%     
%     [I, info] = readimage(test, j);
%     
%     str1 = string(info.Label);
% 
%     out = classify(training, I);
%     str2 = string(out);
%     
%     if str1 == "abnormal"
%         if str2 == "abnormal"
%             TP=TP+1;
%         else
%             FN=FN+1;
%         end
%         
%     else 
%         if str2 == "normal"
%             TN=TN+1;
%         else
%             FP=FP+1;
%         end
%     end
%     
% end
% 
%   acc = ((TP+TN)/(TP+TN+FP+FN));
%   SN = TP/(TP+FN);
%   SP = TN/(TN+FP);
%   PP = TP/(TP+FP);
%   
%   res_sf2 = res_sf2 + acc;
%   sn_sf = sn_sf + SN;
%   sp_sf = sp_sf + SP;
%   pp_sf = pp_sf + PP;


% layer = 'fc1';
% feature_train = activations(training, train, layer, 'OutputAs','rows');
% feature_test = activations(training, test, layer, 'OutputAs','rows');
% 
% classifier = fitcecoc(feature_train, train.Labels);
% 
% predic = predict(classifier, feature_test);
% 
% accuracy = mean(predic == test.Labels);
% 
% fprintf('Acuracy of SVM = %0.2f%%\n', accuracy*100);

%res_sv1 = res_sv1 + accuracy;

% num = numel(test.Labels);
% 
% TP=0;
% TN=0;
% FP=0;
% FN=0;
% 
% for j = 1:num
%     
%     [I, info] = readimage(test, j);
%     
%     str1 = string(info.Label);
%     
%     imageFeatures = activations(training, I, layer, 'OutputAs', 'rows');
% 
%     out = predict(classifier, imageFeatures);
%     str2 = string(out);
%     
%     if str1 == "abnormal"
%         if str2 == "abnormal"
%             TP=TP+1;
%         else
%             FN=FN+1;
%         end
%         
%     else 
%         if str2 == "normal"
%             TN=TN+1;
%         else
%             FP=FP+1;
%         end
%     end
%     
% end
% 
%   acc = ((TP+TN)/(TP+TN+FP+FN));
%   SN = TP/(TP+FN);
%   SP = TN/(TN+FP);
%   PP = TP/(TP+FP);
%   
%   res_sv2 = res_sv2 + acc;
%   sn_sv = sn_sv + SN;
%   sp_sv = sp_sv + SP;
%   pp_sv = pp_sv + PP;
%   
end

%  fprintf('Acuracy of sofmax = %0.2f%%\n', (res_sf1/k)*100);
%  fprintf('Acuracy of sofmax = %0.2f%%\n', (res_sf2/k)*100);
%  fprintf('Sensitivity of sofmax = %0.2f%%\n', (sn_sf/k)*100);
%  fprintf('Specificity of sofmax = %0.2f%%\n', (sp_sf/k)*100);
%  fprintf('Preditivity of sofmax = %0.2f%%\n\n', (pp_sf/k)*100);
%  
%  fprintf('Acuracy of SVM = %0.2f%%\n', (res_sv1/k)*100);
%  fprintf('Acuracy of SVM = %0.2f%%\n', (res_sv2/k)*100);
%  fprintf('Sensitivity of SVM = %0.2f%%\n', (sn_sv/k)*100);
%  fprintf('Specificity of SVM = %0.2f%%\n', (sp_sv/k)*100);
%  fprintf('Preditivity of SVM = %0.2f%%\n', (pp_sv/k)*100);
 
