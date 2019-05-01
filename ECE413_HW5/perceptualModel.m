%{
Karol Wadolowski

Takes the 32 subband channels and a threshold for each channel and
compresses samples.

Inputs:
    subSamps : (32,?) Subband samples
    threshold: (1,32) Threshold for the 32 subbands

Outputs:
    comp : (32,?) Compressed subband samples according to my perceptual
    model
%}

function comp = perceptualModel(subSamps,thresh)
    %Make subSamps have a full 12 samples each time
    subSamps = [subSamps, zeros(32,12-mod(size(subSamps,2),12))];  
    comp = zeros(size(subSamps));       %Compressed subband samples
    
    %Apply my perceptual model
    for ii = 1:size(subSamps,2)/12
        for jj = 1:32
            temp = subSamps(jj,12*(ii-1)+1:12*ii);      %Get 12 samples from one subband
            temp = 20*log10(abs(temp));                 %Power of the samples
            
            m = max(temp);                      %Find maximum power among the samples
            
            %Keep samples that are within the threshold of the max power.
            %Zero out if not within the threshold.
            mask = (temp > (m-thresh(jj)));     
            comp(jj,12*(ii-1)+1:12*ii) = subSamps(jj,12*(ii-1)+1:12*ii).*mask;
        end
    end
end