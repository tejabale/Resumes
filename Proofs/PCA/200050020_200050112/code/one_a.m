%To Run : one_a

clear;
clc;
close all;
rng(1);

a = 0.5;
b = 1;
N = 10^7;
% Generate Random theta in the range [0,2*pi]
theta = 2* pi * rand(N,1);

r = sqrt(rand(N,1));
randompoint_x = a * r .* cos(theta);
randompoint_y = b * r .* sin(theta);

histogram2(randompoint_x,randompoint_y,'BinWidth',[0.01 0.01],'DisplayStyle','tile');
title('2D histogram of 10^7 random points distributed uniformly inside the Ellipse.')
xlabel('x')
ylabel('y')