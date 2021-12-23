function [wm,tamper,notdetection,time]=exwmark(embimg,y,watermark,wtflag)
% exwmark will extract the watermark which were
% embedded by the wtmark function

% embimg    = Embedded image
% wt        = Extracted Watermark
embimg = imresize(embimg,[512 512]);


m=embimg;
notdetection=0;
%m=blkproc(m,[8,8],@dct2);% DCT of image using 8X8 block
%disp(m);

%%%%%%%%%%%%%%%%% To divide image in to 4096---8X8 blocks %%%%%%%%%%%%%%%%%%
k=1; dr=0; dc=0;
% dr is to address 1:8 row every time for new block in x
% dc is to address 1:8 column every time for new block in x
% k is to change the no. of cell
  for h=1:64
      for i=1:64
        for j=1:8
           for k=1:8
               mb(h,i,j,k)=m(j+8*(h-1),k+8*(i-1));
               %disp(mb(h,i,j,k));
           end
        end
      end
  end

k=1;
x=0;
exwt(:)=0;
moto=zeros(64,64);
 tamper=0;
judge=y;

%% MB一つ一つから透かし抽出 %%
if judge==0
    for i=64:-1:1
        for j=64:-1:1
            cou=64*(i-1)+j+watermark;
           if wtflag(i,j)~=1
                
            for ii=8:-1:1
                for jj=8:-1:1
                    if k<=numel(dec2bin(cou))
                        %disp(mb(i,j,ii,jj));
                        %exwt(k)=decround(mb(i,j,ii,jj),1);
                        exwt(k)=decround(mb(i,j,ii,jj)*10,1);
                        %disp(decround(mb(i,j,ii,jj),1));
                        k=k+1;

                    end    
                end
            end
                 for t=1:numel(exwt)%%%%%%%%%%%% 2進数から10進数に変換 %%%%%%%%%%%%%%%%
                     moto(i,j)=moto(i,j)+power(2,t-1)*exwt(t);
                 end
            end
              %disp(moto(i,j));
              k=1;
              exwt(:)=0; 
            
        end        
    end
k=1;
 %%%%%%%%%%%%%%%% 抽出した透かしと照らし合わせる %%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:64
        for j=1:64
           if i==1 && j==1
               time=moto(i,j)-(64*(i-1)+j);
           end
           if wtflag(i,j)~=1
           if (64*(i-1)+j+watermark)~=moto(i,j) 
               tamper=tamper+1;

               for ii=1:8
                   for jj=1:8
                        %disp(64*(i-1)+j+watermark);
                        %disp(moto(i,j));
                        
                        mb(i,j,ii,jj)=1;

                        k=k+1;
                       
                   end
               end
           end
           k=1; exwt(:)=0;
           
        end
    end 
    
   for i=1:64
        for j=1:64
               for ii=1:8
                   for jj=1:8       
                     wm(ii+8*(i-1),jj+8*(j-1))=mb(i,j,ii,jj);
                   end
                end
        end
   end        
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if judge==1
 count=zeros(64); countA=zeros(64);   
%%%%%%%%%%%%%%%%%%%%%%%%%　ランダム並び替え　%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     rng('default');
   flag=zeros(64);
   rng(0);
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
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%　埋め込み可能bit数計算 %%%%%%%%%%%%%%%%%%%%%%%% 
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
   
      %%%%%%%%%%%%%%% 横の拡大MBの場合 %%%%%%%%%%%%%%%%%%%%%%%%%%%
  for  t=1:64 
      for y=1:64
            if rem(y,4)==1 
                countA(t,y)=count(t,y)+count(t,y+1)+count(t,y+2)+count(t,y+3);
            end
      end
  end
   
  
  k=1;
 %%%%%%%%%%%%%%%%%%　横MB透かし抽出 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 exwt(:)=0; k=1;
  for i=1:64 
     for j=1:4:64 
         cou=watermark+countA(i,j); 
            for ii=8:-1:1 
                for jj=8:-1:1 
                    if k<=numel(dec2bin(cou)) 

                        exwt(k)=decround(mb(i,j,ii,jj),1);
                        exwt(9)=1;
                        k=k+1;
                    end
                end
            end
            
             for k=1:numel(exwt)%%%%%%%%%%%% 2進数から10進数に変換 %%%%%%%%%%%%%%%%
                moto(i,j)=moto(i,j)+power(2,k-1)*exwt(k);
             end
               %disp('本来の値');
               %disp(countA(i,j)+watermark);
               %disp('抽出した値');
               %disp(moto(i,j));
     end
  end

  

 
    for i=1:64
        for j=1:4:64
            
           if (countA(i,j)+watermark)~=moto(i,j)
               tamper=tamper+1;
               for ii=1:8
                   for jj=1:8
                       mb(i,j,ii,jj)=1;
                   end
               end
           end
        end
    end    
%%%%%%%%%%%%%%%%%%% 元の画像に並び替え %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag=zeros(64,64);
rng(0);
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
   %%%%%%%%%%%%%%%%%%%%%%%% 4次元から２次元に%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      for i=1:64 
        for j=1:64 
            for ii=1:8 
                for jj=1:8
                     wm(ii+8*(i-1),jj+8*(j-1))=mb(i,j,ii,jj) ;
             
                 end
             end
         end
      end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


 if judge==2 %%%%%%%%%%%%%%%%%%%% 縦の拡大MB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      count=zeros(64); countA=zeros(64);   
%%%%%%%%%%%%%%%%%%%%%%%%%　ランダム並び替え　%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     rng('default');
   flag=zeros(64);
   rng(0);
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
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%　埋め込み可能bit数計算 %%%%%%%%%%%%%%%%%%%%%%%% 
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
   
      %%%%%%%%%%%%%%% 横の拡大MBの場合 %%%%%%%%%%%%%%%%%%%%%%%%%%%
   for  t=1:64 
      for y=1:64
            if rem(t,4)==1 
                countA(t,y)=count(t,y)+count(t+1,y)+count(t+2,y)+count(t+3,y);
            end
      end
  end
   
  
  k=1;
 %%%%%%%%%%%%%%%%%%　縦MB透かし抽出 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 exwt(:)=0; k=1;
  for i=1:4:64 
     for j=1:64 
         cou=watermark+countA(i,j); 
            for ii=8:-1:1 
                for jj=8:-1:1 
                    if k<=numel(dec2bin(cou)) 
                        
                        exwt(k)=decround(mb(i,j,ii,jj),1);
                        exwt(9)=1;
                        k=k+1;
                    end
                end
            end
            
             for k=1:numel(exwt)%%%%%%%%%%%% 2進数から10進数に変換 %%%%%%%%%%%%%%%%
                moto(i,j)=moto(i,j)+power(2,k-1)*exwt(k);
             end
               %disp('本来の値');
               %disp(countA(i,j)+watermark);
               %disp('抽出した値');
               %disp(moto(i,j));
     end
  end

  

 
    for i=1:4:64
        for j=1:64
           if (countA(i,j)+watermark)~=moto(i,j)
               disp(moto(i,j));
               disp(countA(i,j)+watermark);
               tamper=tamper+1;
               for ii=1:8
                   for jj=1:8
                       mb(i,j,ii,jj)=1;
                   end
               end
           end
        end
    end    

%%%%%%%%%%%%%%%%%%% 元の画像に並び替え %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag=zeros(64,64);
rng(0);
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
   %%%%%%%%%%%%%%%%%%%%%%%% 4次元から２次元に%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      for i=1:64 
        for j=1:64 
            for ii=1:8 
                for jj=1:8
                     wm(ii+8*(i-1),jj+8*(j-1))=mb(i,j,ii,jj) ;
             
                 end
             end
         end
      end
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%