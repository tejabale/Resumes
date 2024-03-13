%To Run : five

clear;
close all;
clc;
rng(1);

load ../data/mnist.mat;

%Numbers in labels_train
label = double(labels_train);

%Reshaped matrix
re_mat = reshape(double(digits_train),[28*28, 60000]);

%Frequency of each number in labels_test
freq = zeros(10);

mu = zeros(28*28, 10);

cov_digits = zeros(28*28, 28*28, 10);

%Adding all pixel values of a particular digit
for i = 1 : 60000   
    mu(:, label(i)+1) = mu(:, label(i)+1) + re_mat(:, i);
    freq(label(i)+1) = freq(label(i)+1)+1;
end
%Dividing with frequency to obtain mean(mu)
for i =  1 : 10
    mu(:, i) = mu(:, i)/freq(i);
end

%Matrices after shifting values by mu
mat_0 = zeros(28*28, freq(1));
mat_1 = zeros(28*28, freq(2));
mat_2 = zeros(28*28, freq(3));
mat_3 = zeros(28*28, freq(4));
mat_4 = zeros(28*28, freq(5));
mat_5 = zeros(28*28, freq(6));
mat_6 = zeros(28*28, freq(7));
mat_7 = zeros(28*28, freq(8));
mat_8 = zeros(28*28, freq(9));
mat_9 = zeros(28*28, freq(10));
freq = zeros(10);

for i = 1 : 60000
    freq(label(i)+1) = freq(label(i)+1)+1;
    if label(i) == 0
        mat_0(:, freq(1)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 1
        mat_1(:, freq(2)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 2
        mat_2(:, freq(3)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 3
        mat_3(:, freq(4)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 4
        mat_4(:, freq(5)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 5
        mat_5(:, freq(6)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 6
        mat_6(:, freq(7)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 7
        mat_7(:, freq(8)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 8
        mat_8(:, freq(9)) = re_mat(:, i) - mu(:, label(i)+1);
    elseif label(i) == 9
        mat_9(:, freq(10)) = re_mat(:, i) - mu(:, label(i)+1);
    end
end

%Covariance matrices for each digit.
cov_digits(:, :, 1) = mat_0*mat_0.'/(freq(1)-1);
cov_digits(:, :, 2) = mat_1*mat_1.'/(freq(2)-1);
cov_digits(:, :, 3) = mat_2*mat_2.'/(freq(3)-1);
cov_digits(:, :, 4) = mat_3*mat_3.'/(freq(4)-1);
cov_digits(:, :, 5) = mat_4*mat_4.'/(freq(5)-1);
cov_digits(:, :, 6) = mat_5*mat_5.'/(freq(6)-1);
cov_digits(:, :, 7) = mat_6*mat_6.'/(freq(7)-1);
cov_digits(:, :, 8) = mat_7*mat_7.'/(freq(8)-1);
cov_digits(:, :, 9) = mat_8*mat_8.'/(freq(9)-1);
cov_digits(:, :, 10) = mat_9*mat_9.'/(freq(10)-1);

%After sorting eigen values
lambda_sorted = zeros(28*28, 10);

%Corresponding eigen vectors
eig_vec_sorted = zeros(784, 784, 10);

for i = 1 : 10
    [V, D] = eig(cov_digits(:, :, i));
    [D, order] = sort(diag(D),'descend');
    V = V(:, order);
    eig_vec_sorted(:, :, i) = V;
    lambda_sorted(:, i) = D;
end

components = 84;
eig_subset = zeros(784, 84, 10);


for i = 1 : 10
    eig_subset(:, :, i) = eig_vec_sorted(:, 1:84, i);
end

mat_red_0 = eig_subset(:, :, 1)*((eig_subset(:, :, 1))')*(mat_0);
mat_red_1 = eig_subset(:, :, 2)*((eig_subset(:, :, 2))')*(mat_1);
mat_red_2 = eig_subset(:, :, 3)*((eig_subset(:, :, 3))')*(mat_2);
mat_red_3 = eig_subset(:, :, 4)*((eig_subset(:, :, 4))')*(mat_3);
mat_red_4 = eig_subset(:, :, 5)*((eig_subset(:, :, 5))')*(mat_4);
mat_red_5 = eig_subset(:, :, 6)*((eig_subset(:, :, 6))')*(mat_5);
mat_red_6 = eig_subset(:, :, 7)*((eig_subset(:, :, 7))')*(mat_6);
mat_red_7 = eig_subset(:, :, 8)*((eig_subset(:, :, 8))')*(mat_7);
mat_red_8 = eig_subset(:, :, 9)*((eig_subset(:, :, 9))')*(mat_8);
mat_red_9 = eig_subset(:, :, 10)*((eig_subset(:, :, 10))')*(mat_9);

figure(1);
subplot(1, 2, 1);
imagesc(reshape(mat_0(:, 1) + mu(:, 1), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_0(:, 1) + mu(:, 1), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(2);
subplot(1, 2, 1);
imagesc(reshape(mat_1(:, 1)+ mu(:, 2), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_1(:, 1)+ mu(:, 2), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(3);
subplot(1, 2, 1);
imagesc(reshape(mat_2(:, 1)+ mu(:, 3), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_2(:, 1)+ mu(:, 3), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(4);
subplot(1, 2, 1);
imagesc(reshape(mat_3(:, 1)+ mu(:, 4), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_3(:, 1)+ mu(:, 4), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(5);
subplot(1, 2, 1);
imagesc(reshape(mat_4(:, 1)+ mu(:, 5), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_4(:, 1)+ mu(:, 5), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(6);
subplot(1, 2, 1);
imagesc(reshape(mat_5(:, 1)+ mu(:, 6), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_5(:, 1)+ mu(:, 6), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(7);
subplot(1, 2, 1);
imagesc(reshape(mat_6(:, 1)+ mu(:, 7), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_6(:, 1)+ mu(:, 7), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(8);
subplot(1, 2, 1);
imagesc(reshape(mat_7(:, 1)+ mu(:, 8), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_7(:, 1)+ mu(:, 8), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(9);
subplot(1, 2, 1);
imagesc(reshape(mat_8(:, 1)+ mu(:, 9), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_8(:, 1)+ mu(:, 9), [28, 28]));title('Reconstructed', 'FontSize', 10);

figure(10);
subplot(1, 2, 1);
imagesc(reshape(mat_9(:, 1)+ mu(:, 10), [28, 28]));title('Original', 'FontSize', 10);
subplot(1, 2, 2);
imagesc(reshape(mat_red_9(:, 1)+ mu(:, 10), [28, 28]));title('Reconstructed', 'FontSize', 10);
