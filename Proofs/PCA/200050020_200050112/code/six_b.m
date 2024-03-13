%To Run : six_b

clear;
clc;
close all;
rng(10);

%IMage vector
img_vec = zeros(19200, 16);
%Transformed Image vector
X = zeros(19200, 16);
%Mean
mu = zeros(19200, 1);

for i = 1 : 16
    read = imread(append('../data/data_fruit/image_',int2str(i),'.png'));
    img_vec(:, i) = double(reshape(read, 19200, 1));
    mu = mu + img_vec(:, i);
end

mu = mu/16;

for i = 1 : 16
    X(:,i) = img_vec(:, i) - mu;
end

C = X*X.';

%Eigen Vectors and Values
[V, D]=eigs(C, 10);
lambda = diag(D);

%First four eigen vectors
V1 = V(:, 1);
V2 = V(:, 2);
V3 = V(:, 3);
V4 = V(:, 4);

u1 = dot(mu, V1);
u2 = dot(mu, V2);
u3 = dot(mu, V3);
u4 = dot(mu, V4);
close_img = zeros(19200, 16);

for i = 1 : 16
    tem=dot(img_vec(:,i),V1)*u1-dot(img_vec(:,i),V2)*u2-dot(img_vec(:,i),V3)*u3-dot(img_vec(:,i),V4)*u4;
    num = dot(img_vec(:, i), mu) - tem;
    den = dot(mu, mu) - u1^2 + u2^2 + u3^2 + u4^2;
    a1 = num/den;
    mu_com = a1;
    V1_com = dot(img_vec(:,i),V1)-(u1*a1);
    V2_com = dot(img_vec(:,i),V2)-(u2*a1);
    V3_com = dot(img_vec(:,i),V3)-(u3*a1);
    V4_com = dot(img_vec(:,i),V4)-(u4*a1);
    close_img(:, i) = mu_com*mu + V1_com*V1 + V2_com*V2 + V3_com*V3 + V4_com*V4;
end

for i = 1 : 16
    figure(i);
    img2 = rescale(reshape(close_img(:,i),80,80,3));
    img1 = rescale(reshape(img_vec(:,i),80,80,3));
    subplot(1,2,1); image(img1); title('Original');
    subplot(1,2,2); image(img2); title('Closest Representation');
end