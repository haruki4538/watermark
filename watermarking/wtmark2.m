function [embimg,flag]=wtmark2(im,wt,judge)
% wtmark function performs watermarking in DCT domain
% it processes the image into 8x8 blocks.

% im     = Input Image
% wt     = Watermark
% embimg = Output Embedded image
% p      = PSNR of Embedded image

% Checking Dimnesions



a='imagen';
b='.txt';
cowt=wt;
 % Resize image
watermark =wt; %imresize(im2bw((wt)),[32 32]);% Resize and Change in binary 
flag=zeros(512);

x={}; % empty cell which will consist all blocks
%{
T = dctmtx(8);
dct = @(block_struct) T' * block_struct.data * T;
dct_img = blockproc(im,[8 8],dct);
invdct = @(block_struct) T' * block_struct.data * T;
 dct_img = blockproc(dct_img,[8 8],invdct); 
%}
%dct_img=blkproc(im,[8,8],@dct2);% DCT of image using 8X8 block

C =  mat2cell(im,[8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8],[8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8]);


CR=C.';
CR=CR(:)';
Num_block=numel(CR);
for i=1:Num_block
   CRZ{i}=zigzag(CR{i});
end
CR=reshape(CRZ,64,64).';
C=cell2mat(CR);
C=reshape(C,[512,512]);


  T = dctmtx(8);
  dct = @(block_struct) T * block_struct.data * T';
  dct_img = blockproc(im,[8 8],dct);
  

  moto=zeros(64,64);


%m=reshape(C,[512,512]);

%imshow(m);

%{
   mask =  [17  18  24  47  99  99  99  99 
            18  21  26  66  99  99  99  99 
            24  26  56  99  99  99  99  99 
            47  66  99  99  99  99  99  99
            99  99  99  99  99  99  99  99 
            99  99  99  99  99  99  99  99 
            99  99  99  99  99  99  99  99 
            99  99  99  99  99  99  99  99] ;
%}
%{
    mask=[1 1 1 1 1 1 1 1
          1 1 1 1 1 1 1 0
          1 1 1 1 1 1 0 0 
          1 1 1 1 1 0 0 0
          1 1 1 1 0 0 0 0
          1 1 1 0 0 0 0 0
          1 1 0 0 0 0 0 0 
          1 0 0 0 0 0 0 0 ];
    dct_img=blockproc(im,[8 8],@(block_struct) block_struct.data*mask);
    %dct_img=fix(dct_img);
 %} 
 

%%%%%%%%%%%%%%%%%量子化%%%%%%%%%%%%%%%%%%%%%%%%%%%
m=dct_img;
        

%verMB開始
if judge==0
    
    
    m=m*255;
    
  QfY = [ 16 11 10 16  24  40  51  61 
        12 12 14 19  26  58  60  55
        14 13 16 24  40  57  69  56
        14 17 22 29  51  87  80  62
        18 22 37 56  68 109 103  77
        24 35 55 64  81 104 113  92
        49 64 78 87 103 121 120 101
        72 92 95 98 112 100 103  99 ];
    
Q = @(block_struct)block_struct.data ./ QfY; 
  
  m=blockproc(m,[8 8],Q);
% dr is to address 1:8 row every time for new block in x
% dc is to address 1:8 column every time for new block in x
% k is to change the no. of cell

%%%%%%%%%%%%%%%%% To divide image in to 4096---8X8 blocks %%%%%%%%%%%%%%%%%%
    for h=1:64
      for i=1:64
        for j=1:8
           for k=1:8
               mb(h,i,j,k)=m(j+8*(h-1),k+8*(i-1));
            
           end
         end
       end
    end  
flag=zeros(64,64);    
       
      
      for i=1:2:64 
        for j=1:2:64 
            count(i,j)=0;
             x=[mb(i,j),mb(i+1,j)
                mb(i,j+1),mb(i+1,j+1)];
            y=fwht(x);
             if y(1,1)==0
                flag(i,j)=1;
              
             end
             if y(2,1)==0
                flag(i+1,j)=1;
              
             end
             if y(1,2)==0
                flag(i,j+1)=1;
             end
             if y(2,2)==0
                flag(i+1,j+1)=1;
             end
            for ii=8:-1:1 
                for jj=8:-1:1
                    if mb(i,j,ii,jj)<=0
                        count(i,j)=count(i,j)+1;
                        
                    end
                    
                end
            end
            
        end
      end
    
     for i=2:63
         for j=2:63
             if flag(i-1,j)==1&& flag(i+1,j)==1
                 flag(i,j)=1;
             end
              if flag(i,j-1)==1&& flag(i,j+1)==1
                 flag(i,j)=1;
              end
         end
      end
      
count=0;
k=k+1;

%mb=blkproc(mb,[8 8],@idct2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 透かし埋め込み %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   for i=64:-1:1 
        for j=64:-1:1 
             watermark=cowt+64*(i-1)+j;
             
               if flag(i,j)~=1
                for ii=8:-1:1 
                 if watermark== 0
                    break;
                 end
                 for jj=8:-1:1
                     wt=rem(watermark,2);
                     watermark=watermark/2;
                     watermark=fix(watermark);
                     mb(i,j,ii,jj)=wt/10;
                     exwt(k)=decround(mb(i,j,ii,jj),1);
                     k=k+1;
                    if watermark==0   
                     break;  
                    end
                 end
                end
               end
        end   
   end
     


%%%%%%%%%%%%%%%%%%%%%%%%%%%% 元の4次元配列から2次元配列%%%%%%%%%%%%%%%
embimg=[];
    for i=1:64 
        for j=1:64 
            for ii=1:8 
                for jj=1:8
                    embimg(ii+8*(i-1),jj+8*(j-1))=mb(i,j,ii,jj);
                end
             end
         end
    end

    invQ = @(block_struct)block_struct.data .* QfY;
    embimg = blockproc(embimg,[8 8],invQ);
    embimg=embimg/255;
    invdct = @(block_struct) T' * block_struct.data * T;
    embimg = blockproc(embimg,[8 8],invdct);

 %{   
 for i= 1:Num_block
     X{i} = izigzag(embimg,8,8);
end  

ic= reshape(X,64,64).';    
Z=cell2mat(ic);
embimg=reshape(Z,[512,512]);

    %}

  
    
    
    
   
%WT=reshape(iCR,64,64).';
%embimg=cell2mat(WT);


%embimg=rescale(embimg);
%p=psnr(embimg,im);
%embimg=blkproc(embimg,[8,8],@dct2);
%disp(embimg);
end
%verMB終了


if judge==2
    %ver拡大MB開始
    k=1; dr=0; dc=0; count=zeros(64); countA=zeros(64);
  %%%%%%%%%%%%%%%%%４次元配列に格納%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for h=1:64
      for i=1:64
        for j=1:8
           for k=1:8
               mb(h,i,j,k)=m(j+8*(h-1),k+8*(i-1));
               
           end
        end
      end
    end
    
    %%%%%%%%%%%%%%%%% ランダム並び替え %%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
   rng('default');
   flag=zeros(64);
   rng(1);
   for i=1:64
        for j=1:64
           
                for ii=1:8
                    for jj=1:8
                        t=randi(64,1);
                        k=randi(64,1);
                        if flag(t,k)~=-1 && flag(i,j)~=-1 
                            tmp=mb(i,j,ii,jj);
                            mb(i,j,ii,jj)=mb(t,k,ii,jj);
                            mb(t,k,ii,jj)=tmp;
                            flag(i,j)=-1;
                            flag(t,k)=-1;
                        end
                    end
                end
        end
    end
   flag=zeros(64,64);
   
    %%%%%%埋め込み可能bit数計算%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   for tate=1:64 
       for yoko=1:64
         for dr=1:8
            for dc=1:8
                if mb(tate,yoko,dr,dc)~=0
                    count(tate,yoko)=count(tate,yoko)+1;
                end
            end
         end
       end
   end
   %%%%%%%%%%%%%%% 縦の拡大MB形成の場合 %%%%%%%%%%%%%%%%%%%%%%%%%%%
  for  t=1:64 
      for y=1:64
            if rem(t,4)==1 
                countA(t,y)=count(t,y)+count(t+1,y)+count(t+2,y)+count(t+3,y);
            end
      end
  end
  
  countA=zeros(64,64);
   count=0;
    %%%%%%%%%%%%%%% 拡大MB透かし埋め込み%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      for i=1:4:64 % To address row -- 8X8 blocks of image
        for j=1:64 % To address columns -- 8X8 blocks of image
            watermark=watermark+countA(i,j);
            for ii=8:-1:1 
                if watermark== 0
                    break;
                end
                for jj=8:-1:1
                    
                    wt=rem(watermark,2);
                    watermark=watermark/2;
                    watermark=fix(watermark);
                    mb(i,j,ii,jj)=wt;
                    count=count+1;  

                    if watermark==0 

                        break;   
                    end
                end
            end
        end
      end
   
    %%%%%%%%%%%%%%%%%%%%%元の画像に並び替え%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rng(1);
    
       for i=1:64
        for j=1:64
                for ii=1:8
                    for jj=1:8
                        t=randi(64,1);
                        k=randi(64,1);
                        if flag(t,k)~=-1 && flag(i,j)~=-1 
                            tmp=mb(i,j,ii,jj);
                            mb(i,j,ii,jj)=mb(t,k,ii,jj);
                            mb(t,k,ii,jj)=tmp;
                            flag(i,j)=-1;
                            flag(t,k)=-1;
                        end
                    end
                end
        end
       end 
      
     %ver拡大MB(横)終了
    
     for i=1:64 
        for j=1:64 
            for ii=1:8 
                for jj=1:8
                     embimg(ii+8*(i-1),jj+8*(j-1))=mb(i,j,ii,jj) ;
             
                 end
             end
         end
     end

     
    invdct = @(block_struct) T' * block_struct.data * T;
    embimg = blockproc(embimg,[8 8],invdct);
   
%imshow(embimg);
%embimg=cell2mat(WT);
        %embimg=(uint8(blkproc(embimg,[8 8],@idct2)));       
        %p=psnr(embimg,im);
        %embimg=blkproc(embimg,[8,8],@dct2);
        %disp(embimg);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if judge==1
    %ver拡大MB開始
    k=1; dr=0; dc=0; count=zeros(64); countA=zeros(64);
  %%%%%%%%%%%%%%%%%４次元配列に格納%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for h=1:64
      for i=1:64
        for j=1:8
           for k=1:8
               mb(h,i,j,k)=m(j+8*(h-1),k+8*(i-1));
           end
        end
      end
    end
    
    %%%%%%%%%%%%%%%%% ランダム並び替え %%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
   rng('default');
   flag=zeros(64);
   rng(1);
   for i=1:64
        for j=1:64
           
                for ii=1:8
                    for jj=1:8
                        t=randi(64,1);
                        k=randi(64,1);
                        if flag(t,k)~=-1 && flag(i,j)~=-1 
                            tmp=mb(i,j,ii,jj);
                            mb(i,j,ii,jj)=mb(t,k,ii,jj);
                            mb(t,k,ii,jj)=tmp;
                            flag(i,j)=-1;
                            flag(t,k)=-1;
                        end
                    end
                end
        end
    end
   flag=zeros(64,64);
   
    %%%%%%埋め込み可能bit数計算%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   for tate=1:64 
       for yoko=1:64
         for dr=1:8
            for dc=1:8
                if mb(tate,yoko,dr,dc)~=0
                    count(tate,yoko)=count(tate,yoko)+1;
                end
            end
         end
       end
   end
   %%%%%%%%%%%%%%% 横の拡大MB形成の場合 %%%%%%%%%%%%%%%%%%%%%%%%%%%
  for  t=1:64 
      for y=1:64
            if rem(y,4)==1 
                countA(t,y)=count(t,y)+count(t,y+1)+count(t,y+2)+count(t,y+3);
            end
      end
  end
  
  countA=zeros(64,64);
   count=0;
    %%%%%%%%%%%%%%% 拡大MB透かし埋め込み%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      for i=1:64 % To address row -- 8X8 blocks of image
        for j=1:4:64 % To address columns -- 8X8 blocks of image
            watermark=watermark+countA(i,j);
            
            for ii=8:-1:1 
                if watermark== 0
                    break;
                end
                for jj=8:-1:1
                    
                    wt=rem(watermark,2);
                    watermark=watermark/2;
                    watermark=fix(watermark);
                    mb(i,j,ii,jj)=wt;
                    count=count+1;  

                    if watermark==0 

                        break;   
                    end
                end
            end
        end
      end
   
    %%%%%%%%%%%%%%%%%%%%%元の画像に並び替え%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rng(1);
    
       for i=1:64
        for j=1:64
                for ii=1:8
                    for jj=1:8
                        t=randi(64,1);
                        k=randi(64,1);
                        if flag(t,k)~=-1 && flag(i,j)~=-1 
                            tmp=mb(i,j,ii,jj);
                            mb(i,j,ii,jj)=mb(t,k,ii,jj);
                            mb(t,k,ii,jj)=tmp;
                            flag(i,j)=-1;
                            flag(t,k)=-1;
                        end
                    end
                end
        end
       end 
      
     %ver拡大MB(横)終了
    
     for i=1:64 
        for j=1:64 
            for ii=1:8 
                for jj=1:8
                     embimg(ii+8*(i-1),jj+8*(j-1))=mb(i,j,ii,jj) ;
             
                 end
             end
         end
     end

     
    invdct = @(block_struct) T' * block_struct.data * T;
    embimg = blockproc(embimg,[8 8],invdct);
     
%imshow(embimg);
%embimg=cell2mat(WT);
        %embimg=(uint8(blkproc(embimg,[8 8],@idct2)));       
        %p=psnr(embimg,im);
        %embimg=blkproc(embimg,[8,8],@dct2);
        %disp(embimg);
end






    
    

       
       
 
