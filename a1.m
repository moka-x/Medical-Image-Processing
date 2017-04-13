%fixed=imread('..\example\head3.jpg');
%moving=imread('..\example\head4.jpg');
fixed = dicomread('knee1.dcm');      % ���ο�ͼ��fixed
moving = dicomread('knee2.dcm'); %  ������ͼ��moving
figure, imshowpair(moving, fixed, 'falsecolor'); %method:��falsecolor��α��ɫ��blend�����͸���������͡�diff���ҶȲ��� ��montage����̫��ƴ��%
title('Unregistered-falsecolor');
%figure, imshowpair(moving, fixed, 'blend'); %method:��falsecolor��α��ɫ��blend�����͸���������͡�diff���ҶȲ��� ��montage����̫��ƴ��%
%title('Unregistered-blend');
%figure, imshowpair(moving, fixed, 'montage'); %method:��falsecolor��α��ɫ��blend�����͸���������͡�diff���ҶȲ��� ��montage����̫��ƴ��%
%title('Unregistered-montage');
%figure, imshowpair(moving, fixed, 'diff'); %method:��falsecolor��α��ɫ��blend�����͸���������͡�diff���ҶȲ��� ��montage����̫��ƴ��%
%title('Unregistered-diff');
%���صĲ���optimizer�������Ż�����׼����Ż��㷨��������registration.optimizer.RegularStepGradientDescent ���� registration.optimizer.OnePlusOneEvolutionary���ֿɹ�ѡ��
%�������metric����ע���˶�������ͼƬ���ƶȵķ������ṩ�˾�����registration.metric.MeanSquares���ͻ���Ϣ��registration.metric.MattesMutualInformation�����ֹ�ѡ��%
[optimizer, metric] = imregconfig('monomodal');%����modalityָ��fixed, moving image��ϵ����monomodal��, 'multimodal'���֣��ֱ���������ͼ���ǵ�һģ̬���Ƕ�ģ̬��
%'MovingImage' ��ֵ��Ч�� All dimensions of the moving image should be greater than 4.
movingRegisteredDefault = imregister(moving, fixed, 'affine', optimizer, metric);
figure, imshowpair(movingRegisteredDefault, fixed);
title('A: Default registration'); %A ������׼��δ��׼Ч����% 
%�鿴Ĭ�����ɵ��Ż����Ͷ���������������߾��ȵ�;��ͨ���޸�����������%
disp('optimizer');
disp('metric');
%�ı��Ż����Ĳ���%
optimizer.MinimumStepLength = optimizer.MinimumStepLength/3.5;
movingRegisteredAdjustedInitialRadius = imregister(moving, fixed, 'affine', optimizer, metric);
figure, imshowpair(movingRegisteredAdjustedInitialRadius, fixed);
title('Adjusted InitialRadius');%��A �仯����%
%�ı�����������%
optimizer.MaximumIterations = 300;
movingRegisteredAdjustedInitialRadius300 = imregister(moving, fixed, 'affine', optimizer, metric);
figure, imshowpair(movingRegisteredAdjustedInitialRadius300, fixed);
%��Adjusted ��������һЩ
title('B: Adjusted InitialRadius, MaximumIterations = 300, Adjusted InitialRadius.');
%��similarity�ı任��ʽ����ʼ��׼��'rigid'��'translation','affine'%
tformSimilarity1 = imregtform(moving,fixed,'similarity',optimizer,metric);
Rfixed = imref2d(size(fixed));%imregtform�ѱ仯�����������imref2d���Ʊ任���ͼ����ο�ͼ������ͬ������ֲ�
movingRegisteredRigid = imwarp(moving,tformSimilarity1,'OutputView',Rfixed);
figure, imshowpair(movingRegisteredRigid, fixed);
%��B�������и��ƣ���δ��׼ǰ���Ϻ�
title('C1: Registration based on similarity transformation model.');
%�õ���tformsimilarity.T���Ǵ�˵�еı任������
tformSimilarity1.T;
%��rigid�ı任��ʽ����ʼ��׼��'rigid'��'translation','affine'%
tformSimilarity2 = imregtform(moving,fixed,'rigid',optimizer,metric);
Rfixed = imref2d(size(fixed));%imregtform�ѱ仯�����������imref2d���Ʊ任���ͼ����ο�ͼ������ͬ������ֲ�
movingRegisteredRigid = imwarp(moving,tformSimilarity2,'OutputView',Rfixed);
figure, imshowpair(movingRegisteredRigid, fixed);
%C2>C1����׼
title('C2: Registration based on rigid transformation model.');
tformSimilarity2.T;
%��translation�ı任��ʽ����ʼ��׼��'rigid'��'translation','affine'%
tformSimilarity3 = imregtform(moving,fixed,'translation',optimizer,metric);
Rfixed = imref2d(size(fixed));%imregtform�ѱ仯�����������imref2d���Ʊ任���ͼ����ο�ͼ������ͬ������ֲ�
movingRegisteredRigid = imwarp(moving,tformSimilarity3,'OutputView',Rfixed);
figure, imshowpair(movingRegisteredRigid, fixed);
%C2~>C1>C3
title('C3: Registration based on translation transformation model.');
tformSimilarity3.T;
%��affine�ı任��ʽ����ʼ��׼��'rigid'��'translation','affine'%
tformSimilarity4 = imregtform(moving,fixed,'affine',optimizer,metric);
Rfixed = imref2d(size(fixed));%imregtform�ѱ仯�����������imref2d���Ʊ任���ͼ����ο�ͼ������ͬ������ֲ�
movingRegisteredRigid = imwarp(moving,tformSimilarity4,'OutputView',Rfixed);
figure, imshowpair(movingRegisteredRigid, fixed);
%����˺ܶ�,C2~>C1>C3>>C4
title('C4: Registration based on affine transformation model.');
tformSimilarity4.T;

%similarity����׼:similarity
movingRegisteredSWithIC = imregister(moving,fixed,'similarity',optimizer,metric,...
    'InitialTransformation',tformSimilarity1);
figure, imshowpair(movingRegisteredSWithIC,fixed);
%D1-1~=C1
title('D1-1: Registration from similarity model based on similarity initial condition.');
%similarity����׼:Rigid
movingRegisteredSWithIC = imregister(moving,fixed,'similarity',optimizer,metric,...
    'InitialTransformation',tformSimilarity2);
figure, imshowpair(movingRegisteredSWithIC,fixed);
%C2>>D1-2
title('D1-2: Registration from similarity model based on Rigid initial condition.');
%similarity����׼:translation
movingRegisteredSWithIC = imregister(moving,fixed,'similarity',optimizer,metric,...
    'InitialTransformation',tformSimilarity3);
figure, imshowpair(movingRegisteredSWithIC,fixed);
%
title('D1-3: Registration from similarity model based on translation initial condition.');
%similarity����׼:affine
%(The isSimilarity method of the InitialTransformation must return true when TransformationType is 'similarity'.
%movingRegisteredSWithIC = imregister(moving,fixed,'similarity',optimizer,metric,...
%    'InitialTransformation',tformSimilarity4);
%figure, imshowpair(movingRegisteredSWithIC,fixed);
%
%title('D1-4: Registration from similarity model based on affine initial condition.');

%Rigid����׼:similarity
%The isRigid method of the InitialTransformation must return true when TransformationType is 'rigid'.
%    'InitialTransformation',tformSimilarity1);
%figure, imshowpair(movingRegisteredRigidWithIC,fixed);
%
%title('D2-1: Registration from Rigid model based on similarity initial condition.');
%Rigid����׼:Rigid
movingRegisteredRigidWithIC = imregister(moving,fixed,'Rigid',optimizer,metric,...
    'InitialTransformation',tformSimilarity2);
figure, imshowpair(movingRegisteredRigidWithIC,fixed);
%
title('D2-2: Registration from Rigid model based on Rigid initial condition.');
%Rigid����׼:translation
movingRegisteredRigidWithIC = imregister(moving,fixed,'Rigid',optimizer,metric,...
    'InitialTransformation',tformSimilarity3);
figure, imshowpair(movingRegisteredRigidWithIC,fixed);
%
title('D2-3: Registration from Rigid model based on translation initial condition.');
%Rigid����׼:affine
%The isRigid method of the InitialTransformation must return true when TransformationType is 'rigid'.
%movingRegisteredRigidWithIC = imregister(moving,fixed,'Rigid',optimizer,metric,...
%    'InitialTransformation',tformSimilarity4);
%figure, imshowpair(movingRegisteredRigidWithIC,fixed);
%
%title('D2-4: Registration from Rigid model based on affine initial condition.');

%translation����׼:similarity
%The isTranslation method of the InitialTransformation must return true when TransformationType is 'translation'.
%movingRegisteredTWithIC = imregister(moving,fixed,'translation',optimizer,metric,...
%   'InitialTransformation',tformSimilarity1);
%figure, imshowpair(movingRegisteredTWithIC,fixed);
%
%title('D3-1: Registration from translation model based on similarity initial condition.');
%translation����׼:Rigid
%The isTranslation method of the InitialTransformation must return true when TransformationType is 'translation'.
%movingRegisteredTWithIC = imregister(moving,fixed,'translation',optimizer,metric,...
%    'InitialTransformation',tformSimilarity2);
%figure, imshowpair(movingRegisteredTWithIC,fixed);
%
%title('D3-2: Registration from translation model based on Rigid initial condition.');
%translation����׼:translation
movingRegisteredTWithIC = imregister(moving,fixed,'translation',optimizer,metric,...
    'InitialTransformation',tformSimilarity3);
figure, imshowpair(movingRegisteredTWithIC,fixed);
%
title('D3-3: Registration from translation model based on translation initial condition.');
%translation����׼:affine
%The isTranslation method of the InitialTransformation must return true when TransformationType is 'translation'.
%movingRegisteredTWithIC = imregister(moving,fixed,'translation',optimizer,metric,...
%    'InitialTransformation',tformSimilarity4);
%figure, imshowpair(movingRegisteredTWithIC,fixed);
%
%title('D3-4: Registration from translation model based on affine initial condition.');

%affine����׼:similarity
movingRegisteredAffineWithIC = imregister(moving,fixed,'affine',optimizer,metric,...
    'InitialTransformation',tformSimilarity1);
figure, imshowpair(movingRegisteredAffineWithIC,fixed);
%D4-1>C2
title('D4-1: Registration from affine model based on similarity initial condition.');
%affine����׼:Rigid
movingRegisteredAffineWithIC = imregister(moving,fixed,'affine',optimizer,metric,...
    'InitialTransformation',tformSimilarity2);
figure, imshowpair(movingRegisteredAffineWithIC,fixed);
%����ˣ�D4-1>C2>>D4-2
title('D4-2: Registration from affine model based on Rigid initial condition.');
%affine����׼:translation
movingRegisteredAffineWithIC = imregister(moving,fixed,'affine',optimizer,metric,...
    'InitialTransformation',tformSimilarity3);
figure, imshowpair(movingRegisteredAffineWithIC,fixed);
%D4-1=D4-3>C2>>D4-2
title('D4-3: Registration from affine model based on translation initial condition.');
%affine����׼:affine
movingRegisteredAffineWithIC = imregister(moving,fixed,'affine',optimizer,metric,...
    'InitialTransformation',tformSimilarity4);
figure, imshowpair(movingRegisteredAffineWithIC,fixed);
%D4-1=D4-3>C2>>D4-4>D4-2
title('D4-4: Registration from affine model based on affine initial condition.');

