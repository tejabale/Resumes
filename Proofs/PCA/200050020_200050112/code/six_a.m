%To Run :six_a

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

figure(1);
subplot(2, 3, 1);
image(rescale(reshape(mu, 80, 80, 3))); 
title('mu', 'FontSize', 10);

subplot(2,3,2); 
image(rescale(reshape(V1, 80, 80, 3)));
title('Eigen-1', 'FontSize', 10);

subplot(2,3,3); 
image(rescale(reshape(V2, 80, 80, 3)));
title('Eigen-2', 'FontSize', 10);

subplot(2,3,4);
image(rescale(reshape(V3, 80, 80, 3)));
title('Eigen-3', 'FontSize', 10);

subplot(2,3,5); 
image(rescale(reshape(V4, 80, 80, 3)));
title('Eigen-4', 'FontSize', 10);

figure(2);
plot(lambda);
xlabel('Index(1-10)');
ylabel('Eigen Values');
title('Top 10 Eigen Values');