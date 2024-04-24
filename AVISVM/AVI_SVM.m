function [w, b] = AVI_SVM(positive_data_with_label, reliable_neg_with_label,remain_data,u,v)
positive_data = positive_data_with_label(:,1:end-1);
reliable_neg = reliable_neg_with_label(:,1:end-1);
remain_data = remain_data(:,1:end-1);
labeled_data = [positive_data;reliable_neg];
v1=ones(size(positive_data,1),1);
v2=-ones(size(reliable_neg,1),1);
v3=[v1',v2'];                          
matrix_label=diag(v3); %构造已标签点的标签矩阵
w0=1*ones(size(positive_data,2),1);
b0 = 0;
v0=1e-50; 
num_unlabeled=size(remain_data,1);     %无标签点个数
[num_labeled,num_feature]=size(matrix_label*labeled_data);
w=10*ones(size(positive_data,2),1);
k=0;
while norm(w-w0) > v0 %|| norm(b-b0)> v0
    w = w0;
    %b = b0;
    k = k+1; 
    Obj_function=[-sign(w);0;v*ones(num_unlabeled,1);u*ones(num_labeled,1)];
    AA = [remain_data,-ones(num_unlabeled,1),-eye(num_unlabeled),zeros(num_unlabeled,num_labeled);
        -remain_data,ones(num_unlabeled,1),-eye(num_unlabeled),zeros(num_unlabeled,num_labeled);
         zeros(num_unlabeled,num_feature + 1),-eye(num_unlabeled),zeros(num_unlabeled,num_labeled);
         -matrix_label*labeled_data,matrix_label*ones(num_labeled,1),zeros(num_labeled,num_unlabeled),-eye(num_labeled);
         zeros(num_labeled,num_feature + 1 + num_unlabeled),-eye(num_labeled)];
    BB = [ones(num_unlabeled,1);ones(num_unlabeled,1);zeros(num_unlabeled,1);-ones(num_labeled,1);zeros(num_labeled,1)];
    [x,~] = linprog(Obj_function,AA,BB);
    w0 = x(1:num_feature,:);
    b0 = x(num_feature + 1);
end
w = w0;
b = b0;



