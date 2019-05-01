%{
Karol Wadolowski

This function takes a signal and deconstructs it into 321 subbands

Inputs:
    x : (1x?) Input signal
    C : C coefficients from standard

Outputs:
    out : (32x?) Signal decomposed into 32 subbands
%}

function out = deconstruct(x, C)
    %Make sure the signal is at least 512 samples long and has length
    %divisible by 32.
    if(length(x) < 512)
        x = [x, zeros(1,512-mod(length(x),512))];
    else
        x = [x, zeros(1,32-mod(length(x),32))];
    end
    x = [x,zeros(1,512)];
    
    %Calculate the number of 512 block frames when shifting over 32 samples
    %each time.
    frames = floor((length(x)-512)/32)+1; 
    
    X = zeros(1,512);       %FIFO register index 1 is newest sample
    out = zeros(32,frames); %Subband Samples
    
    %Create the MDCT matrix
    k = 0:63;
    n = (0:31)';
    M = cos(pi*(2*n+1)*(k-16)/64);          %MDCT matrix
    
    for ii = 1:frames
        X(33:512) = X(1:480);                       %Push 32 samples out
        X(1:32) = fliplr(x((32*(ii-1)+1):(32*ii))); %Push 32 samples in
        
        Z = C.*X;                           %Window the FIFO entries
        Y = sum(reshape(Z,64,[]),2);        %Sum every 64th sample
        
        out(:,ii) = M*Y;                    %Perform MDCT to get subband samples
    end
end










