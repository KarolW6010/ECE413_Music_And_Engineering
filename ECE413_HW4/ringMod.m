%{
Karol Wadolowski, Ring Modulator

Takes the input vector and applies a ring mod effect to it.

Inputs:
    inp  : Input signal vector
    freq : Frequency of modulating sine wave
    depth: How much of the modulated signal to add onto the original (0-1)

Outputs:
    out  : The ring modulated signal
%}

function out = ringMod(inp, freq, depth)
    fs = 44100;                 %Sampling frequency
    inp = inp/max(abs(inp));    %Normalize input
    
    len = length(inp);          %Get length of input signal
    
    time = 0:1/fs:((len-1)/fs);     %Time vector
    sine = sin(2*pi*freq*time);     %Modulating signal
    modded = inp.*sine;
    
    %Limit the depth
    depth(depth>1) = 1;
    depth(depth<0) = 0;
    
    out = inp + depth*modded;       %Add on the effect
    out = out/max(abs(out));        %Normalize
end