%To run : four_a

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
    mu(:, i) = mu(:,i)/freq(i);
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
eig_vec_sorted = zeros(28*28, 28*28, 10);

for i = 1 : 10
    [V, D] = eig(cov_digits(:, :, i));
    [D, order] = sort(diag(D),'descend');
    V = V(:, order);
    eig_vec_sorted(:, :, i) = V;
    lambda_sorted(:, i) = D;
end

%Maximun values of lambda for digits
lambda_max = zeros(10, 1);
%Principal eigen vector
eig_vec_princ = zeros(28*28, 10);

for i = 1 : 10
    lambda_max(i) = lambda_sorted(1, i);
    eig_vec_princ(:, i) = eig_vec_sorted(:, 1, i);
end

for i = 1 : 10
    figure;
    plot(lambda_sorted(:, i));
    xlabel('Index');
    ylabel('Eigen Value');
    title(sprintf('Digit %d', i-1))
end