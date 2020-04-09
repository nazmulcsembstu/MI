clc
close all

path = 'C:\Users\yEaSiN aRaFaT\Desktop';

data1 = fullfile(path, 'gr_test');
data = imageDatastore(data1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

[train, test] = splitEachLabel(data, 0.90, 'randomized');

num = numel(test.Labels)

ab =0;
nor=0;

for i = 1:num
    
    [I, info] = readimage(test, i);
    
    info
    
     str1 = string(info.Label);
    
    if str1 == "abnormal"
        ab=ab+1;
    end
    
    if str1 == "normal"
        nor=nor+1;
    end
    
end

ab
nor

