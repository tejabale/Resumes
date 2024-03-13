%To Run : one_b

clear;
clc;
close all;
rng(1);

N=10^7;
u=rand(1,N);
v=rand(1,N);

for i=1:N
    if u(1,i)+v(1,i) > 1
        u(1,i)=1-u(1,i);
        v(1,i)=1-v(1,i);
    end
end
randompoint_x=pi*(u+(v/3));
randompoint_y=v*exp(1);
histogram2(randompoint_x,randompoint_y,'BinWidth',[0.01 0.01],'DisplayStyle','tile');
title('2D histogram of 10^7 random points distributed uniformly inside the triangle.')
xlabel('x')
ylabel('y')