function [flag1,time]=exwmark3(img,y,ii)
m=img;
watermark=ii;
tamper=0;
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
 count=zeros(64); countA=zeros(64);   
 flag1=zeros(64);
%%%%%%%%%%%%%%%%%%%%%%%%%　ランダム並び替え　%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

moto=zeros(64,64);
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
           if  i==1&& j==1
               time=moto(i,j)-countA(i,j);
           end
           if (countA(i,j)+watermark)~=moto(i,j)
               moto(i,j)=moto(i,j)-1;
               
             if (countA(i,j)+watermark)~=moto(i,j)
               disp(moto(i,j));
               disp(countA(i,j)+watermark);
               flag1(i,j)=1;
               flag1(i,j+1)=1;
               flag1(i,j+2)=1;
               flag1(i,j+3)=1;
               tamper=tamper+1;
               for ii=1:8
                   for jj=1:8
                       mb(i,j,ii,jj)=1;
                   end
               end
              end
           end
        end
    end    
%%%%%%%%%%%%%%%%%%% 元の画像に並び替え %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag=zeros(64,64);
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