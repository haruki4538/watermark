function [B1,B3]=res(sinflag,img1,img2)
  for h=1:64
      for i=1:64
        for j=1:8
           for k=1:8
               mb1(h,i,j,k)=img1(j+8*(h-1),k+8*(i-1));
               mb2(h,i,j,k)=img2(j+8*(h-1),k+8*(i-1));
               %disp(mb(h,i,j,k));
           end
        end
      end
  end
  
  
     for h=1:64
      for i=1:64
          if sinflag(h,i)==1
           for j=1:8
            for k=1:8
                mb1(h,i,j,k)=1;
                mb2(h,i,j,k)=1; 
            end
           end
        end
      end
    end
   for h=1:64
      for i=1:64
        for j=1:8
           for k=1:8
               B1(j+8*(h-1),k+8*(i-1))=mb1(h,i,j,k);
               B3(j+8*(h-1),k+8*(i-1))=mb2(h,i,j,k);
               %disp(mb(h,i,j,k));
           end
        end
      end
  end