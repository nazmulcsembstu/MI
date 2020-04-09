
[fname path]=uigetfile('*.mat');
fname=strcat(path,fname);
load(fname);

signal = val(1, :);
z=zeros(1, 200);
signal=[z,signal,z];

[c,l]=wavedec(signal,4,'db4');

ca1=appcoef(c,l,'db4',1);
ca2=appcoef(c,l,'db4',2);

app=ca2;

ECGsignalFiltered1=sgolayfilt(app, 1, 3);
ECGsignalFiltered2=detrend(ECGsignalFiltered1);

Fs = 360;
t = (0 : length(app) - 1) / Fs;
[p, s, mu] = polyfit(t, ECGsignalFiltered2, 21); 
f_y = polyval(p, t, [], mu);
ecg = ECGsignalFiltered2 - f_y;

Wn = 0.01;                 
a = 1;                     
b = fir1(200, Wn, 'low');  
fir_x = filter(b, a, ecg);

med1_x = medfilt1(fir_x, 3, round(Fs*(2/10)));
med2_x = medfilt1(med1_x, 3, round(Fs/4*(6/10)));

offset = 100;
base = [med2_x(offset + 1:length(med2_x)) med2_x(length(med2_x) - offset + 1:length(med2_x))];
bc_sig = ecg - base;

A = bc_sig;
m1=max(A)*.50;
P=find(A>=m1);

P1=P; 
P2=[]; 
last=P1(1);
P2=[P2 last];

for (i=2:1:length(P1))
    if(P1(i)>(last+10))
        last=P1(i);
        P2=[P2 last];
    end
end

P3=P2;
Rloc=[];

for (i=1:1:length(P3))
    
    range=P3(i)-20:P3(i)+20;
    m=max(A(range));
    loc=find(A(range)==m);
    pos=range(loc);
    Rloc=[Rloc; [pos, A(pos)]];
end

Ploc=[];
Qloc=[];
Sloc=[];
Tloc=[];

for (j=1:1:length(Rloc))

    range=Rloc(j,1)-15:Rloc(j,1)-7;
    m=max(A(range));
    loc=find(A(range)==m);
    pos=range(loc);
    Ploc=[Ploc; [pos, A(pos)]];
    
    range=Rloc(j,1)-6:Rloc(j,1)-3;
    m=min(A(range));
    loc=find(A(range)==m);
    pos=range(loc);
    Qloc=[Qloc; [pos, A(pos)]];
    
    range=Rloc(j,1)+1:Rloc(j,1)+10;
    m=min(A(range));
    loc=find(A(range)==m);
    pos=range(loc);
    Sloc=[Sloc; [pos, A(pos)]];
   
    range=Rloc(j,1)+11:Rloc(j,1)+30;
    m=max(A(range));
    loc=find(A(range)==m);
    pos=range(loc);
    Tloc=[Tloc; [pos, A(pos)]];
    
end

ss = [;];
tt = [;];

j = 1;
n = min(length(Sloc(:, 1)), length(Tloc(:, 1)))-4;

data_index1 = 3470;
data_index2 = 2977;
    
   while j <= n
       
    start = Ploc(j, 1);
    endd = Tloc(j, 1);
    slp = 0;
    
    for (i= j : j+4)
        pos1 = Sloc(i, 1)+2;
        pos2 = Tloc(i, 1)-7;
        slp = slp + abs((ecg(pos1) - ecg(pos2))/(pos1 -pos2));
        endd = Tloc(i, 1);
    end
    
      j=j+5;
      
      avg_slp = slp/5;
      
      signal = bc_sig(start : endd);
      %figure;
      %plot(signal);
      
      
      ff = length(signal);
                
      if ff>4
                
          Fs = 128;
          fb = cwtfilterbank('SignalLength',ff,...
                     'SamplingFrequency',Fs,...
                     'VoicesPerOctave',12);
                
          cfs = abs(fb.wt(signal));
          im = ind2rgb(im2uint8(rescale(cfs)), jet(128));
          
          im1 = imresize(im,[227 227]);
          im2 = imresize(im,[224 224]);
          im3 = imresize(im,[128 128]);
          im4 = imresize(im,[28 28]);
          
          gr1 = rgb2gray(im1);
          gr2 = rgb2gray(im2);
          gr3 = rgb2gray(im3);
          gr4 = rgb2gray(im4);
          
   
          if avg_slp > 6.50
             baseFileName = sprintf('abnormal_%d.jpg', data_index1);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\rgb_227\abnormal', baseFileName);
             imwrite(im1, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\rgb_224\abnormal', baseFileName);
             imwrite(im2, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\rgb_128\abnormal', baseFileName);
             imwrite(im3, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\rgb_28\abnormal', baseFileName);
             imwrite(im4, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\gr_227\abnormal', baseFileName);
             imwrite(gr1, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\gr_224\abnormal', baseFileName);
             imwrite(gr2, fullFileName);
              
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\gr_128\abnormal', baseFileName);
             imwrite(gr3, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\gr_28\abnormal', baseFileName);
             imwrite(gr4, fullFileName);
             
             data_index1 = data_index1 + 1;
    
          else
             baseFileName = sprintf('normal_%d.jpg', data_index2); 
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\rgb_227\normal', baseFileName);
             imwrite(im1, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\rgb_224\normal', baseFileName);
             imwrite(im2, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\rgb_128\normal', baseFileName);
             imwrite(im3, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\rgb_28\normal', baseFileName);
             imwrite(im4, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\gr_227\normal', baseFileName);
             imwrite(gr1, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\gr_224\normal', baseFileName);
             imwrite(gr2, fullFileName);
              
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\gr_128\normal', baseFileName);
             imwrite(gr3, fullFileName);
             
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\Desktop\gr_28\normal', baseFileName);
             imwrite(gr4, fullFileName);
             
             data_index2 = data_index2 + 1;
          end 
          
      end
    
   end
   
    % S-Offset fixed point
    % T-offset using slope
    n = 1;
    
    mid = int64((pos1+pos2)/2);
    mn = 0.0;
    start = 1;
    
    for i = mid : pos2-2
         lft = (bc_sig(i) - bc_sig(i-n))/(i - (i-n));
         rgt = (bc_sig(i) - bc_sig(i+n))/(i - (i+n));
         avg = abs((lft + rgt)/2);
        
        if avg > mn
            mn = avg;
            start = i;
        end
    end
    %}
    
    %SOff = pos1;
    %TOn = pos2;
            
    %ss = [ss; [SOff, bc_sig(SOff)]];
    %tt = [tt; [TOn, bc_sig(TOn)]];



figure;
plot(A)
hold on
scatter(Rloc(:, 1), Rloc(:, 2), 'r', 'o')
scatter(Ploc(:, 1), Ploc(:, 2), 'b', 'o')
scatter(Qloc(:, 1), Qloc(:, 2), 'm', 'o')
scatter(Sloc(:, 1), Sloc(:, 2), 'g', 'o')
scatter(Tloc(:, 1), Tloc(:, 2), 'o', 'o')
scatter(ss(:, 1), ss(:, 2), 'r', '*')
scatter(tt(:, 1), tt(:, 2), 'm', '*')
legend('ECG','R','P','Q','S','T');
hold off
title('ECG with extracted P,Q,R,S,T peaks');

