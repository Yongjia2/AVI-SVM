function [train_data_with_label_org, test_data_with_label,train_data_with_label,positive_select_index] = get_data
load iris label;
load iris feature;
whole_dataset = [feature,label];
%πÈ“ªªØ
% [All_matrix,~] = mapminmax(feature');
% All_matrix = All_matrix';
% whole_dataset = [All_matrix,whole_dataset(:,end)];
[train_data_with_label_org, test_data_with_label] = makeDataset(whole_dataset);
gamma = 0.4;
[~, positive_select_index, ~,train_data_with_label] = PU_data(train_data_with_label_org, gamma);
save test_data test_data_with_label