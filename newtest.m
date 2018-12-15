[x,Fs] = audioread('audioshort.wav');
x = x(:, 1);
x = x(1:160000, 1); %cutting audio short
c = 340;                    % Sound velocity (m/s)
fs = 16000;                 % Sample frequency (samples/s)
r = [9 9 9];                % Receiver position [x y z] (m)
s = [9 7 4];                % Source position [x y z] (m)
L = [10 10 10];             % Room dimensions [x y z] (m)
beta = 0.4;                 % Reverberation time (s)
n = 512;                    % Number of samples
SNR = 100;%high SNR
h = rir_generator(c, fs, r, s, L, beta, n);
h = h';
hnoise = awgn(h, 100)-h;
sigp2 = 10*log10(norm(hnoise,2)^2/numel(hnoise));
snr2 = sigp2-100;
sigma2w = 10^(snr2/10);
h = h + hnoise;
y=conv(x,h);
ynoise=awgn(y,SNR);
v=ynoise-y;
sigp1 = 10*log10(norm(v,2)^2/numel(v));
snr1 = sigp1-SNR;
sigma2v = 10^(snr1/10);
y = ynoise;
H=zeros(n, 1);
epsilon=1e-10;%using very low epsilon
index=1;
Xsize=size(x, 1);
Ru=epsilon*eye(n);
threshlow = 1e-5;
%sigma2v = 1e-13;
%sigma2w = 1e-13;
while index < Xsize - n
    if(mod(index, 1000)==0)
        h = awgn(h, SNR);
        y = conv(x, h);
        y = awgn(y, SNR);
        Ru = epsilon*eye(n);
        index  = 1;
    end
    xf = splitv(x, index, n);%changed xf
    Rm = Ru + sigma2w*eye(n);
    sigma2e = xf'*Rm*xf + sigma2v;
    K = Rm*xf/sigma2e;%changed calculation of kalman gain
    e = y(index) - xf'*H;%changed from conc to this
    H = H + K*e;
    Ru = (eye(n) - K*xf')*Rm;
    index=index+1;
    clc;
    norm(h-flipud(H))/norm(h)*100
    index
end   