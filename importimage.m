clear all;
close all;

% 读取载体图像
I = imread('000073604.jpg');
I = imresize(I,[540,960]);

% 转换为灰度图
YUV = rgb2ycbcr(I);
Y = YUV(:,:,1); U = YUV(:,:,2); V = YUV(:,:,3);


% 读取水印图像
W = imread('logo.tif');

% 转换为二值图
% level = graythresh(W);
% W = im2bw(W,level);

% 裁剪为长宽相等
W = imresize(W,[80,80]);

figure('Name','载体图像');
imshow(I);
title('载体图像');

figure('Name','水印图像');
imshow(W);
title('水印图像');
