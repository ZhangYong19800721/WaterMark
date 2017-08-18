function [Wg,nc] = getdwtwatermark(Iw,W,ntimes,rngseed,flag)
%% GETDWTWATERMARK 小波水印提取，本程序不需要使用原始载体和水印图像
%   Iw：带水印的图像
%   W: 原始水印，只是为了计算相关性
%   ntimes：密钥1，Arnold变换次数
%   rngseed：密钥2，随机数生成种子
%   flag：是否显示中间图像
%   Wg：提取出的水印
%   nc：相关系数
    
    [mW,nW] = size(W);
    
    % 由于Arnold置乱只能对方阵进行处理
    if mW ~= nW
        error('ARNOLD置乱要求水印图像的长宽必须相等！');
    end
    
    Iw = double(Iw);
    W = logical(W);
    
    %% 1 计算二级小波系数
    % 一级haar小波分解
    % 低频、水平、垂直、对角线
    ca1w = dwt2(Iw,'haar');
    % 二级haar小波分解
    ca2w = dwt2(ca1w,'haar');
    
    %% 2 从系数提取水印信息
    % 初始化水印矩阵
    Wa = W;
    % rngseed是密钥2，根据种子生成随机数
    rng(rngseed);
    idx = randperm(numel(ca2w),numel(Wa));
    % 逐个系数提取信息
    for i = 1:numel(Wa)
        c = ca2w(idx(i));
        z = mod(c,nW);
        if z<nW/2
            Wa(i)=0;
        else
            Wa(i)=1;
        end
    end
    
    %% 3 对信息进行反Arnold变换
    Wg = Wa;
    % ntimes 是密钥1，Arnold变换次数
    H = [2 -1; -1 1]^ntimes;
    for i = 1:nW
        for j = 1:nW
            idx = mod(H*[i-1;j-1],nW)+1;
            Wg(idx(1),idx(2)) = Wa(i,j);
        end
    end
    
    %% 4 提取和原始水印相关系数计算
    nc = sum(Wg(:).*W(:))/sqrt(sum(Wg(:).^2))/sqrt(sum(W(:).^2));
    
    % 绘图显示结果
    if flag
        figure('Name','数字水印提取结果')
        subplot(1,2,1)
        imshow(W);
        title('原始水印');
        subplot(1,2,2)
        imshow(Wg);
        title(['提取水印，NC = ',num2str(nc)]);
    end
end

