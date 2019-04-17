%{
Karol Wadolowski, Stereo Tremolo

Takes the input vector and applies a tremolo effect to it.

Inputs:
    inp  : Input signal vector
    LFOtype : Type of oscillator (sin, triangle, or square)
    LFOrate : Frequency of LFO
    lag  : Lag time in ms between left and right modulating waveforms
    depth: How much of the modulated signal to add onto the original (0-1)

Outputs:
    out  : The tremeloed signal
%}

function out = stereoTremolo(inp, LFOtype, LFOrate, lag, depth)
    fs = 44100;                 %Sampling frequency
    inp = inp/max(abs(inp));    %Normalize input
    
    len = length(inp);          %Length of input vector
    time = 0:1/fs:((len-1)/fs-lag);
    time = [zeros(1,len - length(time)),time];
    
    %Limit the depth
    depth(depth>1) = 1;
    depth(depth<0) = 0;
    
    %Limit LFOrate
    LFOrate(LFOrate > 5) = 5;
    LFOrate(LFOrate < 0.05) = 0.05;
    
    %Select Oscillator Type
    switch LFOtype
        case {'sin'}
            lfo = sin(2*pi*LFOrate*time);
        case {'triangle'}
            lfo = sawtooth(2*pi*LFOrate*time,1/2);
        case {'square'}
            lfo = square(2*pi*LFOrate*time);
        otherwise
            error('Give valid oscillator type')
    end
    
    modded = inp.*lfo;
    
    out = inp + depth*modded;     %Add on the effect
    out = out/max(abs(out));        %Normalize
end



