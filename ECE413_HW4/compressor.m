%{
Karol Wadolowski, Compression

Takes the input vector and compresses it.

Inputs:
    inp  : Input signal vector
    threshold: Where in range to change gain.
    slope: Applied value to signals with power above threshold (<1)
    avLength: Power averaged over this many samples
    

Outputs:
    out  : The compressed signal
    gain : The gain applied at each time to the signal
%}

function [out,gain] = compressor(inp,threshold,slope,avLength)
    fs = 44100;     %Sampling rate
   
    inp = inp/max(abs(inp));    %Normalize input
    
    len = length(inp);      %Length of input vector;
    gain = ones(1,len);     %Gain in linear of the compressed signal
    
    %Limit the inputs
    slope(slope>=1) = .99999;
    threshold(threshold>1) = 1;
    threshold(threshold<0) = 0;
    
    if(avLength > len)
        avLength = len;
    end
    avLength(avLength <= 1) = 2;
    
    %Make avLengths even for convenience
    if(mod(avLength,2)==1)
        avLength = avLength - 1;
    end
    
    startInd = 1;                       %Start averaging
    endInd = startInd + avLength -1;    %End averaging
    
    startGain = (endInd - startInd + 1)/2;      %Apply gain starting here
    endGain = startGain + avLength;             %Apply gain ending here
    
    out = inp;
    while(startInd <= len)
        if (endInd <= len)  %Full averaging window
            avgPwr = mean(out(startInd:endInd).^2);    %Average Power of the input
            
            if (avgPwr > threshold)
                %Find indices to compress 
                if(endGain <= len)
                    inds = startGain:endGain;
                else
                    inds = startGain:len;
                end
                %Add exponential decay in gain
                x = linspace(0,avLength,length(inds));
                x = exp(x*log(slope)/avLength);
               % keyboard()
                %Update output and gain
                out(inds) = out(inds).*x;
                gain(inds) = gain(inds).*x;
                        
            end
            
            %Update averaging and gain window indices
            startInd = startInd + avLength/2;
            endInd = startInd + avLength - 1;
            startGain = avLength/2 + startInd;  
            endGain = startGain + avLength;            
            
        else                %Not full averaging window
            avgPwr = mean(out(startInd:end).^2);       %Average Power of the input
            if (avgPwr > threshold)
                %Find indices to compress 
                if(startGain <= len)
                    inds = startGain:len;
                else
                    inds = [];
                end
                out(inds) = slope*out(inds);    %Decrease power
                gain(inds) = slope*gain(inds);  %Record gain value          
            end 
            startInd = len + 1;
        end
    end
end



