% First draft a Note Object

classdef objNote
    properties
        % Must be provided
        noteNumber                                                          % Note number in MIDI in string
        temperament                                                         % just or equal
        key                                                                 % Required for Just temperament
        startTime                                                           % Start of the NOte
        endTime                                                             % End time stamp of the note
        amplitude         = 1                                               % amplitude 
        
        % Calculated
        frequency                                                           % Derived from note and temperament
        octave                                                              % Derived from noteNumber
        noteName                                                            % Derived from note Number
    end
    
    properties (Constant = true, GetAccess = private)
        % Constants
        refFreq           = 440       % Reference to 440 Hz
        refNote           = 69        % Reference for A==440;
        noteNameList      = {'C','C#','D','D#','E','F','F#','G','G#','A','A#','B';
            'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'};  % First row is for sharp keys, second for flat keys
        %justOffSetCents   = [0 m2 M2 m3 M3 p4 d5 p5 m6 M6 m7 M7]
        justOffsetCents   =  [0 12 4 16 -14 -2 10 2 14 -16 17 -12];
        justKeyRef        = [60:71;60:71]-60;
    end
    methods
        function obj = objNote(noteNumber,temperament,key,startTime,endTime,amplitude)
            if nargin >= 5
                % Only create a non-empty object if the number of inputs is
                % correct
                
                obj.noteNumber=noteNumber;
                obj.key=key;
                obj.startTime=startTime;
                obj.endTime=endTime;
                obj.amplitude=amplitude;
                
                freqDiff=obj.noteNumber - 69; 
                obj.octave=floor(obj.noteNumber/12)-1;
                noteOffset=rem(noteNumber,12)+1;
                
                switch temperament
                    % MIDI 69 = 440Hz
                    % Compute the offset from 440 Hz
                    case {'just','Just','JUST','j','J'}
                        obj.temperament='just';
                        
                        keyDiffInd = find(strcmp(obj.noteNameList, obj.key));
                        
                        tmpInd=1+mod(obj.noteNumber-obj.justKeyRef(min(keyDiffInd)),12);
                        offsetCents=obj.justOffsetCents(tmpInd);
                        
                        freqAdjust=2.^(offsetCents/1200);
                        
                        obj.frequency=obj.refFreq.*2.^(freqDiff/12)*freqAdjust;
                        
                    case {'equal','Equal','EQUAL','e','E'}
                        obj.temperament='equal';
                        
                        obj.frequency=obj.refFreq.*2.^(freqDiff/12);
                        
                        
                    otherwise
                        error('invalid temperament')
                        
                        switch obj.key
                            case {'C','G','D','A','E','B','F#','C#',}
                                obj.noteName=[obj.noteNameList{1,noteOffset} num2str(obj.octave)];
                            case {'F','Bb','Eb','Ab','Db','Gb','Cb','Fb'}
                                obj.noteName=[obj.noteNameList{2,noteOffset} num2str(obj.octave)];
                            otherwise
                                error ('invalid key');
                        end
                end
            end
        end
    end
end
