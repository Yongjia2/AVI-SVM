clear;
clc;
% label of positive is 1. negative is 0
addpath('AVISVM')
[solution,value,data] = Dycors('main_ecc_AVISVM');

par  = solution(1);
u = solution(2);
v =  solution(3);
[positive_data,reliable_neg,remain_data,w,b,F_value] = test_data_AVISVM(par,u,v);

%% ----------------------figure--------------------------

load iris
positive_org= feature(1:50,:);
negative_org= feature(51:100,:);

figure(1)
x1=(2.8:0.01:7.3);
y1=(b-w(1)*x1)/w(2);
y11=(1+b-w(1)*x1)/w(2);
y111=(-1+b-w(1)*x1)/w(2);
plot(x1,y1,'r',x1,y11,'--r',x1,y111,'--r')
hold on
x3=positive_data(:,1);
y3=positive_data(:,2);
h3 = scatter(x3,y3,80,'k');
hold on
x_neg1 = negative_org(:,1);
x_neg2 = negative_org(:,2);
h1 = scatter(x_neg1,x_neg2,'_b','LineWidth',1);
hold on
x2=reliable_neg(:,1);
y2=reliable_neg(:,2);
h4 = scatter(x2,y2,70,'dk');
hold on 
x3=positive_org(:,1);
y3=positive_org(:,2);
h2 = scatter(x3,y3,'+r','LineWidth',1);
hold on
set(gca,'XTick',3:1:7);
set(gca,'YTick',0:0.5:3.5);
axis([2.8 7.3 0 3.5])
legmark=100;
legend([h1(1),h2(1),h3(1),h4(1)],'unlabeled negative samples', 'unlabeled positive samples',... 
    'labeled positive samples', 'reliable negative samples')
grid off

%orginal figure
figure(2)
x_neg1 = negative_org(:,1);
x_neg2 = negative_org(:,2);
h1_1 = scatter(x_neg1,x_neg2,'_b','LineWidth',1);
hold on
x_pos1 = positive_org(:,1);
x_pos2 = positive_org(:,2);
h2_1 = scatter(x_pos1,x_pos2,'+r','LineWidth',1);
hold on
x3=positive_data(:,1);
y3=positive_data(:,2);
h3_1 = scatter(x3,y3,70,'k');
hold on 
set(gca,'XTick',3:1:7);
set(gca,'YTick',0:0.5:3.5);
axis([2.8 7.3 0 3.5])
legmark=1;
legend([h1_1,h2_1,h3_1],'unlabeled negative samples', 'unlabeled positive samples',... 
    'labeled positive samples')
grid off
box on


