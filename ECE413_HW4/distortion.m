%{
Karol Wadolowski, Ring Modulator

Takes the input vector and adds distortion to it

Inputs:
    inp  : Input signal vector
    gain : Gain (linear) to add before clipping
    tone : Filters the clipped signal

Outputs:
    out  : The distorted signal
%}

function out = distortion(inp, gain, tone)
    inp = inp/max(abs(inp));    %Normalize input
    
    %Custom clipping shape
    clipped = gain*inp;
    clipped = (clipped < -2)*-1 + ...
              (-2 <= clipped & clipped < -1).*(-clipped-3) + ...
              (-1 <= clipped & clipped < 1)*2.*clipped + ...
              (1 <= clipped & clipped < 2).*(-clipped+3) + ...
              (2 <= clipped)*1;
    
    %Limit the tone
    tone(tone>1) = 1;
    tone(tone<0) = 0;
    
    %My failed attempt at a good low pass filter commented out below :(
    %{
    c = 1 - tone;
    d = .000;          %delta
    out = zeros(1,length(inp));
    out(1) = (1-c+d)*inp(1);
    for ii = 2:length(out)
        out(ii) = (1-c+d)*inp(ii) + c*out(ii-1);
    end
    %}
    fpass = 22000*tone;
    out = lowpass(clipped,fpass,44100);    %Low pass filter the clipped signal
end