function [positive_data,reliable_neg,remain_data,w,b,F_value] = test_data_AVISVM(par,u,v)
load iris label;
load iris feature;
whole_dataset = [feature,label];
% [All_matrix,~] = mapminmax(feature');
% All_matrix = All_matrix';
% whole_dataset = [All_matrix,whole_dataset(:,end)];
[train_data_with_label_org, test_data_with_label] = makeDataset(whole_dataset);
gamma = 0.4;
[positive_data, ~, unlabeled_data, ~] = PU_data(train_data_with_label_org, gamma);
num_select = length(positive_data);
[reliable_neg,remain_data] = select_reliable_neg(positive_data, unlabeled_data,num_select,par);
[w, b] = AVI_SVM(positive_data, reliable_neg,remain_data,u,v);
test_data_with_label = train_data_with_label_org;
test_data_feature = test_data_with_label(:,1:end-1);
test_label_org = test_data_with_label(:,end);

label_test_pre = zeros(size(test_data_feature,1),1);
for i = 1: size(test_data_feature,1)
    if test_data_feature(i,:)*w - b > 0
        label_test_pre(i) = 1;
    else
        label_test_pre(i) = 0;
    end
end


TP_test = length(intersect(find(label_test_pre == 1),find(test_label_org == 1)));
TN_test =  length(intersect(find(label_test_pre == 0),find(test_label_org == 0)));
FN_test =  length(intersect(find(label_test_pre == 0),find(test_label_org == 1)));
FP_test =  length(intersect(find(label_test_pre == 1),find(test_label_org == 0)));

p_value = TP_test / (TP_test + FP_test);
r_value = TP_test / (TP_test + FN_test);
F_value = 2*(p_value * r_value) / (p_value + r_value);



    
