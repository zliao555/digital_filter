% This file shows examples of using different methods to generated digital filters in the MCU.
% 1. using iirnotch to implement a 120 Hz notch filter
% 2. using iirpeak to implement a 120 Hz peak filter
% 3. defining a resonant controller transfer function manually and discretize 


clc
clear
close all
format long

%% iirnotch example 

fs = 150e3; % [Hz], sampled frequency of the adc, usually it's the switching frequency
wn = 120;%[Hz], center frequency, we want to filter out 120 Hz component

% bandwidth
Q = 5;  % Q factor to specify bandwidth. 
% while a low bandwidth, high Q notch filter can filter out the center
% frequency content much cleaner, in real implementation, it might be the
% case when the sensed signal have errors around the center frequency. say
% the center frequency is 120 Hz, the actual signal content might be 121 or
% 119 Hz. Lower Q, higher bandwidth can tolerate these errors and still filter the
% singal fairly well. Thus, Q should be tuned empirically.

% the following code is directly from matlab example
wo = wn/(fs/2); 
bw = wo/Q;   
[num,den] = iirnotch(wo, bw);
% once we obtained numerators and denominators, we can use the difference
% equation to implement in the mcu.

% plot the notch fitler transfer function
G_notch = tf(num,den,1/fs);


%           y(z)        b2*z^2 + b1*z + b0
% G_notch = ---- = ---------------------
%           x(z)        a2*z^2 + a1*z + a0


% difference equation format
% y(z)(a2*z^2+ a1*z + a0) = x(z)(b2*z^2 + b1*z + b0)
% y(n) + a1* y(n-1) + a0*y(n-2) = b2*x(n) + b1*x(n-1) + b2*x(n-2);
% the output is y(n)
% y(n) = b2*x(n) + b1*x(n-1) + b2*x(n-2) - (a1* y(n-1) + a0*y(n-2))

% num = [b2, b1, b0] den = [a2, a1, a0]
b2 = num(1)
b1 = num(2)
b0 = num(3)

a2 = den(1)
a1 = den(2)
a0 = den(3)



figure
bode_opts = bodeoptions;
bode_opts.FreqUnits = 'Hz';
bode_opts.Grid = 'on';
bode(G_notch, {2*pi*50 2*pi*1000}, bode_opts)  

%% iirpeak example

% iir peak filter does the opposite of the iir notch, it extracts the
% component at the center frequency
wn = 120;
Q = 5;
wo = wn/(fs/2); 
bw = wo/Q;   

[num1,den1] = iirpeak(wo, bw)
G_peak = tf(num1,den1,1/fs);
figure
bode(G_peak, {0 2*pi*1000}, bode_opts);  

%% second-order high pass filter
% a second-order high-pass fitler with 10 Hz corner frequency

s = tf ('s');
w = 2*pi*10; % the corner frequency is at 10 Hz

hpf = s^2/(s^2+10*s+w^2);

% use tustin method to discretize the tf and get the numerator and denominator
[num2,den2] = tfdata(c2d(hpf,1/fs,'tustin'));

% plot hpf
figure
bode(hpf, {0 2*pi*1000}, bode_opts);










