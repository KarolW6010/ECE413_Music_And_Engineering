function [soundOut] = create_chord( chordType,temperament, root, constants )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%    [ soundOut ] = create_scale( chordType,temperament, root, constants )
% 
% This function creates the sound output given the desired type of chord
%
% OUTPUTS
%   soundOut = The output sound vector
%
% INPUTS
%   chordType = Must support 'Major' and 'Minor' at a minimum
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

%First row of freqRatios is for just, second row for equal temperament.
switch chordType
    case {'Major','major','M','Maj','maj'}
        freqRatios = [1, 5/4,  3/2;
                      1, tw^4, tw^7];
    case {'Minor','minor','m','Min','min'}
        freqRatios = [1, 6/5,  3/2;
                      1, tw^3, tw^7];
    case {'Power','power','pow'}
        freqRatios = [1, 3/2;
                      1, tw^7];
    case {'Sus2','sus2','s2','S2'}
        freqRatios = [1, 9/8,  3/2;
                      1, tw^2, tw^7];
    case {'Sus4','sus4','s4','S4'}
        freqRatios = [1, 4/3,  3/2;
                      1, tw^5, tw^7];
    case {'Dom7','dom7','Dominant7', '7'}
        freqRatios = [1, 5/4,  3/2,  9/5;
                      1, tw^4, tw^7, tw^10];
    case {'Min7','min7','Minor7', 'm7'}
        freqRatios = [1, 6/5,  3/2,  9/5;
                      1, tw^3, tw^7, tw^10];
    otherwise
        error('Inproper chord specified');
end

%Select which row of freqRatios to use.
switch temperament
    case {'just','Just'}
        row = 1;
    case {'equal','Equal'}
        row = 2;
    otherwise
        error('Inproper temperament specified')
end

switch root
    case {'A'}
        freq = 440;
    otherwise
        error('Improper root specified')
end

% Complete with chord vectors
% Create the vector based on the notes
time = 0:1/constants.fs:(constants.durationChord-1/constants.fs);
soundOut = sum(sin(2*pi*freq*freqRatios(row,:)'*time));
end
