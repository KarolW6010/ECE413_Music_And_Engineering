%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Karol Wadolowski
% SCRIPT
%    hw2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear functions
clear variables
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constants.fs=44100;                     % Sampling rate in samples per second
constants.durationScale=.5;             % Duration of notes in a scale
constants.durationChord=4;              % Duration of chords
STDOUT=1;                               % Define the standard output stream
STDERR=2;                               % Define the standard error stream

notes{1}.note='C4';
notes{1}.start=0;
notes{1}.duration=constants.durationChord*constants.fs;
notes{1}.velocity=1;
notes{2}.note='E4';
notes{2}.start=0;
notes{2}.duration=constants.durationChord*constants.fs;
notes{2}.velocity=1;
notes{3}.note='G4';
notes{3}.start=0;
notes{3}.duration=constants.durationChord*constants.fs;
notes{3}.velocity=1;

instrument.temperament='Equal';
instrument.sound='Additive';
%instrument.totalTime=find_length_of_notes(notes);

% for just-tempered chords, use the root note and mode to generate
% frequencies rather than a sequence of note names.
instrument.mode = 'Major';
instrument.mode = 'Note';  %Single note

synthTypes={'Additive','Subtractive','FM','Waveshaper'};
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Questions 1--4 - samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cntSynth=1:length(synthTypes)
    instrument.sound=synthTypes{cntSynth};
    [soundSample]=create_sound(instrument,notes{1}, constants);
    
    fprintf(STDOUT,'For the %s synthesis type...\n',synthTypes{cntSynth})
    
    fprintf(STDOUT,'Playing the Sample Note');
    soundsc(soundSample,constants.fs);
    pause(constants.durationChord)
    fprintf('\n');
    
end % for cntSynth;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Question 5  - chords
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cntSynth=1:length(synthTypes)
    % major chords
    instrument.mode = 'Major';
    instrument.sound=synthTypes{cntSynth};
    [soundMajorChordJust]=create_sound(instrument,notes{2},constants);
    instrument.temperament='Equal';
    [soundMajorChordEqual]=create_sound(instrument,notes{2},constants);
    
    % minor chords
    %notes{2}.note='Eb4';
    instrument.mode = 'Minor';
    [soundMinorChordEqual]=create_sound(instrument,notes{2},constants);
    instrument.temperament='Just';
    [soundMinorChordJust]=create_sound(instrument,notes{2},constants);
    %notes{2}.note='E4';
    
    fprintf(STDOUT,'For the %s synthesis type...\n',synthTypes{cntSynth})
    disp('Playing the Just Tempered Major Chord');
    soundsc(soundMajorChordJust,constants.fs);
    pause(constants.durationChord)
    disp('Playing the Equal Tempered Major Chord');
    soundsc(soundMajorChordEqual,constants.fs);
    pause(constants.durationChord)
    disp('Playing the Just Tempered Minor Chord');
    soundsc(soundMinorChordJust,constants.fs);
    pause(constants.durationChord)
    disp('Playing the Equal Tempered Minor Chord');
    soundsc(soundMinorChordEqual,constants.fs);
    pause(constants.durationChord)
    fprintf('\n');
    
end % for cntSynth;


