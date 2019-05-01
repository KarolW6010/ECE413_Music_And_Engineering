%Karol Wadolowski, ECE-413 HW#5 - MPEG Audio Layer 1

clear;  clc;    close all;
load('CD.mat')      %Load C and D coefficients
load('PIB30.mat')   %Paint It, Black - The Rolling Stones (30 seconds)
load('P2.mat')      %Portal 2 OST - Music of the Spheres (30 seconds)

fs = 44100;         %Sampling frequency

%Thresholding coefficients
thLossLess = inf*ones(1,32);                                %LossLess
thresh = [5*ones(1,8),3*ones(1,8),2*ones(1,8),1*ones(1,8)]; %Lossy    

%% Paint It, Black
LL_PIB30 = compress(PIB30, thLossLess, C, D);   %Loss Less Compression
cPIB30 = compress(PIB30, thresh, C, D);         %Lossy Compression
fprintf('Paint it, Black\n')

%Plot spectrograms
figure('units','normalized','outerposition',[0 0 1 1])
sgtitle('Paint it, Black')
subplot(1,3,1)
spectrogram(PIB30, 1024, 'yaxis')
title('Original')

subplot(1,3,2)
spectrogram(LL_PIB30, 1024, 'yaxis')
title('Loss Less')

subplot(1,3,3)
spectrogram(cPIB30, 1024, 'yaxis')
title('Lossy')

%Play all three versions
fprintf('Playing Original\n')
soundsc(PIB30,fs)
pause(length(PIB30)/fs+1)

fprintf('Playing Lossless\n')
soundsc(LL_PIB30,fs)
pause(length(LL_PIB30)/fs+1)

fprintf('Playing Compressed\n\n')
soundsc(cPIB30,fs)
pause(length(cPIB30)/fs+1)

%% Portal 2 OST - Music of the Spheres
LL_P2 = compress(P2, thLossLess, C, D);     %Loss Less Compression
cP2 = compress(P2, thresh, C, D);            %Lossy Compression
fprintf('Portal 2 OST - Music of the Spheres\n')

%Plot spectrograms
figure('units','normalized','outerposition',[0 0 1 1])
sgtitle('Portal 2 OST - Music of the Spheres')
subplot(1,3,1)
spectrogram(P2, 1024, 'yaxis')
title('Original')

subplot(1,3,2)
spectrogram(LL_P2, 1024, 'yaxis')
title('Loss Less')

subplot(1,3,3)
spectrogram(cP2, 1024, 'yaxis')
title('Lossy')

%Play all three versions
fprintf('Playing Original\n')
soundsc(P2,fs)
pause(length(P2)/fs+1)

fprintf('Playing Lossless\n')
soundsc(LL_P2,fs)
pause(length(LL_P2)/fs+1)

fprintf('Playing Compressed')
soundsc(cP2,fs)
pause(length(cP2)/fs+1)



