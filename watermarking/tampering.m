function [tamper,tampered]=tampering(img,ii,y)
rng(ii)
if y==2
  rng(ii-1)
end
a=randi(64,1);
b=randi(64,1);
while b<a
    b=randi(64,1);
end
tampered=0;
   for h=1:64
      for i=1:64
        for j=1:8
           for k=1:8
               mb(h,i,j,k)=img(j+8*(h-1),k+8*(i-1));
            
           end
         end
       end
   end  
  
if ii>27  && ii<70
    for h=1:64
      for i=1:64
            if h>20 && h<50 && i>15+ii-29&& i<20+ii-29
              tampered=tampered+1;
            for j=1:8
                for k=1:8
                mb(h,i,j,k)=0;
                
                end
            end
            end
       end
    end 
end

 
if (ii>0 && ii<100) %|| (ii>40 && ii<101)
  for h=1:64
    for i=1:64
           if i>57 && i<65 && h<10 &&h>7
               
              
              tampered=tampered+1;
            for j=1:8
                for k=1:8
                mb(h,i,j,k)=0;
                end
            end
           end
    end
  end
end

%{
if tampered==0
for h=1:64
    for i=1:64
           if i>a && i<b && h>a && h<b
              tampered=tampered+1;
            for j=1:8
                for k=1:8
                mb(h,i,j,k)=0;
                end
            end
           end
    end
end
end
   %}
   for h=1:64
      for i=1:64
        for j=1:8
           for k=1:8
               tamper(j+8*(h-1),k+8*(i-1))=mb(h,i,j,k);
           end
         end
       end
   end  
