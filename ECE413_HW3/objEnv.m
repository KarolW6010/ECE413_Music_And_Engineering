classdef objEnv < matlab.System
    % untitled4 Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.
    
    % Public, tunable properties
    properties
        % Defaults
        envParams                              = confEnv;
        constants                              = confConstants;
    end
    
    % Pre-computed constants
    properties(Access = private)
        % Private members
%         StartPoint;
%         ReleasePoint;
        currentTime;
        durationPerBuffer;
        
        attackInd
        releaseInd
        attackMaxInd
        decayMaxInd
        releaseMaxInd
        attackDecayWaveform
        releaseWaveform
        

%         AttackTime
%         DecayTime
%         SustainLevel
%         ReleaseTime
    end
    
    methods
        function obj = objEnv(varargin)
            %Constructor
            if nargin > 0
                setProperties(obj,nargin,varargin{:},...
                    'envParams','constants');
                
%                 obj.constants=varargin{7};
%                 obj.envParams.ReleaseTime=varargin{6};
%                 obj.envParams.SustainLevel=varargin{5};
%                 obj.envParams.DecayTime=varargin{4};
%                 obj.envParams.AttackTime=varargin{3};
%                 obj.envParams.ReleasePoint=varargin{2};
%                 obj.envParams.StartPoint=varargin{1};
                
            end
        end
    end
    
    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            
            obj.currentTime=0;
            obj.durationPerBuffer=obj.constants.BufferSize/obj.constants.SamplingRate;
            
            obj.attackInd=1;                        %Intialize indices for cases when buffer wraps
            obj.releaseInd=1;
            
            obj.attackMaxInd=ceil(obj.envParams.AttackTime.*obj.constants.SamplingRate);
            obj.decayMaxInd=ceil(obj.envParams.DecayTime.*obj.constants.SamplingRate);
            obj.releaseMaxInd=ceil(obj.envParams.ReleaseTime.*obj.constants.SamplingRate);
            
            obj.attackDecayWaveform=[linspace(obj.envParams.InitialLevel,obj.envParams.MaxLevel,obj.attackMaxInd),linspace(obj.envParams.MaxLevel,obj.envParams.SustainLevel,obj.decayMaxInd)];
            obj.releaseWaveform=linspace(obj.envParams.SustainLevel,obj.envParams.FinalLevel,obj.releaseMaxInd);
            
        end
        
        function env = stepImpl(obj)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            timeVec=(obj.currentTime+(0:(1/obj.constants.SamplingRate):((obj.constants.BufferSize-1)/obj.constants.SamplingRate))).';
            indVec=1:length(timeVec);
            noteTime=timeVec-obj.envParams.StartPoint;
            
            if all (timeVec < obj.envParams.StartPoint) % Note has not begun yet
                env=zeros(1,length(indVec));
                minLen=0;
            elseif all (timeVec < obj.envParams.ReleasePoint) % Note is still on
                if all(noteTime < (obj.envParams.AttackTime+obj.envParams.DecayTime))
                    % Fill from the buffer for the early part of the envelope
                    
                    startInd=min(find(timeVec >= obj.envParams.StartPoint));
                    minLen=obj.constants.BufferSize-startInd+1;
                    
                    env=[zeros(1,(startInd-1)) obj.attackDecayWaveform(obj.attackInd+(0:(minLen-1)))];
                    
                    obj.attackInd=obj.attackInd+minLen;
                elseif any(noteTime < (obj.envParams.AttackTime+obj.envParams.DecayTime))
                    % Fill from the transistion into the sustain portion
                    minLen=min(obj.constants.BufferSize,length(obj.attackDecayWaveform)-obj.attackInd);
                    env=[obj.attackDecayWaveform(obj.attackInd+(0:(minLen-1))) repmat(obj.envParams.SustainLevel,1,obj.constants.BufferSize-minLen)];
                    obj.attackInd=obj.attackInd+minLen;
                else
                    % Fill during the sustain portion
                    env=repmat(obj.envParams.SustainLevel,1,obj.constants.BufferSize);
                end
            elseif any(timeVec < obj.envParams.ReleasePoint)
                % end sustain and begin release
                releaseInd=max(timeVec < obj.envParams.ReleasePoint);
                minLen=min(obj.constants.BufferSize,length(obj.releaseWaveform)-obj.releaseInd);
                env=[repmat(obj.envParams.SustainLevel,1,releaseInd) obj.releaseWaveform(obj.releaseInd+1+(0:(minLen-1-releaseInd)))];
                obj.releaseInd=obj.releaseInd+minLen;
            elseif any(timeVec < (obj.envParams.ReleasePoint + obj.envParams.ReleaseTime))
                % finish release
                minLen=min(obj.constants.BufferSize,length(obj.releaseWaveform)-obj.releaseInd);
                env=[obj.releaseWaveform(obj.releaseInd+(0:(minLen-1))) zeros(1,obj.constants.BufferSize-minLen)];
                obj.releaseInd=obj.releaseInd+minLen;
            else % time vec is past end of note
                env=[];
                startInd=1;
                releaseInd=1;
            end
            
            
            if ~isempty(env) && length(env)~=obj.constants.BufferSize
                error('Improper Envelope Length!')
            end
            
            
            obj.currentTime=obj.currentTime+(obj.constants.BufferSize/obj.constants.SamplingRate);      % Advance the internal time
        end
        
        function resetImpl(obj)
            % Initialize / reset discrete-state properties
                        obj.currentTime=0;
            obj.durationPerBuffer=obj.constants.BufferSize/obj.constants.SamplingRate;
            
            obj.attackInd=1;                        %Intialize indices for cases when buffer wraps
            obj.releaseInd=1;
        end
    end
end
