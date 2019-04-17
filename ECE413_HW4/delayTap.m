%{
Karol Wadolowski, Delay Tap

Takes the input vector and delays it, attenuates/amplifies it, and adds it 
back.

Inputs:
    inp  : Input signal vector
    depth: How much of the modulated signal to add onto the original (0-1)
    delayTime : How long to delay the signal (sec)
    fbGain : Feedback gain (linear)
    

Outputs:
    out  : The delayed and fed back signal
%}

function out = delayTap(inp,depth,delayTime,fbGain)
    fs = 44100;     %Sampling rate
    
    inp = inp/max(abs(inp));    %Normalize input
    
    %Limit the delay time
    delayTime(delayTime>8) = 8;
    delayTime(delayTime<1e-4) = 1e-4;
    
    dTsamp = round(delayTime*fs);   %Delay time in samples
    
    len = length(inp);
    inp = [inp,zeros(1,4*len)];
    out = zeros(1,5*len);
    
    out((dTsamp+1):(dTsamp+len)) = inp(1:len);      %First delayed copy
    
    for ii = (2*dTsamp+1):length(out)
        out(ii) = fbGain*out(ii-dTsamp) + out(ii);      %Feedback 
    end

    out = inp + depth*out;
    out = out/max(abs(out));        %Normalize
end




