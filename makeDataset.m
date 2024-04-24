function [train_data_with_label,test_data_with_label] = makeDataset(whole_data)
All_matrix = whole_data(:,1:end - 1);
% %数据归一化
% [All_matrix,~] = mapminmax(All_matrix');
% All_matrix = All_matrix';
% whole_data = [All_matrix,whole_data(:,end)]; % with label 
%随机选取训练集
rng('default') 
rng(8)
rand_index = randperm(length(whole_data));
ratio = 1;
num_train = round(ratio * length(whole_data));
train_index = rand_index(1:num_train);
test_index = rand_index(num_train + 1:end);
train_data_with_label = whole_data(train_index,:);
test_data_with_label = whole_data(test_index,:);









