classdef objOsc < matlab.System
    % untitled2 Add summary here
    %
    % This template includes the minimum set of functions required
    % to define a System object with discrete state.

    % Public, tunable properties
    properties
        % Defaults
        note                        = objNote;
        oscConfig                   = confOsc;
        constants                   = confConstants;
    end

    % Pre-computed constants
    properties(Access = private)
        % Private members
        currentTime;
        EnvGen                = objEnv;
    end
    
    methods
        function obj = objOsc(varargin)
            %Constructor
            if nargin > 0
                setProperties(obj,nargin,varargin{:},'note','oscConfig','constants');
                
                tmpEnv=confEnv(obj.note.startTime,obj.note.endTime,...
                    obj.oscConfig.oscAmpEnv.AttackTime,...
                    obj.oscConfig.oscAmpEnv.DecayTime,...
                    obj.oscConfig.oscAmpEnv.SustainLevel,...
                    obj.oscConfig.oscAmpEnv.ReleaseTime);
                obj.EnvGen=objEnv(tmpEnv,obj.constants);
            end
            %keyboard()
        end
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            
            % Reset the time function
            obj.currentTime=0;
        end

        function audio = stepImpl(obj)
%             obj.EnvGen.StartPoint=obj.note.startTime;   % set the end point again in case it has changed
%             obj.EnvGen.ReleasePoint=obj.note.endTime;   % set the end point again in case it has changed
            
            timeVec=(obj.currentTime+(0:(1/obj.constants.SamplingRate):((obj.constants.BufferSize-1)/obj.constants.SamplingRate))).';
            noteTime=timeVec-obj.note.startTime;
            
            %mask = obj.EnvGen.advance;
            mask = step(obj.EnvGen);
            if isempty(mask)
                audio=[];
            else
                if all (mask == 0)
                    audio = zeros(1,obj.constants.BufferSize).';
                else
                    %Switch case added so that more oscillator types can be
                    %used.
                    switch obj.oscConfig.oscType
                        case {'sine'}
                            audio=obj.note.amplitude.*mask(:).*sin(2*pi*obj.note.frequency*timeVec);
                        case {'SUB'}        %Suvtractive synth
                            theta = linspace(pi,0,length(timeVec));         %Angle of conjugate poles
                            amps = obj.note.amplitude*abs(exp(2*1j*theta)-2*obj.oscConfig.oscRadius*cos(theta).*exp(1j*theta)+obj.oscConfig.oscRadius^2);   %Amplitude scaling factor
                            sq = square(obj.note.frequency*timeVec);   %Square wave at specified frequency
                            
                            audio = zeros(length(timeVec),1);        
                            %Apply difference equation
                            %y[n] = amps[n]x[n] - 2rcos(th[n])y[n-1] -r^2)y[n-2]
                            audio(1) = sum(amps(1)*sq(1));
                            audio(2) = sum(amps(2)*sq(2) -2*obj.oscConfig.oscRadius*cos(theta(2))*audio(:,1));

                            for ii = 3:length(timeVec)
                                audio(ii) = amps(ii)*sq(ii) -2*obj.oscConfig.oscRadius*cos(theta(ii))*audio(ii-1) - (obj.oscConfig.oscRadius^2)*audio(ii-2);
                            end
                            %keyboard()
                            audio=obj.note.amplitude.*mask(:).*square(2*pi*obj.note.frequency*timeVec);
                        
                        case {'FM'}     %Frequency Modulation
                            IMAX = 10;
                            fm = obj.note.frequency*7/5;        %Modulating freq
                            dur = (obj.constants.BufferSize-1)/obj.constants.SamplingRate; %Duration
                            s1 = obj.note.amplitude.*2.^(-10*(1/(dur))*(timeVec-obj.currentTime));
                            
                            s2 = fm*IMAX*2.^(-10*(1/(dur))*(timeVec-obj.currentTime));
                            s2 = s2.*sin(2*pi*fm*timeVec);
                            s2 = s2 + sin(2*pi*obj.note.frequency*(timeVec-obj.currentTime));
                            
                            audio = s1.*s2.*mask(:);
                            %keyboard()
                            
                        case {'ADD'}
                            %Bell from Jerse Fig 4.28
                            amps = obj.note.amplitude.*[1,.67,1,1.8,2.67,1.67,1.46,1.33,1.33,1,1.33];   %Amplitudes
                            durs = ((obj.constants.BufferSize-1)/obj.constants.SamplingRate)*...
                                [1,.9,.65,.55,.325,.35,.25,.2,.15,.1,.075];         %Durations
                            rs = obj.note.frequency*([.56,.56,.92,.92,1.19,1.7,2,2.74,3,3.76,4.07] + ...
                                [0,1,0,1.7,0,0,0,0,0,0,0]);                         %Frequencies
                            f2s = 2.^(-10*(timeVec-obj.currentTime)*(1./(durs)));            %Waveform Envelope

                            env = repmat(amps,length(timeVec),1).*f2s;   %Envelope scaled by amplitudes
                            
                            audio = sum(sin(2*pi*timeVec*rs).*env,2).*mask(:);
                            
                        case {'WS'}
                            amp = obj.note.amplitude;
                            dur = ((obj.constants.BufferSize-1)/obj.constants.SamplingRate);
                            rise = round(dur*.085/4*obj.constants.SamplingRate);    %Index of last rise time
                            decay = round(dur*(4-.64)/4*obj.constants.SamplingRate);  %Index of first decay time

                            %Envelope (Rise, Sustain, Decay)
                            env = [linspace(0,255,rise),255*ones(1,decay-rise-1),linspace(255,0,length(timeVec)-decay+1)];

                            s1 = env'.*sin(2*pi*obj.note.frequency*timeVec);
                            %Put the signal throught the F(x) function
                            F1 = (s1<200).*(s1/400-1);
                            F2 = (200<=s1 & s1<=312).*(s1/112-32/14);
                            F3 = (312<s1).*(s1/398 + 1/2-312/398);

                            audio = amp*(F1+F2+F3).*mask(:);
                            
                        otherwise
                            error('Not a valid oscillator type')
                    end
                        
                end
            end
            obj.currentTime=obj.currentTime+(obj.constants.BufferSize/obj.constants.SamplingRate);      % Advance the internal time

        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            % Reset the time function
            obj.currentTime=0;
        end
    end
end
