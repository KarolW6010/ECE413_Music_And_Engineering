%{
Karol Wadolowski

This file plays the three MIDI files that you supplied to us.
%}
clc; clear; close all;

% PROGRAM CONSTANTS
constants                              = confConstants;
constants.BufferSize                   = 882;                                                    % Samples
constants.SamplingRate                 = 44100;                                                  % Samples per Second
constants.QueueDuration                = 0.1;                                                    % Seconds - Sets the latency in the objects
constants.TimePerBuffer                = constants.BufferSize / constants.SamplingRate;          % Seconds;

oscParams                              = confOsc;
oscParams.oscType                      = 'sine';
oscParams.oscAmpEnv.StartPoint         = 0;
oscParams.oscAmpEnv.ReleasePoint       = Inf;  % Time to release the note
oscParams.oscAmpEnv.AttackTime         = .02;  % Attack time in seconds
oscParams.oscAmpEnv.DecayTime          = .01;  % Decay time in seconds
oscParams.oscAmpEnv.SustainLevel       = 0.7;  % Sustain level
oscParams.oscAmpEnv.ReleaseTime        = .05;  % Time to release from sustain to zero

%My additions
oscParams.oscRadius                    = .99;   % Subtractive synth pole radius

oscillTypes = {'SUB','SUB','FM'};
playMIDI('ROW.mid',oscParams,constants,1,oscillTypes)

oscillTypes = {'WS','SUB','FM'};
playMIDI('mario.mid',oscParams,constants,2,oscillTypes)

oscillTypes = {'sine','SUB','FM'};
playMIDI('furelise.mid',oscParams,constants,4,oscillTypes)
