[fname path]=uigetfile('*.mat');
fname=strcat(path,fname);
load(fname);

x = val(1, :);
z=zeros(1, 200);
x=[z,x,z];

[c, l] = wavedec(x, 4, 'db4');       
app1 = appcoef(c, l, 'db4', 1);  
app2 = appcoef(c, l, 'db4', 2); 

Fs = 250/4;

x=app2;

Wn = 0.01;                 
a = 1;                     
b = fir1(200, Wn, 'low');  
fir_x = filter(b, a, x);

med1_x = medfilt1(fir_x, 3, round(Fs*(2/10)));
med2_x = medfilt1(med1_x, 3, round(Fs/4*(6/10)));

offset = 100;
base = [med2_x(offset + 1:length(med2_x)) med2_x(length(med2_x) - offset + 1:length(med2_x))];
bc_sig = x - base;

subplot(2, 1, 1)
plot(x)
hold on
plot(base, 'red', 'LineWidth', 3)
hold off
legend('RAW ECG', 'Base Line')
title('Wandering Baseline')

subplot(2, 1, 2)
plot(bc_sig)
title('Baseline Corrected Signal')

