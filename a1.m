%fixed=imread('..\example\head3.jpg');
%moving=imread('..\example\head4.jpg');
fixed = dicomread('knee1.dcm');      % 读参考图像fixed
moving = dicomread('knee2.dcm'); %  读浮动图像moving
figure, imshowpair(moving, fixed, 'falsecolor'); %method:‘falsecolor’伪彩色‘blend’混合透明处理类型‘diff’灰度差异 ‘montage’蒙太奇拼接%
title('Unregistered-falsecolor');
%figure, imshowpair(moving, fixed, 'blend'); %method:‘falsecolor’伪彩色‘blend’混合透明处理类型‘diff’灰度差异 ‘montage’蒙太奇拼接%
%title('Unregistered-blend');
%figure, imshowpair(moving, fixed, 'montage'); %method:‘falsecolor’伪彩色‘blend’混合透明处理类型‘diff’灰度差异 ‘montage’蒙太奇拼接%
%title('Unregistered-montage');
%figure, imshowpair(moving, fixed, 'diff'); %method:‘falsecolor’伪彩色‘blend’混合透明处理类型‘diff’灰度差异 ‘montage’蒙太奇拼接%
%title('Unregistered-diff');
%返回的参数optimizer是用于优化度量准则的优化算法，这里有registration.optimizer.RegularStepGradientDescent 或者 registration.optimizer.OnePlusOneEvolutionary两种可供选择。
%输出参数metric则是注明了度量两幅图片相似度的方法，提供了均方误差（registration.metric.MeanSquares）和互信息（registration.metric.MattesMutualInformation）两种供选择。%
[optimizer, metric] = imregconfig('monomodal');%参数modality指定fixed, moving image关系，‘monomodal’, 'multimodal'两种，分别质量两幅图像是单一模态还是多模态，
%'MovingImage' 的值无效。 All dimensions of the moving image should be greater than 4.
movingRegisteredDefault = imregister(moving, fixed, 'affine', optimizer, metric);
figure, imshowpair(movingRegisteredDefault, fixed);
title('A: Default registration'); %A 初步配准比未配准效果差% 
%查看默认生成的优化器和度量函数参数，提高精度的途径通过修改这两个参数%
disp('optimizer');
disp('metric');
%改变优化器的步长%
optimizer.MinimumStepLength = optimizer.MinimumStepLength/3.5;
movingRegisteredAdjustedInitialRadius = imregister(moving, fixed, 'affine', optimizer, metric);
figure, imshowpair(movingRegisteredAdjustedInitialRadius, fixed);
title('Adjusted InitialRadius');%较A 变化不大%
%改变最大迭代次数%
optimizer.MaximumIterations = 300;
movingRegisteredAdjustedInitialRadius300 = imregister(moving, fixed, 'affine', optimizer, metric);
figure, imshowpair(movingRegisteredAdjustedInitialRadius300, fixed);
%较Adjusted 差异少了一些
title('B: Adjusted InitialRadius, MaximumIterations = 300, Adjusted InitialRadius.');
%用similarity的变换方式做初始配准，'rigid'，'translation','affine'%
tformSimilarity1 = imregtform(moving,fixed,'similarity',optimizer,metric);
Rfixed = imref2d(size(fixed));%imregtform把变化矩阵输出；用imref2d限制变换后的图像与参考图像有相同的坐标分布
movingRegisteredRigid = imwarp(moving,tformSimilarity1,'OutputView',Rfixed);
figure, imshowpair(movingRegisteredRigid, fixed);
%较B，明显有改善，类未配准前，较好
title('C1: Registration based on similarity transformation model.');
%得到的tformsimilarity.T就是传说中的变换矩阵了
tformSimilarity1.T;
%用rigid的变换方式做初始配准，'rigid'，'translation','affine'%
tformSimilarity2 = imregtform(moving,fixed,'rigid',optimizer,metric);
Rfixed = imref2d(size(fixed));%imregtform把变化矩阵输出；用imref2d限制变换后的图像与参考图像有相同的坐标分布
movingRegisteredRigid = imwarp(moving,tformSimilarity2,'OutputView',Rfixed);
figure, imshowpair(movingRegisteredRigid, fixed);
%C2>C1更精准
title('C2: Registration based on rigid transformation model.');
tformSimilarity2.T;
%用translation的变换方式做初始配准，'rigid'，'translation','affine'%
tformSimilarity3 = imregtform(moving,fixed,'translation',optimizer,metric);
Rfixed = imref2d(size(fixed));%imregtform把变化矩阵输出；用imref2d限制变换后的图像与参考图像有相同的坐标分布
movingRegisteredRigid = imwarp(moving,tformSimilarity3,'OutputView',Rfixed);
figure, imshowpair(movingRegisteredRigid, fixed);
%C2~>C1>C3
title('C3: Registration based on translation transformation model.');
tformSimilarity3.T;
%用affine的变换方式做初始配准，'rigid'，'translation','affine'%
tformSimilarity4 = imregtform(moving,fixed,'affine',optimizer,metric);
Rfixed = imref2d(size(fixed));%imregtform把变化矩阵输出；用imref2d限制变换后的图像与参考图像有相同的坐标分布
movingRegisteredRigid = imwarp(moving,tformSimilarity4,'OutputView',Rfixed);
figure, imshowpair(movingRegisteredRigid, fixed);
%变差了很多,C2~>C1>C3>>C4
title('C4: Registration based on affine transformation model.');
tformSimilarity4.T;

%similarity精配准:similarity
movingRegisteredSWithIC = imregister(moving,fixed,'similarity',optimizer,metric,...
    'InitialTransformation',tformSimilarity1);
figure, imshowpair(movingRegisteredSWithIC,fixed);
%D1-1~=C1
title('D1-1: Registration from similarity model based on similarity initial condition.');
%similarity精配准:Rigid
movingRegisteredSWithIC = imregister(moving,fixed,'similarity',optimizer,metric,...
    'InitialTransformation',tformSimilarity2);
figure, imshowpair(movingRegisteredSWithIC,fixed);
%C2>>D1-2
title('D1-2: Registration from similarity model based on Rigid initial condition.');
%similarity精配准:translation
movingRegisteredSWithIC = imregister(moving,fixed,'similarity',optimizer,metric,...
    'InitialTransformation',tformSimilarity3);
figure, imshowpair(movingRegisteredSWithIC,fixed);
%
title('D1-3: Registration from similarity model based on translation initial condition.');
%similarity精配准:affine
%(The isSimilarity method of the InitialTransformation must return true when TransformationType is 'similarity'.
%movingRegisteredSWithIC = imregister(moving,fixed,'similarity',optimizer,metric,...
%    'InitialTransformation',tformSimilarity4);
%figure, imshowpair(movingRegisteredSWithIC,fixed);
%
%title('D1-4: Registration from similarity model based on affine initial condition.');

%Rigid精配准:similarity
%The isRigid method of the InitialTransformation must return true when TransformationType is 'rigid'.
%    'InitialTransformation',tformSimilarity1);
%figure, imshowpair(movingRegisteredRigidWithIC,fixed);
%
%title('D2-1: Registration from Rigid model based on similarity initial condition.');
%Rigid精配准:Rigid
movingRegisteredRigidWithIC = imregister(moving,fixed,'Rigid',optimizer,metric,...
    'InitialTransformation',tformSimilarity2);
figure, imshowpair(movingRegisteredRigidWithIC,fixed);
%
title('D2-2: Registration from Rigid model based on Rigid initial condition.');
%Rigid精配准:translation
movingRegisteredRigidWithIC = imregister(moving,fixed,'Rigid',optimizer,metric,...
    'InitialTransformation',tformSimilarity3);
figure, imshowpair(movingRegisteredRigidWithIC,fixed);
%
title('D2-3: Registration from Rigid model based on translation initial condition.');
%Rigid精配准:affine
%The isRigid method of the InitialTransformation must return true when TransformationType is 'rigid'.
%movingRegisteredRigidWithIC = imregister(moving,fixed,'Rigid',optimizer,metric,...
%    'InitialTransformation',tformSimilarity4);
%figure, imshowpair(movingRegisteredRigidWithIC,fixed);
%
%title('D2-4: Registration from Rigid model based on affine initial condition.');

%translation精配准:similarity
%The isTranslation method of the InitialTransformation must return true when TransformationType is 'translation'.
%movingRegisteredTWithIC = imregister(moving,fixed,'translation',optimizer,metric,...
%   'InitialTransformation',tformSimilarity1);
%figure, imshowpair(movingRegisteredTWithIC,fixed);
%
%title('D3-1: Registration from translation model based on similarity initial condition.');
%translation精配准:Rigid
%The isTranslation method of the InitialTransformation must return true when TransformationType is 'translation'.
%movingRegisteredTWithIC = imregister(moving,fixed,'translation',optimizer,metric,...
%    'InitialTransformation',tformSimilarity2);
%figure, imshowpair(movingRegisteredTWithIC,fixed);
%
%title('D3-2: Registration from translation model based on Rigid initial condition.');
%translation精配准:translation
movingRegisteredTWithIC = imregister(moving,fixed,'translation',optimizer,metric,...
    'InitialTransformation',tformSimilarity3);
figure, imshowpair(movingRegisteredTWithIC,fixed);
%
title('D3-3: Registration from translation model based on translation initial condition.');
%translation精配准:affine
%The isTranslation method of the InitialTransformation must return true when TransformationType is 'translation'.
%movingRegisteredTWithIC = imregister(moving,fixed,'translation',optimizer,metric,...
%    'InitialTransformation',tformSimilarity4);
%figure, imshowpair(movingRegisteredTWithIC,fixed);
%
%title('D3-4: Registration from translation model based on affine initial condition.');

%affine精配准:similarity
movingRegisteredAffineWithIC = imregister(moving,fixed,'affine',optimizer,metric,...
    'InitialTransformation',tformSimilarity1);
figure, imshowpair(movingRegisteredAffineWithIC,fixed);
%D4-1>C2
title('D4-1: Registration from affine model based on similarity initial condition.');
%affine精配准:Rigid
movingRegisteredAffineWithIC = imregister(moving,fixed,'affine',optimizer,metric,...
    'InitialTransformation',tformSimilarity2);
figure, imshowpair(movingRegisteredAffineWithIC,fixed);
%变差了，D4-1>C2>>D4-2
title('D4-2: Registration from affine model based on Rigid initial condition.');
%affine精配准:translation
movingRegisteredAffineWithIC = imregister(moving,fixed,'affine',optimizer,metric,...
    'InitialTransformation',tformSimilarity3);
figure, imshowpair(movingRegisteredAffineWithIC,fixed);
%D4-1=D4-3>C2>>D4-2
title('D4-3: Registration from affine model based on translation initial condition.');
%affine精配准:affine
movingRegisteredAffineWithIC = imregister(moving,fixed,'affine',optimizer,metric,...
    'InitialTransformation',tformSimilarity4);
figure, imshowpair(movingRegisteredAffineWithIC,fixed);
%D4-1=D4-3>C2>>D4-4>D4-2
title('D4-4: Registration from affine model based on affine initial condition.');

