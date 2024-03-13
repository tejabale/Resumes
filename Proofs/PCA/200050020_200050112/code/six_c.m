%To Run : six_c

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

U1 = V(:, 1 : 4);
D1 = D(1 : 4, 1 : 4);

%Generating a MVG as in 2nd question with mean mu and using first 4
%principal components.

figure(1);
for i = 1 : 3
    tem = sqrt(D1)*randn(4, 1);
    tem = U1*tem;
    final = mu + tem;
    img = rescale(reshape(final, 80, 80, 3));
    subplot(3, 2, i);
    image(img);
    title(sprintf('New Image %d',i));
end