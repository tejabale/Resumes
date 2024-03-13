I = double(imread('image_1.png'));
disp(I(40,40,:));
vector = reshape(I,19200,1);
vis = reshape(vector,80,80,3);
B = rescale(vis);
image(B);


