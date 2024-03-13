%To Run : two

clear;
clc;
close all;
rng(1);

err_mean= zeros(100,5);
err_cov= zeros(100,5);
for i= 1:5
    for j = 1:100
        mu = [1, 2]';
        m = 2;
        N=10^i;
        C = [1.6250, -1.9486; -1.9486, 3.8750];
        [V, l] = eig(C);
        tem = sqrt(l)*randn(2, N);
        X = [1;2] + (V*tem);
        ML_mu = [sum(X(1, :))/N; sum(X(2, :))/N];
        err_mean(j,i) = sqrt(((mu(1,1)-ML_mu(1,1))^2) + ((mu(2,1)-ML_mu(2,1))^2))/sqrt((mu(1,1)^2)+(mu(2,1)^2));
        
        %finding errors in covariance matrix%
        A = X-ML_mu; ML_cov = zeros(2,2);
        for k = 1:N
            ML_cov = ML_cov + A(:,k)*A(:,k)';
        end
        ML_cov = ML_cov./N;
        C1=C -ML_cov;
        err_cov(j,i) = sqrt(sum(sum(C1.^2)))/sqrt(sum(sum(C.^2)));
        
        if(j==1)
            %standerdising x and y
            % A is standerdise matrix of X 
            mean_xy=sum(A(1,:).*A(2,:))/N;
            var_x=sum(A(1,:).^2)/N;
            var_y=sum(A(2,:).^2)/N;
            cov_xy = mean_xy;
            %covariance matrix 
            cov = zeros(2,2);
            cov(1,1)=var_x;
            cov(1,2)=cov_xy;
            cov(2,2)=var_y;
            cov(2,1)=cov_xy;
            [V,D] = eig(cov);
            A =  V(:,1).*sqrt(D(1,1))+ ML_mu;
            B =  V(:,2).*sqrt(D(2,2)) + ML_mu;
            point1 = [A' ; ML_mu' ];
            point2 = [B' ; ML_mu' ];
            figure(i+2);
            scatter(X(1,:),X(2,:),'filled'); hold on
            line(point1(:,1),point1(:,2), 'color', 'r', 'LineWidth', 2) ; hold on
            line(point2(:,1),point2(:,2), 'color', 'r', 'LineWidth', 2) ; hold on
            title(append('for N=10^',num2str(i)));
            xlabel("X");
            ylabel("Y")
        end
    end
end
figure(1);
boxplot(err_mean, "Labels", [1,2,3,4,5])
grid on;
xlabel("Value of log N");
ylabel("Error")
title("boxplot of errors b/w the true mean and the ML estimate");
figure(2);
boxplot(err_cov, "Labels", [1,2,3,4,5])
grid on;
xlabel("Value of log N");
ylabel("Error")
title("boxplot of errors b/w the true Covariance and the ML estimate");