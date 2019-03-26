%{
Karol Wadolowski

Takes a midi file name that is in the directory and processes it and then
plays it.

Inputs:
    name_MIDI : name of MIDI file that you want to play (must be in
    directory)
    oscParams : as you defined them in your realtime files
    constants : as you defined them in your realtime files
    xSpeed    : speed up (xSpeed = 2 means twice as fast)
    oscillTypes : Cell array containing the names of all available
    oscillator types
%}

function playMIDI(name_MIDI,oscParams,constants,xSpeed,oscillTypes)
DEBUG = 0;                      %Print debugging statements

fileID = fopen(name_MIDI);      %Open MIDI file
bytes = fread(fileID)';         %Store the MIDI file in bytes

n = length(bytes);
headerLoc = 1;                  %Location of first MIDI header
midiType = nan;                 %0, 1, or 2
tracks = nan;                   %Number of tracks
ppqn = nan;                     %Pulses per quarter note
commandDone = 0;                %Logical 1 if command just finished. 0 if command ongoing
time = 0;                       %Current time
uspp = 0;                       %Microseconds per pulse
command = -1;                   %Current command number (0-7) while running
patchVal = 0;                   %Patch value (aka instrument)

for ii = 1:16
    for jj = 1:128
        keys(ii,jj).times = cell(2,0);  %Each channel with 128 possible keys.
        %Will store the start and end times of a key press.
    end
end

ii = 1;     %Loop variable
fprintf("Start processing MIDI file.\n")
while(ii <= n)
    if (ii == headerLoc)    %Skip Header bytes
        if (DEBUG)
            fprintf("Header Loc found at %.0f\n",ii);
        end
        ii = ii + 4;    %Move to start of length bytes
    else
        if (ii == (headerLoc + 4))  %Looking at length bytes
            %ii is currently at the first byte of the 4 byte length
            nextHeaderLoc = sum((256.^(3:-1:0)).*bytes(ii:ii+3)) + ii + 4; 
            %ii + 4 added to account for the 4 byte length 

            if (DEBUG)
                fprintf("Next Header Loc found at %.0f\n",nextHeaderLoc)
            end
            
            ii = ii + 4;    %Next byte after length bytes
            
            %Handle the set up (Only runs once)
            if (ii == 9)        %MTHd not MTrk
                midiType = bytes(10);
                tracks = 256*bytes(11) + bytes(12);
                ppqn = 256*bytes(13) + bytes(14);
                
                fprintf("This file is MIDI type %1.0f. \n", midiType)
                fprintf("There are %.0f tracks. \n", tracks)
                fprintf("The ppqn is %.0f. \n", ppqn)
               
                ii = 15;     %First track location
            end
            
            headerLoc = nextHeaderLoc;      %Location of next MTrk header
            
            if (midiType ~= 2)      %1 or more simultaneous tracks
                time = 0;           %Reset back to 0 after each track
            end
            
            commandDone = 1;
            
        else        %General Commands of the track
            if (commandDone)    %Compute delta time
                dt = 0;         %Delta time in seconds
                dtp = 0;        %Delta time in pulses
                while(bytes(ii) >= 128)     %Extended Lengths
                    dt = dt*128 + (bytes(ii) - 128)*uspp;
                    dtp = dtp*128 + bytes(ii) - 128;
                    ii = ii + 1;
                end
                %Once out of the loop we are at the last delta time info
                %byte
                dt = dt*128 + bytes(ii)*uspp;
                dtp = dtp*128 + bytes(ii);
                
                if (DEBUG)
                    fprintf("ii = %0.f,\tDelta time %.0f\n", ii, dtp)
                end
                
                time = time + dt;   %Update time
                ii = ii + 1;
                commandDone = 0;
            else                %Command
                %Non MIDI events handling
                if (bytes(ii) == 255)   %FF commands
                    if (DEBUG)
                        fprintf("ii = %.0f,\tFF command found\n", ii)
                    end
                    ii = ii + 1;
                    
                    switch (bytes(ii))  %Switch based on type#
                        case (47)           %2F 00 End of track
                            ii = ii + 2;    %Start of next track
                            
                        case (81)           %51 03 tt tt tt Tempo info
                            ii = ii + 2;    %First tt
                            %Microseconds per quarter note
                            uspqn = (sum((256.^(2:-1:0)).*(bytes(ii:ii+2))))*1e-6;
                            uspp = uspqn/ppqn;  %Microseconds per pulse
                            tempo = 60/uspqn;   %Tempo aka bpm
                            ii = ii + 3;
                            
                        otherwise
                            ii = ii + 1;    %Start of length byte
                            ii = ii+ bytes(ii) + 1;     %Next delta time command location
                    end
                else    %Other command (8 possible)
                    prevCommand = command;      %Store previous command 
                    
                    if (bytes(ii) >= 128)   %New command
                        channel = mod(bytes(ii),16) + 1;    %Channel of the command (+1 for indexing)
                        command = floor(bytes(ii)/16) - 8;  %Command value
                        
                        switch (command)
                            case 0      %Note off
                                note = bytes(ii+1) + 1;     %Note value (+1 for indexing)
                                temp = cell2mat(keys(channel,note).times(1,end));
                                temp(2) = time;     %Record the end time of the note
                                keys(channel,note).times(1,end) = {temp};
                                ii = ii + 3;        %Next delta time command
                                
                            case 1      %Note on
                                note = bytes(ii+1) + 1;
                                if (bytes(ii+2) == 0)   %Note off with note on command
                                    temp = cell2mat(keys(channel,note).times(1,end));
                                    temp(2) = time;     %Record an end time
                                    keys(channel,note).times(1,end) = {temp};
                                else    %Note actually being turned on
                                    temp = [time, nan];
                                    nxt = size(keys(channel,note).times,2);     %Next cell array entry
                                    keys(channel,note).times(1,nxt+1) = {temp};
                                    keys(channel,note).times(2,nxt+1) = {patchVal};
                                end
                                ii = ii + 3;        %Next delta time command
                                
                            case 2      %Polyphonic key aftertouch
                                ii = ii + 3;        %Next delta time command 
                            
                            case 3      %Controller Command
                                ii = ii + 3;        %Next delta time command
                            
                            case 4      %Patch Change
                                patchVal = bytes(ii+1); %Change patch
                                ii = ii +2;         %Next delta time command
                                
                            case 5      %Channel aftertouch
                                ii = ii + 2;        %Next delta time command
                                
                            case 6      %Pitch Bend
                                ii = ii + 3;        %Next delta time command
                                
                            case 7      %System Commands
                                ii = ii + 1;        %Manufacturer ID byte
                                while(bytes(ii) ~= 247)
                                    ii = ii + 1;
                                end
                                ii = ii + 1;        %Next delta time command
                                
                            otherwise
                                error('Not a valid command')
                        end
                    else        %Repeated command
                        command = prevCommand;
                        
                        switch (command)
                            case 0      %Note off
                                note = bytes(ii) + 1;     %Note value (+1 for indexing)
                                temp = cell2mat(keys(channel,note).times(1,end));
                                temp(2) = time;     %Record the end time of the note
                                keys(channel,note).times(1,end) = {temp};
                                ii = ii + 2;        %Next delta time command
                                
                            case 1      %Note on
                                note = bytes(ii) + 1;
                                if (bytes(ii+1) == 0)   %Note off with note on command
                                    temp = cell2mat(keys(channel,note).times(1,end));
                                    temp(2) = time;     %Record an end time
                                    keys(channel,note).times(1,end) = {temp};
                                else    %Note actually being turned on
                                    temp = [time, nan];
                                    nxt = size(keys(channel,note).times,2);     %Next cell array entry
                                    keys(channel,note).times(1,nxt+1) = {temp};
                                    keys(channel,note).times(2,nxt+1) = {patchVal};
                                end
                                ii = ii + 2;        %Next delta time command
                                
                            case 2      %Polyphonic key aftertouch
                                ii = ii + 2;        %Next delta time command 
                            
                            case 3      %Controller Command
                                ii = ii + 2;        %Next delta time command
                            
                            case 4      %Patch Change
                                patchVal = bytes(ii);   %Change patch
                                ii = ii + 1;        %Next delta time command
                                
                            case 5      %Channel aftertouch
                                ii = ii + 1;        %Next delta time command
                                
                            case 6      %Pitch Bend
                                ii = ii + 2;        %Next delta time command
                                
                            case 7      %System Commands
                                while(bytes(ii) ~= 247)
                                    ii = ii + 1;
                                end
                                ii = ii + 1;        %Next delta time command
                                
                            otherwise
                                error('Not a valid command')
                        end
                        
                    end
                end
                commandDone = 1;        %Command finished
            end
        end
    end       
end

%All notes have now been stored in keys object. Now place them in a matrix
%and order based on start time.

musicNotes = [];        %Will hold the key times and notes
%First 2 columns are start and end times, 3rd col is note value, 4th is
%patch val

cnt = 1;                %Count
for ii = 0:15
    for jj = 1:127
        temp = keys(ii+1,jj+1).times;
        times_pressed = size(temp,2);       %Time a key has been pressed
        if (times_pressed > 0)
            for kk = 1:times_pressed
                musicNotes(cnt,1:2) = cell2mat(temp(1,kk));     %Start and end times
                musicNotes(cnt,3) = jj;                         %Note value
                musicNotes(cnt,4) = cell2mat(temp(2,kk));       %Patch value
                cnt = cnt + 1;
            end
        end
    end
end

%Order the notes by start time
[~,order] = sort(musicNotes(:,1),1);
for ii = 1:size(musicNotes,2)
    musicNotes(:,ii) = musicNotes(order,ii);
end

%Create mapping from patch to oscillator type
num_inst = size(oscillTypes,2);             %Number of available instruments
patches = unique(musicNotes(:,4))';         %All different patch numbers
mapping = [patches; 0:(length(patches)-1)];
mapping(2,:) = mod(mapping(2,:),num_inst);      %Second row contains a number in the key set

temp = zeros(length(musicNotes(:,4)),1);
for ii = 1:(length(patches))
    temp = temp + (musicNotes(:,4) == mapping(1,ii))*mapping(2,ii);
end

musicNotes(:,4) = temp;
keySet = [0:(num_inst-1)];

%If statement in case there is only one oscillator type.
if size(oscillTypes,2) == 1
    M = containers.Map(keySet,string(oscillTypes));
else
    M = containers.Map(keySet,oscillTypes);
end

%Map the patches to oscillators
for ii = 1:length(musicNotes(:,4))
    oscParams.oscTypes(ii) = {M(musicNotes(ii,4))};
end


musicNotes(:,1:2) = musicNotes(:,1:2)/xSpeed;   %Speed up factor

fprintf("MIDI file processing finished.\nStart creating note objects\n")
music = objMusic('equal','C',tempo*xSpeed,musicNotes);

fprintf("MIDI note objects created\n\n")
playAudio(music,oscParams,constants);
end












