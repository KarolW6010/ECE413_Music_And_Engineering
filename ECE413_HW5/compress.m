%{
Karol Wadolowski

Compresses the input signal based on the threshold supplied.

Inputs:
    inp : (1,?) Input signal
    thresh : (1,32) Thresholding values for the 32 subbands
    C : (1,512) C coefficients from MPEG standard
    D : (1,512) D coefficients from MPEG standard

Outputs:
    comp : (1,?) Compressed output signal
%}

function comp = compress(inp,thresh,C,D)
    sub = deconstruct(inp,C);               %Break the signal into 32 subbands
    
    percSub = perceptualModel(sub,thresh);  %Put subbands through perceptual model
    comp = reconstruct(percSub,D);          %Merge 32 subbands into 1 signal
end