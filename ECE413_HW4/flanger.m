%{
Karol Wadolowski, Flanger

Takes the input vector and flanges it

Inputs:
    inp  : Input signal vector
    depth: How much of the modulated signal to add onto the original (0-1)
    delayTime : How long to delay the signal (sec)
    sweepDepth : How much the delay can vary
    LFOrate: LFO frequency
    LFOtype: Oscillator type
    

Outputs:
    out  : The delayed and fed back signal
%}

function out = flanger(inp,depth,delayTime,sweepDepth,LFOrate,LFOtype)
    fs = 44100;     %Sampling rate
    
    inp = inp/max(abs(inp));    %Normalize
    
    %Limit the values
    depth(depth > 1) = 1;
    depth(depth < 0) = 0;
    delayTime(delayTime < 1e-4) = 1e-4;
    delayTime(delayTime > 1e-2) = 1e-2;
    sweepDepth(sweepDepth < 1e-7) = 1e-7;
    sweepDepth(sweepDepth > 1e-2) = 1e-2;
    LFOrate(LFOrate > 5) = 5;
    LFOrate(LFOrate < 0.05) = 0.05;
    
    
    len = length(inp);
    time = 0:1/fs:((len-1)/fs-delayTime);
    time = [zeros(1,len-length(time)),time];
    
    %Select Oscillator Type
    switch LFOtype
        case {'sin'}
            %dT: Changing delay time
            dT = delayTime + sweepDepth*(1+sin(2*pi*LFOrate*time));     
        case {'triangle'}
            dT = delayTime + sweepDepth*(1+sawtooth(2*pi*LFOrate*time,1/2));
        otherwise
            error('Give valid oscillator type')
    end
    
    dTsamp = ceil(dT*fs);       %Delay time in samples
    
    out = zeros(1,len);
    %keyboard()
    for ii = 1:length(dTsamp)
        if(dTsamp(ii) >= ii)
            out(ii) = 0;
        else
            out(ii) = inp(ii-dTsamp(ii));
        end
    end
    
    out = inp + depth*out;
    out = out/max(abs(out));
end
















