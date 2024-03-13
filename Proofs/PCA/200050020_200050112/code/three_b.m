%To Run : three_b
clear;
clc;
close all;

B = importdata('../data/points2D_Set2.mat');
x = B.x;
y = B.y;

sum_x=0;
sum_y=0;
squres_sum_x=0;
squres_sum_y=0;
for i = 1:1000
    sum_x = sum_x+x(i,1);
    sum_y = sum_y+y(i,1);
    squres_sum_x = squres_sum_x+(x(i,1))^2;
    squres_sum_y = squres_sum_y+(y(i,1))^2;
end
mean_x=sum_x/1000;
mean_y=sum_y/1000;
%standerdising x and y
trans = zeros(1000,2);

for i = 1:1000
    trans(i,1)=(x(i,1)-mean_x);
    trans(i,2)=(y(i,1)-mean_y);
end
sum_xy=0;
squres_sum_x=0;
squres_sum_y=0;
for i = 1:1000
    sum_xy = sum_xy+trans(i,1)*trans(i,2);
    squres_sum_x = squres_sum_x+(trans(i,1))^2;
    squres_sum_y = squres_sum_y+(trans(i,2))^2;
end
mean_xy=sum_xy/1000;
var_x=(squres_sum_x/1000);
var_y=(squres_sum_y/1000);
cov_xy = mean_xy;

%covariance matrix 
cov = zeros(2,2);
cov(1,1)=var_x;
cov(1,2)=cov_xy;
cov(2,2)=var_y;
cov(2,1)=cov_xy;

[V,D] = eig(cov);
final = trans*V(:, 2);
final = final*V(:, 2)';
final = final + [mean_x,mean_y];

scatter(final(:,1),final(:,2),5,'filled'); hold on
scatter(x,y,10,'filled');
title('scatter plot of the points2D\_Set2')
xlabel('X')
ylabel('Y')
grid on;