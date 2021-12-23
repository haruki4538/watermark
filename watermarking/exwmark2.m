function [wm,tamper]=exwmark2(embimg,y,watermark,x)
% exwmark will extract the watermark which were
% embedded by the wtmark function
disp(embimg);
% embimg    = Embedded image
% wt        = Extracted Watermark


judge=0;
m=embimg;

%m=blkproc(m,[8,8],@dct2);% DCT of image using 8X8 block
%disp(m);

%%%%%%%%%%%%%%%%% To divide image in to 4096---8X8 blocks %%%%%%%%%%%%%%%%%%
k=1; dr=0; dc=0;
% dr is to address 1:8 row every time for new block in x
% dc is to address 1:8 column every time for new block in x
% k is to change the no. of cell

mb=m;
if x==1
    filename=['透かし入り画像',num2str(watermark+x),'.csv'];
    fileID=fopen(filename,'w');
    fprintf(fileID,'%f\n',mb);
    fclose(fileID);
end
k=1;

exwt(:)=0;
moto=zeros(64,64);
 tamper=0;
%% MB一つ一つから透かし抽出 %%
if judge==0

            cou=x+watermark;
            for ii=8:-1:1
                for jj=8:-1:1
                    if k<=numel(dec2bin(cou))
                        %disp(mb(ii,jj));
                        %disp(mb(i,j,ii,jj));
                        exwt(k)=decround(mb(ii,jj),1);
                        %disp(decround(mb(i,j,ii,jj),1));
                        k=k+1;
                    
                    end    
                end
            end
                 for t=1:numel(exwt)%%%%%%%%%%%% 2進数から10進数に変換 %%%%%%%%%%%%%%%%
                     moto=moto+power(2,t-1)*exwt(t);
                 end

              disp(moto);
 

k=1;
 %%%%%%%%%%%%%%%% 抽出した透かしと照らし合わせる %%%%%%%%%%%%%%%%%%%%%%%%%%

           if (x+watermark)~=moto 
               tamper=tamper+1;
               %disp(64*(i-1)+j+watermark);
               for ii=1:8
                   for jj=1:8
                        %disp(64*(i-1)+j+watermark);
                        %disp(moto(i,j));   
                        mb(ii,jj)=0;
                        k=k+1;
                   end
               end
           k=1; exwt(:)=0;
           end
    
    wm=mb;    

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if judge==1
    
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
                if mb(tate,yoko,dr,dc)==0
                    count(tate,yoko)=count(tate,yoko)+1;
                end
            end
         end
       end
    end
   
      %%%%%%%%%%%%%%% 横の拡大MBの場合 %%%%%%%%%%%%%%%%%%%%%%%%%%%
  for  t=1:64 
      for y=1:16
            for yoko=1:4
                countA(t,y)=countA(t,y)+count(t,y*yoko);
            end
      end
  end 
   
  
  
 %%%%%%%%%%%%%%%%%%　横MB透かし抽出 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 flag=0; exwt(:)=0; k=1;
  for i=64:-1:1 
     for j=64:-4:1 
            for ii=8:-1:1 
                if flag== 1
                    break;
                end
                for jj=8:-1:1 
                    if mb(i,j,ii,jj)==0||mb(i,j,ii,jj)==1
                        exwt(k)=mb(i,j,ii,jj);
                        k=k+1;
                    end
                   
                    if mb(i,j,ii,jj)~=0 && mb(i,j,ii,jj)~=1
                        disp(mb(i,j,ii,jj));
                        flag=1;%%%%%%%%%% ループを終わらせる %%%%%%%%%%%
                        break;
                    end
                end
                  for k=1:numel(exwt)%%%%%%%%%%%% 2進数から10進数に変換 %%%%%%%%%%%%%%%%
                     moto(i,j)=moto+power(2,k-1)*exwt(k);
                     disp(exwt(k));
                  end
            end
      end
  end
  
    for k=1:numel(exwt)%%%%%%%%%%%% 2進数から10進数に変換 %%%%%%%%%%%%%%%%
        moto=moto+power(2,k-1)*exwt(k);
        disp(exwt(k));
    end
 
    for i=1:64
        for j=1:64
           if (countA(i,j)+watermark)==moto(i,j)
               for ii=1:8
                   for jj=1:8
                       mb(i,j,ii,jj)=0;
                       tamper=tamper+1;
                   end
               end
           end
        end
    end    
end