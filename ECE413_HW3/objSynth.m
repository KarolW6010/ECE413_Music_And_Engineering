classdef objSynth < matlab.System
    % untitled Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.
    
    % Public, tunable properties
    properties
        notes;
        oscConfig                   = confOsc;
        constants                   = confConstants;
    end
    
    % Pre-computed constants
    properties(Access = private)
        currentTime;
%         arrayNotes                  = objNote.empty(8,0);
%         arraySynths                 = objOsc.empty(8,0);
        arrayNotes                  = objNote;
        arraySynths                 = {objOsc};

    end
    
    methods
        function obj = objSynth(varargin)
            %Constructor
            setProperties(obj,nargin,varargin{:},'notes','oscConfig','constants');
            obj.arrayNotes=obj.notes.arrayNotes;
            
            for cntNote=1:length(obj.arrayNotes)
                if (size(obj.oscConfig.oscTypes,2) ~= 0)
                    temp = string(obj.oscConfig.oscTypes(cntNote));
                    obj.oscConfig.oscType = temp;
                end
                
                obj.arraySynths{cntNote}=objOsc(obj.arrayNotes(cntNote),obj.oscConfig,obj.constants);
            end
            %keyboard()
        end
    end
    
    
    methods(Access = protected)
        
        
%         function validateInputsImpl(~,notes,oscConfig,constants)
%             keyboard
%             if ~isprop(notes,'arrayNotes')
%                 error('Invalid Notes Function')
%             end
%             if ~isobject(oscConfig)
%                 error('oscConfig must be an object');
%             end
%             if ~isobject(constants)
%                 error('constants must be an object');
%             end
%         end

        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants

            % Reset the time function
            obj.currentTime=0;
            
        end
        
        function audioAccumulator = stepImpl(obj)
            % Implement algorithm.
            audioAccumulator=[];
            for cntNote = 1:length(obj.arrayNotes)
                
                %audio = obj.arraySynths(cntNote).advance;
                audio = step(obj.arraySynths{cntNote});
                
                %audio = step(obj.arraySynths(cntNote));
                if ~isempty(audio)
                    if isempty(audioAccumulator)
                        audioAccumulator=audio;
                    else
                        audioAccumulator=audioAccumulator+audio;
                    end
                end
                
            end

        end
        
        function resetImpl(obj)
            % Reset the time function
            obj.currentTime=0;
        end
    end
end
