%{
Karol Wadolowski

Given subband samples and D coefficients the signal is reconstructed.

Inputs:
    subSamps : (32,?) Subband samples
    D : D coefficients from standard

Outputs:
    out : (1,32*?) Reconstructed signal
%}

function out = reconstruct(subSamps, D)
    subSamps = [subSamps, zeros(32,15)];    %To preserve input and output lengths

    frames = size(subSamps,2);      %How many frames to reconstruct

    V = zeros(1,1024);          %V vector
    U = zeros(1,512);           %U vector
    out = zeros(1,32*frames);   %Reconstructed signal
    
    %Create Inverse MDCT matrix
    k = (0:63)';
    n = 0:31;
    iM = cos(pi*(k+16)*(2*n+1)/64);   %IMDCT matrix
    
    for kk = 1:frames
        V(1,65:end) = V(1,1:960);           %Shift out old values
        V(1:64) =(iM*subSamps(:,kk)).';     %SHift in new IMDCT values
        
        %Compute U values
        for ii = 0:7
            for jj = 0:31
                U(jj+64*ii+1) = V(jj+128*ii+1);
                U(jj+64*ii+32+1) = V(jj+128*ii+96+1);
            end
        end
        
        W = U.*D;               %Apply D
        
        x = zeros(1,32);        %32 output samples corresponding to subband snapshot
        for ii = 0:31
            for jj = 0:15
                x(ii+1) = x(ii+1) + W(ii+32*jj+1);
            end
        end
        
        out(32*(kk-1)+1:32*kk) = x;     %Output
    end
end



