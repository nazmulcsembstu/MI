% Input_Portion
[fname path]=uigetfile('*.mat');
fname=strcat(path,fname);
load(fname);
ecg = val(1, :);

%plot(ecg);

% Wavlet_Decomposition
[c, l] = wavedec(ecg, 4, 'db4');

app1 = appcoef(c, l, 'db4', 1);
app2 = appcoef(c, l, 'db4', 2);   
%app3 = appcoef(c, l, 'db4', 3);  
%app4 = appcoef(c, l, 'db4', 4);

det1to4 = detcoef(c, l, 'db4');    
det2 = cell2mat(det1to4(2)); 

app = app2;
det = det2;

% ECG_Filtering
ECGsignalFiltered1=sgolayfilt(app, 1, 3);
ECGsignalFiltered2=detrend(ECGsignalFiltered1);

Fs = 360;
t = (0 : length(app) - 1) / Fs; 
[p, s, mu] = polyfit(t, ECGsignalFiltered2, 21); 
f_y = polyval(p, t, [], mu);
ecg = ECGsignalFiltered2 - f_y;

% ECG_Segmentation   % 304 -->5, 302,307 -->6, 300,313,320--->8
Fs = Fs/8;

det = det.*det.*(det >= 0);  
window = round(Fs*1.5);
max_points = [];            
det_peaks = [];

for i = 1 : window : (length(det) - window)
    M = max(det(i : (i + window)));         
    if M
        max_points = find(...            
        det(i : (i + window)) >= 0.7*M);	
    else
        continue;                         
    end

    w_peaks = [];                         
    w_peaks = [w_peaks max_points(1)];
    
    for j = 2 : 1 : length(max_points)
        if (max_points(j) > (max_points(j - 1) + window))
            w_peaks = [w_peaks max_points(j)];
        end
    end
    
    det_peaks = [det_peaks (w_peaks + (i-1))];
end

P = [;];    
Q = [;];    
R = [;];   
S = [;];    
T = [;];

for i = 1 : 1 : length(det_peaks)
	range = det_peaks(i) : (det_peaks(i) + 3);
    M = max(ecg(range));
    location = find(ecg(range) == M);
    Rpeak = range(location);
    R = [R; [Rpeak, ecg(Rpeak)]]
end

for j = 1 : 1 : length(R(:, 1))
    
	range = R(j, 1) - 25 : R(j, 1) - 3;
    if range(length(range)) < length(ecg)
        M = max(ecg(range));
        Ppeak = find(ecg(range) == M);
        Ppeak = Ppeak(1);
        Ppeak = range(Ppeak);
        P = [P; [Ppeak, ecg(Ppeak)]];
    end
    
    range = R(j, 1) - 6 : R(j, 1)-3;
    if range(length(range)) < length(ecg)
        m = min(ecg(range));
        Qpeak = find(ecg(range) == m);
        Qpeak = Qpeak(1);
        Qpeak = range(Qpeak);
        Q = [Q; [Qpeak, ecg(Qpeak)]];
    end
  
    range = R(j, 1) + 1 : R(j, 1) + 5;
    if range(length(range)) < length(ecg)
        m = min(ecg(range));
        Speak = find(ecg(range) == m);
        Speak = Speak(1);
        Speak = range(Speak);
        S = [S; [Speak, ecg(Speak)]];
    end
    
    range = R(j, 1) + 6 : R(j, 1) + 30;
    if range(length(range)) < length(ecg)
        M = max(ecg(range));
        Tpeak = find(ecg(range) == M);
        Tpeak = Tpeak(1);
        Tpeak = range(Tpeak);
        T = [T; [Tpeak, ecg(Tpeak)]];
    end
end

ss = [;];
tt = [;];

data_index1 = 1;
data_index2 = 2;

start = P(1, 1);

len = length(P(:, 1));

for j = 1 : 1 : min(length(S(:, 1)), length(T(:, 1)))
    
    pos1 = S(j, 1)+2;
    pos2 = T(j, 1)-7;
    
    SOff = pos1;
    TOn = pos2;
    
    avg_slp = abs((ecg(pos1) - ecg(pos2))/(pos1 -pos2));
            
    ss = [ss; [SOff, ecg(SOff)]];
    tt = [tt; [TOn, ecg(TOn)]];
        
    endd = T(j, 1);
    signal = ecg(start : endd);
    %ts = ecg(SOff : TOn);
    
    figure;
    plot(signal);
       
      ff = length(signal);
                
      if ff>4
                
          Fs = 128;
          fb = cwtfilterbank('SignalLength',ff,...
                     'SamplingFrequency',Fs,...
                     'VoicesPerOctave',12);
                
          cfs = abs(fb.wt(signal));
          im = ind2rgb(im2uint8(rescale(cfs)), jet(128));
          im = imresize(im,[227 227]);
   
          if avg_slp > 5.00
             baseFileName = sprintf('abnormal_%d.jpg', data_index1); 
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\OneDrive\Documents\over1\abnormal', baseFileName);
             imwrite(im, fullFileName);
             data_index1 = data_index1 + 1;
             %figure;
             %plot(signal);
             %title('abnormal');
    
          else
             baseFileName = sprintf('normal_%d.jpg', data_index2); 
             fullFileName = fullfile('C:\Users\yEaSiN aRaFaT\OneDrive\Documents\over1\normal', baseFileName);
             imwrite(im, fullFileName);
             data_index2 = data_index2 + 1;
             %figure;
             %plot(signal);
             %title('normal');
          end 
          
      end
       
       if j+1 <= len
         start = P(j+1, 1);
       end
end

figure;
%subplot(2,1,1)
plot(1:length(ecg), ecg, 'b')
hold on
scatter(P(:, 1), P(:, 2), 'r', 'o')
scatter(Q(:, 1), Q(:, 2), 'r', 'o')
scatter(R(:, 1), R(:, 2), 'r', 'o')
scatter(S(:, 1), S(:, 2), 'r', 'o')
scatter(T(:, 1), T(:, 2), 'r', 'o')
scatter(ss(:, 1), ss(:, 2), 'm', '*')
scatter(tt(:, 1), tt(:, 2), 'g', '*')
legend('ECG', 'P', 'Q', 'R', 'S', 'T')
hold off
title('ECG with extracted P, Q, R, S, T peaks');

%{
subplot(2,1,2)
plot(1:length(ecg), ecg, 'b')
hold on
scatter(ss(:, 1), ss(:, 2), 'm', '*')
scatter(tt(:, 1), tt(:, 2), 'r', 'o')
legend('ECG', 'S', 'T')
hold off
title('ECG with extracted ST Segment');
%}







