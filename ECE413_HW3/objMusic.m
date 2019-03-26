%{
Karol Wadolowski

Makes a objMusic object that holds tha array of notes.
Made so as to be compatible with your playAudio, objSynth, and objOsc
functions.
%}

classdef objMusic
    properties
        % These are the inputs that must be provided
        temperament                 = 'equal'                               % Default to equal temperament
        key                         = 'C'                                   % Default to key of C
        amplitude                   = 1                                     % Amplitude of the notes in the scale
        
        % Defaults
        tempo                       = 120                                   % Beats per minute
        noteDurationFraction        = 0.8                                   % Duration of the beat the note is played for 
        breathDurationFraction      = 0.2                                   % Duration pf the beat that is silent
        songNotes                   = [0,0,0];
        
        % Calculated
        secondsPerQuarterNote                                               % The number of seconds in a quarterNote
        noteDuration                                                        % Duration of the note portion in seconds
        breathDuration                                                      % Duration of the breath portion in seconds
        arrayNotes                  = objNote.empty;                        % Array of notes for the scale
    end
    
    methods
        function obj = objMusic(varargin)
            
            % Map the variable inputs to the class
            if nargin >= 4
                obj.songNotes = varargin{4};    %Sounds from midi file
            end
            if nargin >= 3
                obj.tempo=varargin{3};
            end
            if nargin >= 2
                obj.key=varargin{2};
            end
            if nargin >= 1
                obj.temperament=varargin{1};
            end
            
            
            % Compute some constants based on inputs
            obj.secondsPerQuarterNote       = 60/obj.tempo;                       
            obj.noteDuration                = obj.noteDurationFraction*obj.secondsPerQuarterNote;         % Duration of the note in seconds (1/4 note at 120BPM)
            obj.breathDuration              = obj.breathDurationFraction*obj.secondsPerQuarterNote;       % Duration between notes

            %Add the notes from the matrix into the array notes 
            amplitudeNote=obj.amplitude;
            for cnt=1:(size(obj.songNotes,1))
                obj.arrayNotes(cnt)=objNote(obj.songNotes(cnt,3),obj.temperament,obj.key,obj.songNotes(cnt,1),...
                    obj.songNotes(cnt,2),amplitudeNote);
            end
        end
    end
end
