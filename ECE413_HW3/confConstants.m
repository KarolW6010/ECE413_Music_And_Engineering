% Configuration class for constants
classdef confConstants < handle
    properties
        % Defaults
        BufferSize                   = 882;                                                    % Samples
        SamplingRate                 = 44100;                                                  % Samples per Second
        QueueDuration                = 0.1;                                                    % Seconds - Sets the latency in the objects
        TimePerBuffer                                                                          % Computed in constructor
    end
    %properties (GetAccess = private)
    
    methods
        function obj = confConstants(varargin)
            if nargin > 0
                obj.currentTime=0;
                
                if nargin >= 3
                    obj.QueueDuration=varargin{3};
                end
                if nargin >= 2
                    obj.SamplingRate =varargin{2};
                end
                if nargin >=1
                    obj.BufferSize =varargin{1};
                end
            end
            TimePerBuffer                = obj.BufferSize / obj.SamplingRate;                              % Seconds;
            
            
        end
        
    end
    
    %methods (Access = protected)
    %function audio = stepImpl(~)
    methods
        function env = advance(obj)
            
        end
    end
end



