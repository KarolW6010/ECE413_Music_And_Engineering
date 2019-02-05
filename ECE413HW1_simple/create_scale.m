function [soundOut] = create_scale( scaleType,temperament, root, constants )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%    [ soundOut ] = create_scale( scaleType,temperament, root, constants )
% 
% This function creates the sound output given the desired type of scale
%
% OUTPUTS
%   soundOut = The output sound vector
%
% INPUTS
%   scaleType = Must support 'Major' and 'Minor' at a minimum
%   temperament = may be 'just' or 'equal'
%   root = The Base frequeny (expressed as a letter followed by a number
%       where A4 = 440 (the A above middle C)
%       See http://en.wikipedia.org/wiki/Piano_key_frequencies for note
%       numbers and frequencies
%   constants = the constants structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants
tw = 2^(1/12);     %Twelfth root of two

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: Add all relavant constants 

%First row of freqRatios is for just, second row for equal temperament.
switch scaleType
    case {'Major','major','M','Maj','maj'}
	% TODO: Complete with interval pattern for the major scale
        freqRatios = [1, 9/8,  5/4,  4/3,  3/2,  5/3,  15/8,  2;
                      1, tw^2, tw^4, tw^5, tw^7, tw^9, tw^11, 2];  
    case {'Minor','minor','m','Min','min'}
	% TODO: Complete with interval pattern for the minor scale
        freqRatios = [1, 9/8,  6/5,  4/3,  3/2,  8/5,  9/5,   2;
                      1, tw^2, tw^3, tw^5, tw^7, tw^8, tw^10, 2]; 
    case {'Harmonic', 'harmonic', 'Harm', 'harm'}
	% EXTRA CREDIT
        freqRatios = [1, 9/8,  6/5,  4/3,  3/2,  8/5,  7/4,   2;
                      1, tw^2, tw^3, tw^5, tw^7, tw^8, tw^11, 2];
    case {'Melodic', 'melodic', 'Mel', 'mel'}
	% EXTRA CREDIT
        freqRatios = [1, 9/8,  6/5,  4/3,  3/2,  5/3,  9/5,   2;
                      1, tw^2, tw^3, tw^5, tw^7, tw^9, tw^11, 2];
    otherwise
        error('Improper scale specified');
end

%Select which row of freqRatios to use.
switch temperament
    case {'just','Just'}
	% TODO: Pull the Just tempered ratios based on the pattern from the scales
        row = 1;
    case {'equal','Equal'}
	% TODO: Pull the equal tempered ratios based on the pattern from the scales
        row = 2;
    otherwise
        error('Improper temperament specified')
end

switch root
    case {'A'}
        freq = 440;
    otherwise
        error('Improper root specified')
end


% Create the vector based on the notes
time = 0:1/constants.fs:(constants.durationScale-1/constants.fs);

%Reshaping here so that all the notes go one after the other.
soundOut = reshape(sin(2*pi*freq*freqRatios(row,:)'*time)',1,[]);

end
