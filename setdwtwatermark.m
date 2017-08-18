function [Iw,psnr] = setdwtwatermark(I,W,ntimes,rngseed,flag)
%SETDWTWATERMARK 基于小波变换的数字水印嵌入
%  I: 载体图像，灰度图
%  W：水印图像，二值图，且长宽相等
%  ntimes: 密钥1，Arnold置乱次数
%  rngseed：密钥2，随机数种子
%  flag：是否显示图像，0不显示，1显示
%  Iw：添加了水印信息后的图像
%  psnr：峰值信噪比，越大说明水印质量越好
    
    % 数据类型
    type = class(I); 
    
    % 强制转换为double和logical
    I = double(I);
    W = logical(W);
    [mI,nI] = size(I);
    [mW,nW] = size(W);
    
    % 由于Arnold置乱只能对方阵进行处理
    if mW ~= nW
        error('ARNOLD置乱要求水印图像的长宽必须相等！');
    end
    
    %% 1对载体图像进行小波分解
    % 一级haar小波分解
    % 低频、水平、垂直、对角
    [ca1,ch1,cv1,cd1] = dwt2(I,'haar');
    % 二级haar小波分解
    [ca2,ch2,cv2,cd2] = dwt2(ca1,'haar');
    
    if flag
        figure('Name','载体小波分解');
        subplot(1,2,1);
        imagesc([wcodemat(ca1),wcodemat(ch1);wcodemat(cv1),wcodemat(cd1)]);
        title('一级小波分解');
        subplot(1,2,2);
        imagesc([wcodemat(ca2),wcodemat(ch2);wcodemat(cv2),wcodemat(cd2)]);
        title('二级小波分解');
    end
    
    %% 2对水印图像进行预处理
    Wa = W;
    % 对水印进行Arnold变换
    H = [1 1; 1 2]^ntimes; % ntimes是密钥1，Arnold变换次数
    % 反Arnold置乱变换
    % H = [2 -1; -1 1]^ntimes;
    for i = 1:nW
        for j = 1:nW
            idx = mod(H*[i-1;j-1],nW)+1;
            Wa(idx(1),idx(2)) = W(i,j);
        end
    end
    
    if flag
        figure('Name','水印置乱效果');
        subplot(1,2,1);
        imshow(W);
        title('原始水印');
        subplot(1,2,2);
        imshow(Wa);
        title(['置乱水印，变换次数 = ',num2str(ntimes)]);
    end
    
    %% 3 小波数字水印的嵌入
    % 初始化嵌入水印的ca2系数
    ca2w = ca2;
    % 从ca2中随机选择mW*nW个系数
    rng(rngseed); % rngseed是密钥2，随机数种子
    idx = randperm(numel(ca2),numel(Wa));
    % 将水印信息嵌入到ca2中
    for i = 1:numel(Wa)
        % 二级小波系数
        c = ca2(idx(i));
        z = mod(c,nW);
        % 添加水印信息
        if Wa(i) % 水印对应二进制位1
            if z<nW/4
                f = c - nW/4 - z;
            else
                f = c + nW*3/4 - z;
            end
        else % 水印对应二进制位0
            if z<nW*3/4
                f = c + nW/4 - z;
            else
                f = c + nW*5/4 - z;
            end
        end
        % 嵌入水印后的小波系数
        ca2w(idx(i)) = f;
    end
    
    %% 4 根据小波系数重构图像
    % haar小波逆变换重构图像
    ca1w = idwt2(ca2w,ch2,cv2,cd2,'haar');
    Iw = idwt2(ca1w,ch1,cv1,cd1,'haar');
    
    % 必要的时候调整Iw维度
    Iw = Iw(1:mI,1:nI);
    
    %% 5 计算水印图像峰值信噪比
    mn = numel(I);
    Imax = max(I(:));
    psnr = 10*log10(mn*Imax^2/sum((I(:)-Iw(:)).^2));
    
    %% 6 输出嵌入水印后的图像最后结果
    % 转换原始数据类型
    I = cast(I,type);
    Iw = cast(Iw,type);
    
    if flag
        figure('Name','嵌入水印的图像');
        subplot(1,2,1);
        imshow(I);
        title('原始图像');
        subplot(1,2,2);
        imshow(Iw);
        title(['添加水印，PSNR = ',num2str(psnr)]);
    end
end

