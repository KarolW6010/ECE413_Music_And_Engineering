function out=playAudio(notes,oscParams,constants)
USE_SYSTEM=1;

% Instantiate Objects
if USE_SYSTEM
    Generator = objSynth(notes,oscParams,constants);
else
    Generator = objSynth_OLD(notes,oscParams,constants);
end
%keyboard()
Speaker = audioDeviceWriter('SampleRate',constants.SamplingRate,'BufferSize',constants.BufferSize);

audio=zeros(1,constants.BufferSize);
pause(1)                                                % Allow soundcard time to start up

if USE_SYSTEM
    audio = step(Generator);
else
    audio = Generator.advance;
end
out=[audio];

while ~isempty(audio)
    step (Speaker, audio);
    
    if USE_SYSTEM
        audio = step(Generator);
    else
        audio = Generator.advance;
    end
    out=[out;audio];
end
end
