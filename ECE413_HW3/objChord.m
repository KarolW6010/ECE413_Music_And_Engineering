% First draft a Scale Object

classdef objChord
    properties
        % These are the inputs that must be provided
        chordType                                                           % major or minor
        startingNoteNumber                                                  % MIDI note number
        temperament                 = 'equal'                               % Default to equal temperament
        key                         = 'C'                                   % Default to key of C
        amplitude                   = 1                                     % amplitude of the whole chord
        
        % Defaults
        tempo                       = 120                                   % Beats per minute
        noteDurationFraction        = 2.8                                  % Duration of the beat the note is played for 
        breathDurationFraction      = 0.2                                   % Duration pf the beat that is silent
        
        % Calculated
        secondsPerQuarterNote                                               % The number of seconds in a quarterNote
        noteDuration                                                        % Duration of the note portion in seconds
        breathDuration                                                      % Duration of the breath portion in seconds
        arrayNotes                  = objNote.empty;                   % Array of notes for the scale
    end
    
    properties (Constant = true, GetAccess = private)
        % Constants
        majOffsets=[4 3];                                         % Half steps between notes in the major scale
        minOffsets=[3 4];                                         % Half steps between notes in the minor scale
    end
    methods
        function obj = objChord(varargin)
            
            % Map the variable inputs to the class
            if nargin >= 5
                obj.tempo=varargin{5};
            end
            if nargin >= 4
                obj.key=varargin{4};
            end
            if nargin >= 3
                obj.temperament=varargin{3};
            end

            obj.startingNoteNumber=varargin{2};
            obj.chordType=varargin{1};    
            
            % Compute some constants based on inputs
            obj.secondsPerQuarterNote       = 60/obj.tempo;                       
            obj.noteDuration                = obj.noteDurationFraction*obj.secondsPerQuarterNote;         % Duration of the note in seconds (1/4 note at 120BPM)
            obj.breathDuration              = obj.breathDurationFraction*obj.secondsPerQuarterNote;         % Duration between notes
            
            % Select the pattern between notes based on the scale selected
            switch obj.chordType
                case {'major','Major'}
                    offsets=obj.majOffsets;
                case {'minor','Minor'}
                    offsets=obj.minOffsets;
                otherwise
                    error('Scale not defined');
            end
            
            % Walk through the offsets and build the scale
            currentNoteNumber=obj.startingNoteNumber;
            startTime=0;
            endTime=obj.noteDuration;
            amplitudeNote=obj.amplitude./(length(offsets)+1);
            for cnt=1:(length(offsets)+1)
                obj.arrayNotes(cnt)=objNote(currentNoteNumber,obj.temperament,obj.key,startTime,endTime,amplitudeNote);
                
                if cnt <= length(offsets)
                    currentNoteNumber=currentNoteNumber+offsets(cnt);
                end
                
            end
        end
    end
end
