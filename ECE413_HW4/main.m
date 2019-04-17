%{
Karol Wadolowski, ECE413 HW#4 - Effects

This file runs all the effects and plays them. All the effects functions
are written in separate files.
%}

clear;  clc;    close all;
fs = 44100;         %Sampling rate
load 'bell.mat'     %Synthesized bell from HW#2
load 'roll.mat'     %From Rick Astley's 'Never Gonna Give You Up'
load 'echo.mat'     %Thats me
load 'drum.mat'     %From https://www.youtube.com/watch?v=zZbM9n9j3_g
bell = audioplayer(soundSample,fs);
rolled = audioplayer(roll,fs);
echoPl = audioplayer(echo,fs);
drumPl = audioplayer(drum,fs);

%% Number 1: Compression
threshold = .3;
slope = .1;
avLength = 5000;

time = 0:1/fs:3;
sig = sin(2*pi*400*time).*(square(2*pi*4*time)+1.1);
sig = sig/max(abs(sig));

[out,gain] = compressor(sig,threshold,slope,avLength);

%Play the original followed by the compressed
fprintf('Compressor\n')
fprintf('\tOriginal\n')
sigPl = audioplayer(sig,fs);
play(sigPl)
pause(length(sig)/fs+1);

fprintf('\tEffect\n\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(out)/fs+1);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(3,1,1)
plot(time,sig)
ylim([-1,1])
title('Original Signal')
xlabel('Time (s)')
ylabel('Amplitude')

subplot(3,1,2)
plot(time,out)
ylim([-1,1])
title('Compressed Signal')
xlabel('Time (s)')
ylabel('Amplitude')

subplot(3,1,3)
plot(time,gain)
ylim([0,1])
title('Gain Applied')
xlabel('Time (s)')
ylabel('Gain (linear)')

%% Number 2: Ring Modulator
modFreq = 1000;        %Modulation Frequency
depth = 1;             %Modulation Depth

out = ringMod(roll, modFreq, depth);     %Apply Ring Mod Effect

%Play the original followed by the one with ring mod
fprintf('Ring Modulator\n')
fprintf('\tOriginal\n')
play(rolled)
pause(length(roll)/fs+1);

fprintf('\tEffect\n\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(out)/fs+1);

%% Number 3: Stereo Tremolo
LFOtype = 'sin';        %Low Frequency Oscillator Waveform
LFOrate = 5;            %LFO frequency
lag = .01;              %Lag
depth = .8;             %Modulation Depth

out = stereoTremolo(soundSample, LFOtype, LFOrate, lag, depth);

%Play the original followed by the one with tremolo
fprintf('Stereo Tremolo\n')
fprintf('\tOriginal\n')
play(bell)
pause(length(soundSample)/fs+1);

fprintf('\tEffect\n\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(out)/fs+1);

%% Number 4: Distortion
%Plot the waveform of the waveshaper used for distortion/clipping
x = linspace(-4,4,1000);
clipped = x;
clipped = (clipped < -2)*-1 + ...
              (-2 <= clipped & clipped < -1).*(-clipped-3) + ...
              (-1 <= clipped & clipped < 1)*2.*clipped + ...
              (1 <= clipped & clipped < 2).*(-clipped+3) + ...
              (2 <= clipped)*1;
figure
plot(x,clipped)
title('Clipper')
xlabel('Input Level')
ylabel('Output Level')

gain = 10;
tone = .4;

%Play the original sample followed by the distorted
out = distortion(soundSample, gain, tone);
fprintf('Distortion\n')
fprintf('\tOriginal\n')
play(bell)
pause(length(soundSample)/fs+1)

fprintf('\tEffect\n\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(out)/fs+1);

%Plot the output for various amounts of gain
gain = 2:6:20;
tone = 1;
figure('units','normalized','outerposition',[0 0 1 1])
for ii = 1:length(gain)
    out = distortion(soundSample, gain(ii), tone);
    
    subplot(2,2,ii)
    spectrogram(out)
    str = sprintf('Gain of %.0d',gain(ii));
    title(str)
end
sgtitle('Spectrogram of Output Signal for Various Gain Values')

%% Number 5: Single Tap Delay
%A: Slapback---------------------------------------------------------------
depth = .3;
delayTime = .35;
fbGain = 0;
out = delayTap(drum,depth,delayTime,fbGain);

%Play the original followed by the 'giant cavern' delay
fprintf('Single Tap Delay\n')
fprintf('\tOriginal: Slapback\n')
play(drumPl)
pause(length(drum)/fs+1);

fprintf('\tDelay: Slapback\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(drum)/fs+1+delayTime);

%B: Giant Cavern-----------------------------------------------------------
depth = .9;
delayTime = .5;
fbGain = .5;
out = delayTap(echo,depth,delayTime,fbGain);

%Play the original followed by the 'giant cavern' delay
fprintf('\tOriginal: Giant Cavern\n')
play(echoPl)
pause(length(echo)/fs+1);

fprintf('\tDelay: Giant Cavern\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(out)/fs+1);

%C: Delayed Tempo----------------------------------------------------------
depth = .9;
delayTime = .45;
fbGain = .5;
out = delayTap(drum,depth,delayTime,fbGain);

%Play the original followed by the 'giant cavern' delay
fprintf('\tOriginal: Delayed Tempo\n')
play(drumPl)
pause(length(drum)/fs+1);

fprintf('\tDelay: Delayed Tempo\n\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(out)/(4*fs)+1);

%% Number 6: Flanger
depth = 1;
delayTime = .1;
sweepDepth = .01;
LFOrate = 5; 
LFOtype = 'triangle';

out = flanger(drum,depth,delayTime,sweepDepth,LFOrate,LFOtype);

%Play the original followed by the flanger
fprintf('Flanger\n')
fprintf('\tOriginal\n')
%play(drumPl)
%pause(length(drum)/fs+1);

fprintf('\tEffect\n\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(out)/(fs)+1);


%% Number 7: Chorus
depth = 1;
delayTime = .05;
sweepDepth = .001;
LFOrate = 5; 
LFOtype = 'triangle';

out = flanger(roll,depth,delayTime,sweepDepth,LFOrate,LFOtype);

%Play the original followed by the chorus
fprintf('Chorus\n')
fprintf('\tOriginal\n')
play(rolled)
pause(length(roll)/fs+1);

fprintf('\tEffect\n\n')
temp = audioplayer(out,fs);
play(temp)
pause(length(out)/(fs)+1);




