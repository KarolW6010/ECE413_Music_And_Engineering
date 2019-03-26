% Synthesize single note

%classdef objSynthSineNote < matlab.System
classdef confEnv < handle
    properties
        % Defaults
        StartPoint                                  = 0;    % Starting point for the envelope 
        ReleasePoint                                = Inf   % Time to release the note 
        AttackTime                                  = .01;  %Attack time in seconds
        InitialLevel                                = 0;    % Level before Attack begins.   Should be zero for amplitude may be something else depending on usage (filter / frequency)
        DecayTime                                   = .05;  % Decay time in seconds
        MaxLevel                                    = 1;    % Level at the furthest point.  Where the Attack changes to Decay - should be zero for amplitude functions
        SustainLevel                                = 0.7;  % Sustain level (1 being max)
        ReleaseTime                                 = .03;  % Time to release from sustain to zero
        FinalLevel                                  = 0;    % Level at the end of the release begins.   Should be zero for amplitude may be something else depending on usage (filter / frequency)
    end
    %properties (GetAccess = private)
    
    methods
        function obj = confEnv(varargin)
            if nargin > 0
                
                if nargin >= 6
                    obj.ReleaseTime=varargin{6};
                end
                if nargin >= 5
                    obj.SustainLevel=varargin{5};
                end
                if nargin >= 4
                    obj.DecayTime=varargin{4};
                end
                if nargin >= 3
                    obj.AttackTime=varargin{3};
                end
                if nargin >= 2
                    obj.ReleasePoint=varargin{2};
                end
                if nargin >=1
                    obj.StartPoint=varargin{1};
                end
                
            end

        end
        
    end
    
    %methods (Access = protected)
    %function audio = stepImpl(~)
    methods
        function env = advance(obj)
            
        end
    end
end



