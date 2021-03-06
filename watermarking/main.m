%% 


clc;
clear all;
close all;



%%%%%%%%%%%%%前景オブジェクト検出%%%%%%%%%%%%%%%%%%
videoSource=VideoReader('man3.avi');
detector = vision.ForegroundDetector(...
       'NumTrainingFrames', 100, 'MinimumBackgroundRatio',0.1,...
       'InitialVariance', 30*30);
blob = vision.BlobAnalysis(...
       'CentroidOutputPort', false, 'AreaOutputPort', false, ...
       'BoundingBoxOutputPort', true, ...
       'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 250);
shapeInserter = vision.ShapeInserter('BorderColor','White');   
videoPlayer = vision.VideoPlayer();

while hasFrame(videoSource)
     frame  = readFrame(videoSource);
     fgMask = detector(frame);
     bbox   = blob(fgMask);
     out    = shapeInserter(frame,bbox);
     %videoPlayer(out);
     pause(0.05);
end   

release(videoPlayer);
a='imagenation';
b='.csv';
ksum=0;
ssum=0;
qdct=0;
sum=0;
workingDir = tempname;
mkdir(workingDir)
mkdir(workingDir,'images')
vidObj=VideoReader('man3.avi');
vidObj.NumFrames
flag=0;
numframe=zeros(vidObj.NumFrames);
 numframe=MotionBasedMultiObjectTrackingExample();
 y=1;
 %%%%%%%%%%%%%%%%% 移動体のあるフレームを表示 %%%%%%%%%%%%%%%%
for i=1:numel(numframe)
    fprintf("flag:%d\n",numframe(i));
end
cou=0; 
t=1;
k=1;
misssum=0;%誤検出数
notsum=0;%検出不可数
tsum=0;%総改ざん数
tdsum=0;%総改ざん検出数
max=0;%画質のmax
min=1;%画質のmin
ii=1;%フレーム番号の変数
ps=zeros(1,300);%PSNRの変化
ss=zeros(1,300);%SSIMの変化
tampertime=zeros(1,300);%抽出したフレーム番号格納用


%動画を画像に変換
while hasFrame(vidObj)
    img=readFrame(vidObj);
    filename = [sprintf('%03d',ii) '.bmp'];
    fullname = fullfile(workingDir,'images',filename);
    imwrite(img,fullname);   
    ii = ii+1;
end

%画像検索
imageNames = dir(fullfile(workingDir,'images','*.bmp'));
imageNames = {imageNames.name}';

%動画ファイル作成
outputVideo = VideoWriter(fullfile(workingDir,'man_ver2.avi'),'Uncompressed AVI');
outputVideo.FrameRate = vidObj.FrameRate;

open(outputVideo)


for ii = 1:length(imageNames)
    
   img = imread(fullfile(workingDir,'images',imageNames{ii})); 
  
   %[X,cmap]=rgb2ind(RGB,Q);
   [m,n,k]=size(img);
   I=rgb2ycbcr(img);
   dI=I(:,:,1);
   %I=rgb2gray(img);
   
   wm=zeros(n);
 %double型に変換
   ddI= im2double(dI);

  %イメージリサイズ
   rI= imresize(ddI,[512 512]); 
  
%もし拡大MBを用いるならコメントとる   
 %  for i=1:300
   %  numframe(i)=0;
 %  end
  %移動体があるときとそうでないとき，ないときの２枚目のフレームを判別  
    for x=1:numel(numframe)
      if numframe(x)~=ii
          y=1;
          if flag==1
              y=2;
              flag=0;
              break;
          end
      end   
      if numframe(x)==ii
          y=0;
          break;
      end   
    end
    
   if y==1
       flag=1;
   end

   disp(y)
    
    %電子透かし埋め込み関数
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      [B3,wtflag]=wtmark2(rI,ii,y);        
      
      %B3は画像　wtflagは単一色の箇所
      
       %imshow(B3);
       %peaksnr=PSNR_RGB(B3,I);
       peaksnr=psnr(B3,rI);
       ps(ii)=peaksnr;
       ssimval=ssim(B3,rI);
       ss(ii)=ssimval;
       if max<ssimval
           max=ssimval;
       end
       if min>ssimval
           min=ssimval;
       end
       %B3=imresize(B3,[m n]);
      % ksum=p+ksum;

    %透かし埋め込み前と埋め込み後を画像ファイルで保存
    filename = [sprintf('%03d_image_original',ii) '.bmp'];
    fullname = fullfile(workingDir,'images',filename);
    imwrite(rI,fullname);  
    filename = [sprintf('%03d_image',ii) '.bmp'];
    fullname = fullfile(workingDir,'images',filename);
    imwrite(B3,fullname);    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
    
    %SSIMとPSNRの総計
    ssum=ssum+ssimval;
    sum=sum+peaksnr;
    
 
    
    %%%%%%%%%%%%%%%%% 改ざん %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   [B3,betamper]=tampering(B3,ii,y);
   disp('tampering');
   disp(betamper);
   if betamper>0
       cou=cou+1;
   end
   %このコメントは時間的領域改ざんの場合
   %{
   if ii<=50&&ii>=40
           if ii==40
             A0=B3;
           end
           if ii== 41
             A1=B3;
           end
           if ii==42
             A2=B3;
           end
           if ii== 43
             A3=B3;
           end
           if ii== 44
             A4=B3;
           end
           if ii== 45
             A5=B3;
           end
           if ii== 46
             A6=B3;
           end
           if ii== 47
             A7=B3;
           end
           if ii== 48
             A8=B3;
           end
           if ii== 49
             A9=B3;
           end
           if ii==50
            A10=B3;
           end
   end
   
   if ii>50||ii<40 
    if ii>119 && ii<131
          if ii==120
             B3=A0;
             imshow(B3);
           end
           if ii==121
             B3=A1;
           end
           if ii==122
             B3=A2;
           end
           if ii==123
             B3=A3;
           end
           if ii==124
             B3=A4;
           end
           if ii== 125
             B3=A5;
           end
           if ii== 126
             B3=A6;
           end
           if ii== 127
             B3=A7;
           end
           if ii== 128
             B3=A8;
           end
           if ii== 129
             B3=A9;
           end
           if ii==130
             B3=A10;
             imshow(B3);
           end
     end
   %}
   
   tsum=tsum+betamper;
   %改ざんされた変数を画像ファイルに
   filename = [sprintf('%03d_tampering',ii) '.bmp'];
   fullname = fullfile(workingDir,'images',filename);
   imwrite(B3,fullname); 
    
    

%%%%%%%%%%%%%% 透かし抽出 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      if y==0 %移動体があった場合
       T = dctmtx(8);%dct
       dct = @(block_struct) T * block_struct.data * T';
       I = blockproc(B3,[8 8],dct);
       %quantize 
  QfY = [ 16 11 10 16  24  40  51  61 
        12 12 14 19  26  58  60  55
        14 13 16 24  40  57  69  56
        14 17 22 29  51  87  80  62
        18 22 37 56  68 109 103  77
        24 35 55 64  81 104 113  92
        49 64 78 87 103 121 120 101
        72 92 95 98 112 100 103  99 ];
 t =[255 255 255 255 255 255 255 255
     255 255 255 255 255 255 255 255
     255 255 255 255 255 255 255 255
     255 255 255 255 255 255 255 255
     255 255 255 255 255 255 255 255
     255 255 255 255 255 255 255 255
     255 255 255 255 255 255 255 255
     255 255 255 255 255 255 255 255];
QfY=QfY ./ t;       
Q = @(block_struct)block_struct.data ./ QfY; 

       I = blockproc(I,[8 8],Q);
       [B3,tamper,notdetection,time]= exwmark(I,y,ii,wtflag);  
        tampertime(ii)=time;
        disp('detection');
        disp(tamper);
        disp('not detection');
        disp(betamper-tamper);
        tdsum=tdsum+tamper;
        notsum=notsum+(betamper-tamper);
        Q = @(block_struct)block_struct.data .* QfY; 
        qI = blockproc(B3,[8 8],Q);
        invdct = @(block_struct) T' * block_struct.data * T;
         B3 = blockproc(qI,[8 8],invdct);

               

         filename = [sprintf('%03d_tampering_detection',ii) '.bmp'];
        fullname = fullfile(workingDir,'images',filename);
        imwrite(B3,fullname);
      end
      if y==1 %移動体がない1枚目のフレーム
           T1 = dctmtx(8);
           dct = @(block_struct) T1 * block_struct.data * T1';
           I = blockproc(B3,[8 8],dct);
          before=B3;
          [flag1,time]=exwmark3(I,y,ii);
          tampertime(ii)=time;
          
      end
      if y==2 %移動体がない2枚目のフレーム
           T = dctmtx(8);
           dct = @(block_struct) T * block_struct.data * T';
           I = blockproc(B3,[8 8],dct);
           
           
          [flag2,time]=exwmark4(I,y,ii);
          tampertime(ii)=time;
          tamper=0;
          sinflag=zeros(64);
          for h=1:64
            for i=1:64
                if flag1(h,i)==flag2(h,i) && flag1(h,i)==1
                    tamper=tamper+1;
                    sinflag(h,i)=1;

                end
            end
          end
        disp('detection');
        disp(tamper);
       
        if (tamper-betamper)>=0
            miss=tamper-betamper;
            disp('miss detection');
            disp(miss);
            misssum=misssum+miss*2;
            tdsum=tdsum+(tamper-miss)*2;
        end
        if (tamper-betamper)<0
            not=-1*(tamper-betamper);
            disp('not detection');
            disp(-1*(tamper-betamper));
            notsum=notsum+not*2;
            tdsum=tdsum+(tamper-not)*2;
         end
        
        
          [B1,B3]=res(sinflag,before,I);
          
      
          invdct1 = @(block_struct) T1' * block_struct.data * T1;
          invdct2 = @(block_struct) T' * block_struct.data * T;
           B1 = blockproc(B1,[8 8],invdct1); 
           B3 = blockproc(B3,[8 8],invdct2); 
           
           
           
           filename = [sprintf('%03d_tampering_detection',ii-1) '.bmp'];
           fullname = fullfile(workingDir,'images',filename);
           imwrite(B1,fullname);
           filename = [sprintf('%03d_tampering_detection',ii) '.bmp'];
           fullname = fullfile(workingDir,'images',filename);
           imwrite(B3,fullname);
           B1=rescale(B1);
           writeVideo(outputVideo,B1);
           B3=rescale(B3);
           writeVideo(outputVideo,B3);
      
   end 
      
    
   
   if y==0
    B3=rescale(B3);
    writeVideo(outputVideo,B3);
   
    %imshow(B3);
    end
    %end
end
u=4096*cou-tdsum-notsum-misssum;
disp('総改ざん数');
disp(tsum);
disp('総改ざん検出数');
disp(tdsum);
disp('総誤改ざん検出数');
disp(misssum);
disp('総改ざん不可検出数');
disp(notsum);
disp('検出率');
disp(tdsum/tsum);
disp('精度');
disp((tdsum+u)/(tdsum+u+notsum+misssum));

disp("ssim");
disp(ssum/ii);
disp("psnr");
disp(sum/ii);
disp("kpsnr");
disp(ksum/ii);


ii=1:300;
y=ps(ii);
%plot(ii,y,'o');










