clc
close all

path = 'C:\Users\yEaSiN aRaFaT\Desktop\mat_classify';

data = fullfile(path, 'data_3');
train = imageDatastore(data, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

count = train.countEachLabel;

net = alexnet;

layers = [imageInputLayer([227 227 3])
 net(2:end-3)
 fullyConnectedLayer(2)
 softmaxLayer
 classificationLayer()
];

opt = trainingOptions('sgdm', 'Maxepoch', 15 , 'InitialLearnRate', 0.0001);
training = trainNetwork(imdsTrain, layers, opt);

im = imread('ab01.jpg');

figure,imshow(im)
out = classify(training, im);

title(string(out))


