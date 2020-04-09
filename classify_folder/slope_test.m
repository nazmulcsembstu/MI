% Input_Portion
load('302m.mat');
ecg = val(1, :);

% Wavlet_Decomposition
[c,l] = wavedec(ecg, 4, 'db4');

app1 = appcoef(c, l, 'db4', 1);
app2 = appcoef(c, l, 'db4', 2);   
app3 = appcoef(c, l, 'db4', 3);  
app4 = appcoef(c, l, 'db4', 4);

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

%{
figure;
plot(t, ecg);
hold on
xaxis = t*0;
plot(t, xaxis);
title(['Filtered Signal ',ecg]);xlabel('Time (Sec)');ylabel('Amplitude mV');
%}

Fs = Fs/6;

% ECG_Segmentation
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
    R = [R; [Rpeak, ecg(Rpeak)]];
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
    
    range = R(j, 1) + 6 : R(j, 1) + 25;
    if range(length(range)) < length(ecg)
        M = max(ecg(range));
        Tpeak = find(ecg(range) == M);
        Tpeak = Tpeak(1);
        Tpeak = range(Tpeak);
        T = [T; [Tpeak, ecg(Tpeak)]];
    end
end

st_elevation = [;];
ss = [;];
tt = [;];

for j = 1 : 1 : min(length(S(:, 1)), length(T(:, 1)))
    
    st = S(j, 1);
    ed = T(j, 1);
    n=1;
    
    right = (ecg(st) - ecg(st+(n)))/(st - (st+(n)));
    avg = right;
    
    mn_slp = abs(avg);
    prv = mn_slp;
    index = st;
    
    for i = st+1 : ed-3
         left = (ecg(i) - ecg(i-n))/(i - (i-n));
         right = (ecg(i) - ecg(i+n))/(i - (i+n));
         avg = (left + right)/2;
         
         if abs(avg) < mn_slp
             mn_slp = abs(avg);
             index = i;
         end
    end
    
    pos1 = st;
    mx = 0;
    
    for i = st+1 : index
         left = (ecg(i) - ecg(i-n))/(i - (i-n));
         right = (ecg(i) - ecg(i+n))/(i - (i+n));
         avg = abs((left + right)/2);
         
         dif = abs(prv - avg);
         
         if dif > mx
             pos1 = i;
             mx = dif;
         end
         
         prv = avg;
    end
    
    left = (ecg(index) - ecg(index-(n)))/(index - (index-(n)));
    avg = left;
    
    mn_slp = abs(avg);
    prv = mn_slp;
    
    pos2 = index;
    mx = 0;
    
    fprintf('avrage = %d %d %d\n',st,index,ed);
    
    for i = index+1 : ed-3
         left = (ecg(i) - ecg(i-n))/(i - (i-n));
         right = (ecg(i) - ecg(i+n))/(i - (i+n));
         avg = abs((left + right)/2);
         
         %fprintf('avrage = %d\n',avg);
         
         dif = abs(prv - avg);
         %disp('nazmul in/out');
         
         if dif > mx
             pos2 = i-1;
             mx = dif;
         end
         
         prv = avg;
    end
    
    
   % mn_slp;
    
    disp('nazmul_end');
    
	%SOff = S(j, 1) + 2;
    SOff = pos1;
    %TOn = T(j, 1) - 11;
    TOn = pos2;
            
    ss = [ss; [SOff, ecg(SOff)]];
    tt = [tt; [TOn, ecg(TOn)]];      
end


figure;
subplot(2,1,1)
plot(1:length(ecg), ecg, 'b')
hold on
scatter(P(:, 1), P(:, 2), 'r', 'o')
scatter(Q(:, 1), Q(:, 2), 'r', 'o')
scatter(R(:, 1), R(:, 2), 'r', 'o')
scatter(S(:, 1), S(:, 2), 'r', 'o')
scatter(T(:, 1), T(:, 2), 'r', 'o')
scatter(ss(:, 1), ss(:, 2), 'm', '*')
scatter(tt(:, 1), tt(:, 2), 'g', '*')
legend('P', 'Q', 'R', 'S', 'T')
hold off
title('ECG with extracted P, Q, R, S, T peaks');


subplot(2,1,2)
plot(1:length(ecg), ecg, 'b')
hold on
scatter(ss(:, 1), ss(:, 2), 'm', '*')
scatter(tt(:, 1), tt(:, 2), 'r', 'o')
legend('ECG', 'S', 'T')
hold off
title('ECG with extracted ST Segment');


%{
subplot(2,1,2)
plot(st_elevation(:, 2), st_elevation(:, 1))
hold on
plot(ss(:, 1), ss(:, 2), 'r');
%plot(ss);
plot(tt(:, 1), tt(:, 2), 'g');
hold off
title('S and T amplitude');
xlabel('Nth ST-Segment in Original ECG');
ylabel('Elevation');
%}






