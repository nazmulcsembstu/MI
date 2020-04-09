path = 'C:\Users\yEaSiN aRaFaT\Desktop\mat_classify';

data1 = fullfile(path, 'over');
data = imageDatastore(data1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

net = alexnet;

mm = net.Layers(1:end);

mm.Layers

%{
net.Layers(1);
imageSize = net.Layers(1).InputSize;
augmented_data= augmentedImageDatastore(imageSize, data);

lgraph = layerGraph(net);

lgraph = removeLayers(lgraph, {'ClassificationLayer_fc1000','fc1000_softmax','fc1000'});

numClasses = numel(categories(data.Labels));

newCNN = [
    imageInputLayer([227 227 3],'Name','data')
    
    convolution2dLayer(11,96,'Stride',4,'Padding',0,'Name','conv1')
    reluLayer('Name','relu1')
    crossChannelNormalizationLayer(5,'Name','norm1')
    maxPooling2dLayer(3,'Stride',2,'Padding',0,'Name','pool1')
    
    convolution2dLayer(5,256,'Stride',1,'Padding',2,'Name','conv2')
    reluLayer('Name','relu2')
    crossChannelNormalizationLayer(5,'Name','norm2')
    maxPooling2dLayer(3,'Stride',2,'Padding',0,'Name','pool2')
    
    %convolution2dLayer(3,384,'Stride',1,'Padding',1,'Name','conv3')
    %reluLayer('Name','relu3')
    
    %convolution2dLayer(3,384,'Stride',1,'Padding',1,'Name','conv4')
    %reluLayer('Name','relu4')
    
    %convolution2dLayer(3,256,'Stride',1,'Padding',1,'Name','conv5')
    %reluLayer('Name','relu5')
    %maxPooling2dLayer(3,'Stride',2,'Padding',0,'Name','pool5')
    
    fullyConnectedLayer(4096,'Name','fc6')
    reluLayer('Name','relu6')
    dropoutLayer(0.5,'Name','drop6')
    
    fullyConnectedLayer(4096,'Name','fc7')
    reluLayer('Name','relu7')
    dropoutLayer(0.5,'Name','drop7')
    
    fullyConnectedLayer(numClasses,'Name','fc8','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','prob')
    classificationLayer('Name','output')];
%}

%lgraph = addLayers(lgraph, newLayers);
%lgraph = connectLayers(lgraph,'avg_pool','fc');
%lgraph.Layers;


%layers(1:110) = freezeWeights(layers(1:110));

%opt = trainingOptions('sgdm', 'Maxepoch', 5 , 'InitialLearnRate', 0.001);
%training = trainNetwork(data, newCNN, opt);

%{
lgraph = connectLayers(lgraph,'avg_pool','fc');

layers = lgraph.Layers;
connections = lgraph.Connections;

%layers(1:110) = freezeWeights(layers(1:110));
lgraph = createLgraphUsingConnections(layers,connections);

opt = trainingOptions('sgdm', 'Maxepoch', 30 , 'InitialLearnRate', 0.001);
training = trainNetwork(augmented_data, lgraph, opt);

[YPred,probs] = classify(training, data);
accuracy = mean(YPred == data.Labels);
accuracy = accuracy*100;

fprintf('Acuracy = %0.2f%%\n', accuracy);
%}

%{
newAlex = [
    imageInputLayer([224 224 3],'Name','data')
    
    convolution2dLayer(3, 64, 'Stride',1, 'Padding',0, 'Name','conv1')
    reluLayer('Name','relu1')
    
    convolution2dLayer(3, 64, 'Stride',1, 'Padding',0, 'Name','conv2')
    reluLayer('Name','relu2')
    
    maxPooling2dLayer(2, 'Stride',2, 'Padding',0, 'Name','pool2')
   
    convolution2dLayer(3, 128, 'Stride',1, 'Padding',0, 'Name','conv3')
    reluLayer('Name','relu3')
    
    convolution2dLayer(3, 128, 'Stride',1, 'Padding',0, 'Name','conv4')
    reluLayer('Name','relu4')
    
    maxPooling2dLayer(2, 'Stride',2, 'Padding',0, 'Name','pool2')
    
    convolution2dLayer(3, 256, 'Stride',1, 'Padding',0, 'Name','conv5')
    reluLayer('Name','relu5') 
    
    convolution2dLayer(3, 256, 'Stride',1, 'Padding',0, 'Name','conv6')
    reluLayer('Name','relu6')
    
    maxPooling2dLayer(2,'Stride',2,'Padding',0,'Name','pool3')
    
    fullyConnectedLayer(2048, 'Name','fc1')
    reluLayer('Name','relu7')
    dropoutLayer(0.5, 'Name','drop1')
    
    fullyConnectedLayer(2048, 'Name','fc2')
    reluLayer('Name','relu8')
    dropoutLayer(0.5, 'Name','drop2')
    
    fullyConnectedLayer(2, 'Name','fc3','WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer('Name','prob')
    classificationLayer('Name','output')];
%}
%layersTransfer = newAlex.Layers(1:end-3);

%lgraph = layerGraph(net);

%lgraph.Layers(1);
%imageSize = lgraph.Layers(1).InputSize;
%augmented_data = augmentedImageDatastore(imageSize, data);

%opt = trainingOptions('sgdm', 'Maxepoch', 1 , 'InitialLearnRate', 0.001);
%training = trainNetwork(data, newAlex, opt);


