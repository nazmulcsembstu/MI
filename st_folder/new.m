[fname path]=uigetfile('*.mat');
fname=strcat(path,fname);
load(fname);

signal = val(1, :);
%z=zeros(1, 200);
%signal=[z,signal,z];

[c,l]=wavedec(signal,4,'db4');

ca1=appcoef(c,l,'db4',1);
ca2=appcoef(c,l,'db4',2);
ca3=appcoef(c,l,'db4',3);
%ca4=appcoef(c,l,'db4',4)

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

subplot(2, 1, 1)
plot(ecg)
hold on
plot(base, 'red', 'LineWidth', 3)
hold off
legend('RAW ECG', 'Base Line')
title('Wandering Baseline')

subplot(2, 1, 2)
plot(bc_sig)
title('Baseline Corrected Signal')

%{
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

%{
ss = [;];
tt = [;];

data_index1 = 1;
data_index2 = 1;

start = Ploc(1, 1);

len = length(Ploc(:, 1));

for (j = 1 : 1 : min(length(Sloc(:, 1)), length(Tloc(:, 1))))
    
    pos1 = Sloc(j, 1)+2;
    pos2 = Tloc(j, 1)-7;
    
    SOff = pos1;
    TOn = pos2;
    
    avg_slp = abs((ecg(pos1) - ecg(pos2))/(pos1 -pos2));
            
    ss = [ss; [SOff, ecg(SOff)]];
    tt = [tt; [TOn, ecg(TOn)]];
        
    endd = Tloc(j, 1);
    signal = ecg(start : endd);
    ts = ecg(SOff : TOn);
    
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
          im = imresize(im, [227 227]);
   
          if avg_slp > 5.00
             baseFileName = sprintf('abnormal_%d.jpg', data_index1); 
             %fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\OneDrive\Documents\over\abnormal', baseFileName);
             %imwrite(im, fullFileName);
             data_index1 = data_index1 + 1;
    
          else
             baseFileName = sprintf('normal_%d.jpg', data_index2); 
             %fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\OneDrive\Documents\over\normal', baseFileName);
             %imwrite(im, fullFileName);
             data_index2 = data_index2 + 1;
          end 
          
      end
       
       if j+1 <= len
         start = Ploc(j+1, 1);
       end
end
%}

figure;
plot(A)
hold on
scatter(Rloc(:, 1), Rloc(:, 2), 'r', 'o')
scatter(Ploc(:, 1), Ploc(:, 2), 'b', 'o')
scatter(Qloc(:, 1), Qloc(:, 2), 'm', 'o')
scatter(Sloc(:, 1), Sloc(:, 2), 'g', 'o')
scatter(Tloc(:, 1), Tloc(:, 2), 'o', 'o')
%scatter(ss(:, 1), ss(:, 2), 'r', '*')
%scatter(tt(:, 1), tt(:, 2), 'm', '*')
legend('ECG','R','P','Q','S','T');
hold off
title('ECG with extracted P,Q,R,S,T peaks');
%}
