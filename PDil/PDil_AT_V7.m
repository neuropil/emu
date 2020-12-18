%V8 - transitioning to a more put-together form of this task

sca; clearvars; close all; clc;


wholesession = tic;
introtime = tic;


practiceblock = 'no';

if strcmp(practiceblock, 'yes')
    nTrialsPerBlock = 8;
elseif strcmp(practiceblock, 'no')
    nTrialsPerBlock = 10;
end

mode = 'testrun'; %either 'testrun' or 'experiment'
opponent = 'human'; %either 'human' or 'computer'
taskoutput = struct();
dbstop if error
PsychDefaultSetup(2);
DisableKeysForKbCheck(40)%this is used for keys that are stuck so that that specific keyboard output is ignored

txtsize = 20;
spacebar_wait = 1;

if strcmp(opponent, 'computer')
    choice_matrix_player1 = zeros(1,10);
    choice_matrix_player2 = {'c';'d';'c';'d';'d';'d';'d';'d';'c';'d'};
elseif strcmp(opponent, 'human')
    choice_matrix_player1 = zeros(1,10);
    choice_matrix_player2 = zeros(1,10);
end

% rand('state', sum(100*clock)); %AT this is no longer recommended
rng('shuffle');% At this is recommended in the ^'s place

ErrorDelay=1;
interTrialInterval = .1;
rxnTime_player1 = zeros(nTrialsPerBlock,1);
rxnTime_player2 = zeros(nTrialsPerBlock,1);
playerA_pts_summary = zeros(nTrialsPerBlock,1);

Time_scrn_flip_trials1= zeros(nTrialsPerBlock,2);
Time_scrn_flip_trials2= zeros(nTrialsPerBlock,2);
Time_scrn_flip_trials3= zeros(nTrialsPerBlock,2);
Time_scrn_flip_trials4= zeros(nTrialsPerBlock,2);
Time_scrn_flip_trials5= zeros(nTrialsPerBlock,2);

Time_postscrn_flip_trials1 = zeros(nTrialsPerBlock,1);
Time_postscrn_flip_trials2 = zeros(nTrialsPerBlock,1);
Time_postscrn_flip_trials3 = zeros(nTrialsPerBlock,1);
Time_postscrn_flip_trials4 = zeros(nTrialsPerBlock,1);
Time_postscrn_flip_trials5 = zeros(nTrialsPerBlock,1);
timing_wholesession_trials = zeros(nTrialsPerBlock,1);
timing_wholesession_trial_n = zeros(nTrialsPerBlock,1);
timing_sumTictocs_trial_n = zeros(nTrialsPerBlock,1);

KbName('UnifyKeyNames');
% Key1=KbName('LeftArrow'); Key_rtArrow=KbName('RightArrow');
Key_spacebar = KbName('space');
Key_esc = KbName('ESCAPE');
Key_c = KbName('c');
Key_d = KbName('d');
Key_1 = KbName('1!');
Key_2 = KbName('2@');
Key_3 = KbName('3#');
Key_4 = KbName('4$');
Key_5 = KbName('5%');
Key_6 = KbName('6^');
Key_7 = KbName('7&');
Key_8 = KbName('8*');
Key_9 = KbName('9(');

% corrkey = [80, 79]; % left and right arrow, %AT; note, this will need to be changed most likely if going between Mac and windows
%can use KbDemo to test out some key names and other timing things

gray = [.5 .5 .5];
white = [1 1 1];
black = [0 0 0];
%below is for red
str_color = '#FF401b';
red = sscanf(str_color(2:end),'%2x%2x%2x',[1 3])/255;
%below is for green
str_color = '#58de49';
green = sscanf(str_color(2:end),'%2x%2x%2x',[1 3])/255;
%below is for blue
str_color = '#009de6';
blue = sscanf(str_color(2:end),'%2x%2x%2x',[1 3])/255;

str_color = '#00BA00';
green2 = sscanf(str_color(2:end),'%2x%2x%2x',[1 3])/255;

str_color = '#FF00AB';
magenta = sscanf(str_color(2:end),'%2x%2x%2x',[1 3])/255;

str_color = '#00B1FF';
blue2 = sscanf(str_color(2:end),'%2x%2x%2x',[1 3])/255;


bgcolor = white;
textcolor_black = black;
textcolor_defect = magenta;
textcolor_cooperate = blue2;
textcolor_keypresses = green2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Sound feedback
% BeepFreq = [800 1300 2000]; BeepDur = [.1 .1 .1];
% Beep1 = MakeBeep(BeepFreq(1), BeepDur(1));
% Beep2 = MakeBeep(BeepFreq(2), BeepDur(2));
% Beep3 = MakeBeep(BeepFreq(3), BeepDur(3));
% Beep4 = [Beep1 Beep2 Beep3];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Login prompt and open file for writing data out
prompt = {'Outputfile', 'Subject''s number:', 'age', 'gender', 'group', 'Num of Blocks'};
defaults = {'ChoiceRT', '4', '4', '4', '4' , '4'};
answer = inputdlg(prompt, 'ChoiceRT', 2, defaults);
[output, subid, subage, gender, group, nBlocks] = deal(answer{:}); % all input variables are strings
outputname = [output gender subid group subage '.xls'];
nblocks = str2num(nBlocks); % convert string to number for subsequent reference

if exist(outputname)==2 % check to avoid overiding an existing file
    fileproblem = input('That file already exists! Append a .x (1), overwrite (2), or break (3/default)?');
    if isempty(fileproblem) || fileproblem==3
        return;
    elseif fileproblem==1
        outputname = [outputname '.x'];
    end
end
outfile = fopen(outputname,'w'); % open a file for writing data out
fprintf(outfile, 'subid\t subage\t gender\t group\t keyboardOrMouse\t blockNumber\t trialNumber\t redOrBlue\t accuracy\t ReactionTime\t \n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Screen parameters

Screen('Preference', 'SkipSyncTests', 1);

screens=Screen('Screens');
% screenNumber=max(screens);
screenNumber = 0;

if strcmp(mode, 'testrun')
    rez = Screen('Resolution',screenNumber);
    width = (rez.width)/4;
    height = (rez.height)/4;
    newrect = [0,0,width,height];
    
    [mainwin, screenrect] = PsychImaging('OpenWindow', screenNumber, white, newrect);
    %     Screen('BlendFunction', mainwin, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    %     [mainwin, screenrect] = Screen('OpenWindow', window, newrect);
    
elseif strcmp(mode, 'experiment')
    
    % Open window with default settings:
    [mainwin, screenrect] = Screen('OpenWindow', screenNumber);
    
end
% [mainwin, screenrect] = Screen(0, 'OpenWindow');
% Screen('TextFont',mainwin, 'Helvetica');
% Screen('TextSize',mainwin, 14);
% Screen('TextStyle', mainwin, 1+2);
% Screen('FillRect', mainwin, bgcolor);
center = [screenrect(3)/2 screenrect(4)/2];
x_offset = -(center(1)/2);
y_offset = -(center(2)/2);
Screen(mainwin, 'Flip');

% %   load images
% im = imread('redStar.jpg'); redStar = Screen('MakeTexture', mainwin, im);
% im = imread('blueStar.jpg'); blueStar = Screen('MakeTexture', mainwin, im);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Experimental instructions, wait for a spacebar response to start
Screen('FillRect', mainwin ,bgcolor);
Screen('TextSize', mainwin, txtsize);


Intro_wholesession = toc(wholesession);
Introtime = toc(introtime);

time_scrn_flip_intro1 = tic;jj = 1;
Time_scrn_flip_intro1 = zeros(1,2); %note, you need to change variable name
while jj <= 2
    
    linea = 'Starting study, please remember you can stop at any time.';
    lineb = '';
    Screen('TextSize', mainwin, txtsize);
    DrawFormattedText(mainwin, [linea, lineb],...
        'center',center(2)+y_offset,textcolor_black);
    
    if jj == 2
        DrawFormattedText(mainwin, '\n\n\n\n Press spacebar to begin the study.',...
            'center',center(2)+y_offset,textcolor_keypresses);
    end
    
    Screen('Flip',mainwin );
    Time_scrn_flip_intro1(jj) = toc(time_scrn_flip_intro1);
    if jj == 2
        time_postscrn_flip_intro1 = tic;
    elseif jj == 1
        WaitSecs(spacebar_wait)
    end
    
    jj = jj+1;
    
end



FlushEvents();
keyIsDown=0;

while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(Key_spacebar)
            break ;
        elseif keyCode(Key_esc)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end

Time_postscrn_flip_intro1 = toc(time_postscrn_flip_intro1);
time_scrn_flip_intro2 = tic;
FlushEvents();
WaitSecs(0.5);



jj = 1;
Time_scrn_flip_intro2 = zeros(1,6); %note, you need to change variable name
while jj <= 6
    
    linea = 'Below are examples of text colors and their associations.';
    Screen('TextSize', mainwin, txtsize);
    DrawFormattedText(mainwin, linea,...
        'center',center(2)+y_offset,textcolor_black);
    
    if jj >= 2
        DrawFormattedText(mainwin, linea,...
            'center',center(2)+y_offset,textcolor_black);
    end
    if jj >= 3
        DrawFormattedText(mainwin, '\n\n\n  ''Keypress requested''',...
            'center',center(2)+y_offset,textcolor_keypresses);
    end
    if jj >= 4
        DrawFormattedText(mainwin, '\n\n\n\n\n   ''Cooperate''',...
            'center',center(2)+y_offset,textcolor_cooperate);
    end
    if jj >= 5
        DrawFormattedText(mainwin, '\n\n\n\n\n\n\n    ''Defect''',...
            'center',center(2)+y_offset,textcolor_defect);
    end
    
    
    if jj == 6
        DrawFormattedText(mainwin, '\n\n\n\n\n\n\n\n\n\n Press spacebar to begin the study.',...
            'center',center(2)+y_offset,textcolor_keypresses);
    end
    
    Screen('Flip',mainwin );
    Time_scrn_flip_intro2(jj) = toc(time_scrn_flip_intro2);
    if jj == 6
        time_postscrn_flip_intro2 = tic;
    end
    
    if jj < 5
        WaitSecs(spacebar_wait/2)
    elseif jj == 5
        WaitSecs(spacebar_wait)
        
    end
    
    jj = jj+1;
    
end

FlushEvents();
keyIsDown=0;

while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(Key_spacebar)
            break ;
        elseif keyCode(Key_esc)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end

Time_postscrn_flip_intro2 = toc(time_postscrn_flip_intro2);
time_scrn_flip_intro3 = tic;
FlushEvents();
WaitSecs(0.5);



jj = 1;
Time_scrn_flip_intro3 = zeros(1,2);
while jj <= 2
    
    if strcmp(practiceblock, 'yes')
        linea = 'This is a PRACTICE block of trials. First, you will walk through an example of each possible outcome and then given the chance to practice some responses on your own';
        lineb = '\n\n For this block, "Player B" is a COMPUTER.'; %
        Screen('TextSize', mainwin, txtsize);
        DrawFormattedText(mainwin, [linea, lineb],...
            'center',center(2)+y_offset,textcolor_black, 70);
    elseif strcmp(practiceblock, 'no')
        if strcmp(opponent, 'computer')
            linea = 'For this block, "Player B" is a COMPUTER.'; %
        elseif strcmp(opponent, 'human')
            linea = 'For this block, "Player B" is a PERSON.'; %
        end
        Screen('TextSize', mainwin, txtsize);
        DrawFormattedText(mainwin, [linea],...
            'center',center(2)+y_offset,textcolor_black, 70);
    end
    
    
    if jj == 2
        DrawFormattedText(mainwin, '\n\n\n\n\n\n\n\n\n Press spacebar to begin the study.',...
            'center',center(2)+y_offset,textcolor_keypresses);
    end
    
    Screen('Flip',mainwin );
    Time_scrn_flip_intro3(jj) = toc(time_scrn_flip_intro3);
    
    if jj == 2
        time_postscrn_flip_intro3 = tic;
        
    elseif jj == 1
        WaitSecs(spacebar_wait)
    end
    
    jj = jj+1;
    
end

FlushEvents();
keyIsDown=0;

while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(Key_spacebar)
            break ;
        elseif keyCode(Key_esc)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end

IntroScreens_wholesession = toc(wholesession);
Time_postscrn_flip_intro3 = toc(time_postscrn_flip_intro3);


for a = 1:nTrialsPerBlock
    
%     Time_scrn_flip_trials1 = zeros(nTrialsPerBlock,2);
    time_scrn_flip_trials1 = tic;
    FlushEvents();
    WaitSecs(0.5);
    
    jj = 1;
    while jj <= 2
        
        linea = (['Your cumulative points: ' mat2str(sum(playerA_pts_summary))]);
        lineb = ''; %
        Screen('TextSize', mainwin, txtsize);
        DrawFormattedText(mainwin, [linea, lineb],...
            'center',center(2)+y_offset,textcolor_black);
        
        if jj == 2
            if strcmp(practiceblock, 'yes')
                DrawFormattedText(mainwin, (['\n\n\n\n Press spacebar to begin PRACTICE Trial #' mat2str(a)]),...
                    'center',center(2)+y_offset,textcolor_keypresses);
            elseif strcmp(practiceblock, 'no')
                DrawFormattedText(mainwin, (['\n\n\n\n Press spacebar to begin Trial #' mat2str(a)]),...
                    'center',center(2)+y_offset,textcolor_keypresses);
            end
        end
        
        Screen('Flip',mainwin );
        Time_scrn_flip_trials1(a,jj) = toc(time_scrn_flip_trials1);
        
        if jj == 2
            time_postscrn_flip_trials1 = tic;
        elseif jj == 1
            WaitSecs(spacebar_wait)
        end
        
        jj = jj+1;
        
    end
    
    
    
    
    FlushEvents();
    keyIsDown=0;
    
    while 1
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(Key_spacebar)
                break ;
            elseif keyCode(Key_esc)
                ShowCursor;
                fclose(outfile);
                Screen('CloseAll');
                return;
            end
        end
    end
    
    Time_postscrn_flip_trials1(a,1) = toc(time_postscrn_flip_trials1);
    time_scrn_flip_trials2 = tic;
    FlushEvents();
    WaitSecs(0.5);
    
%     Time_scrn_flip_trials2 = zeros(nTrialsPerBlock,2);
    jj = 1;
    while jj <= 2
        
        linea = ('Player A: Do you choose to Cooperate or Defect?');
        lineb = ('\n'); %
        linec = ('\n\n');
        lined = ('');
        DrawFormattedText(mainwin, [linea  lineb  linec],...
            'center', center(2)+y_offset,textcolor_black);
        if jj == 2
            lineb = ('\n'); %
            linec = ('\n\n\n   Press the       key for                  , or       key for        '); %
            if strcmp(practiceblock, 'yes')
                if a == 1
                    lined = ('\n\n PRACTICE trial: let''s see what happens if both you and Player B Cooperate');
                elseif a == 2
                    lined = ('\n\n PRACTICE trial: let''s see what happens if both you and Player B Defect');
                elseif a == 3
                    lined = ('\n\n PRACTICE trial: let''s see what happens if you Cooperate and Player B Defects');
                elseif a == 4
                    lined = ('\n\n PRACTICE trial: let''s see what happens if you Defect and Player B Cooperates');
                elseif a > 4
                    lined = ('\n\n PRACTICE trial: let''s simulate a real trial');
                    
                end
            end
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, linea,...
                'center', center(2)+y_offset,textcolor_black);
            DrawFormattedText(mainwin, [lineb  linec],...
                'center', center(2)+y_offset,textcolor_keypresses);
            DrawFormattedText(mainwin, lined,...
                'center', center(2)+y_offset,textcolor_black);
            
            
            linea = ('');
            lineb = ('\n'); %
            linec = ('\n\n\n                                                  "D"             Defect'); %
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, [linea  lineb  linec],...
                center(1)+x_offset, center(2)+y_offset,textcolor_defect);
            
            linea = ('');
            lineb = ('\n'); %
            linec = ('\n\n\n         "C"             Cooperate'); %
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, [linea  lineb  linec],...
                center(1)+x_offset, center(2)+y_offset,textcolor_cooperate);
        end
        
        
        Screen('Flip',mainwin );
        Time_scrn_flip_trials2(a, jj) = toc(time_scrn_flip_trials2);
        
        if jj == 2
            time_postscrn_flip_trials2 = tic;
        elseif jj == 1
            WaitSecs(spacebar_wait)
        end
        
        jj = jj+1;
        
    end
    
    
    FlushEvents();
    
    keyIsDown=0;
    rxntime_player1 = tic;
    
    if strcmp(practiceblock, 'yes')
        if a == 1 || a == 3
            RestrictKeysForKbCheck([Key_c,Key_esc])
        elseif a == 2 || a == 4
            RestrictKeysForKbCheck([Key_d, Key_esc])
        else
            RestrictKeysForKbCheck([Key_d, Key_c, Key_esc])
        end
    end
    
    if strcmp(practiceblock, 'no')
        RestrictKeysForKbCheck([Key_d, Key_c, Key_esc])
    end
    
    
    while 1
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            rxnTime_player1(a,1) = toc(rxntime_player1);
            
            if keyCode(Key_c)
                player1_response = 'c';
                break ;
            elseif keyCode(Key_d)
                player1_response = 'd';
                break ;
            elseif keyCode(Key_esc)
                ShowCursor;
                fclose(outfile);
                Screen('CloseAll');
                return;
            end
            
        end
    end
    
    Time_postscrn_flip_trials2(a,1) = toc(time_postscrn_flip_trials2);
    time_scrn_flip_trials3 = tic;
    
    RestrictKeysForKbCheck([])
    WaitSecs(.5);
    FlushEvents();
    
    %     if a == 1 || a == 3
    %         player1_response = 'c';
    %     elseif a == 2 || a == 4
    %         player1_response = 'd';
    %     end
    
    
    
    jj = 1;
%     Time_scrn_flip_trials3 = zeros(nTrialsPerBlock,2);

    while jj <= 2
        if strcmp(player1_response, 'd')
            linea = ('Your response: ______');
            DrawFormattedText(mainwin, linea,...
                'center',center(2)+y_offset,textcolor_black);
            DrawFormattedText(mainwin, '                                       Defect',...
                center(1)+x_offset,center(2)+y_offset,textcolor_defect);
        elseif strcmp(player1_response, 'c')
            linea = ('Your response: _________');
            
            DrawFormattedText(mainwin, linea,...
                'center',center(2)+y_offset,textcolor_black);
            DrawFormattedText(mainwin, '                                    Cooperate',...
                center(1)+x_offset,center(2)+y_offset,textcolor_cooperate);
        end
        
        
        if jj == 2
            DrawFormattedText(mainwin, ('\n\n\n\n  Awaiting Player B''s response...'),...
                'center',center(2)+y_offset,textcolor_keypresses);
        end
        
        Screen('Flip',mainwin );
        Time_scrn_flip_trials3(a,jj) = toc(time_scrn_flip_trials3);
        
        if jj == 2
            time_postscrn_flip_trials3 = tic;
        elseif jj == 1
            WaitSecs(spacebar_wait)
        end
        
        jj = jj+1;
        
    end
    
    
    
    
    if a > 0
        RestrictKeysForKbCheck([Key_c, Key_d, Key_esc])
        
        if strcmp(opponent, 'computer')
            WaitSecs(2)
            player2_response = choice_matrix_player2(a);
        elseif strcmp(opponent,'human')
            keyIsDown=0;
            rxntime_player2 = tic;
            
            while 1
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyIsDown
                    toc_rxntime_player2 = toc(rxntime_player2);
                    
                    if keyCode(Key_spacebar)
                        break ;
                    elseif keyCode(Key_c)
                        player2_response = 'c';
                        break ;
                    elseif keyCode(Key_d)
                        player2_response = 'd';
                        break ;
                    elseif keyCode(Key_esc)
                        ShowCursor;
                        fclose(outfile);
                        Screen('CloseAll');
                        return;
                    end
                end
            end
            
            Time_postscrn_flip_trials3(a,1) = toc(time_postscrn_flip_trials3);
            time_scrn_flip_trials4 = tic;
            FlushEvents();
            RestrictKeysForKbCheck([])
            WaitSecs(.5);
            
        end
        
    elseif a == 1 || a == 2
        player2_response = 'c';
    elseif a == 3 || a == 4
        player2_response = 'd';
    end
    
    
    
    if strcmp(opponent, 'human')
        rxnTime_player2(a,1) = toc_rxntime_player2;
    end
    
    
    
    jj = 1;
%     Time_scrn_flip_trials4 = zeros(nTrialsPerBlock,2);

    while jj <= 2
        if strcmp(player1_response, 'd')
            linea = 'Player B has responded';
            lineb = ('\n\n  If response is Cooperate, you will receive 6 points');
            linec = ('\n  If response is Defect, you will receive 1 points');
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, [linea],...
                'center',center(2)+y_offset,textcolor_black);
        elseif strcmp(player1_response, 'c')
            linea = 'Player B has responded';
            lineb = ('\n\n  If response is Cooperate, you will receive 4 points');
            linec = ('\n  If response is Defect, you will receive 2 points');
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, [linea],...
                'center',center(2)+y_offset,textcolor_black);
        end
        
        
        if jj == 2
            lineg = '\n\n\n\n\n\n Press spacebar to see Player B''s response';
            DrawFormattedText(mainwin, lineg,...
                'center',center(2)+y_offset,textcolor_keypresses);
        end
        
        Screen('Flip',mainwin );
        Time_scrn_flip_trials4(a,jj) = toc(time_scrn_flip_trials4);
        
        if jj == 2
            time_postscrn_flip_trials4 = tic;
            
        elseif  jj == 1
            WaitSecs(spacebar_wait)
        end
        
        jj = jj+1;
        
    end
    
    
    
    
    FlushEvents();
    keyIsDown=0;
    
    while 1
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(Key_spacebar)
                break ;
            elseif keyCode(Key_esc)
                ShowCursor;
                fclose(outfile);
                Screen('CloseAll');
                return;
            end
        end
    end
    
    Time_postscrn_flip_trials4(a,1) = toc(time_postscrn_flip_trials4);
    time_scrn_flip_trials5 = tic;
    FlushEvents();
    WaitSecs(0.5);
%     Time_scrn_flip_trials5 = zeros(nTrialsPerBlock,2);
    
    jj = 1;
    while jj <= 2
        if strcmp(player2_response, 'c') && strcmp(player1_response,'c') %mod(trialorder(i),2)==0
            %             Screen('DrawTexture', mainwin, redStar, [], itemloc);
            linea = '\n\n Your response: _________';
            lineb = '\n Player B''s response: _________'; %
            linec = 'You receive 4 points'; %
            lined = '';
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, [linec linea lineb lined],...
                'center',center(2)+y_offset,textcolor_black);
            DrawFormattedText(mainwin, '\n\n                                     Cooperate',...
                center(1)+x_offset,center(2)+y_offset,textcolor_cooperate);
            DrawFormattedText(mainwin, '\n\n\n                                         Cooperate',...
                center(1)+x_offset,center(2)+y_offset,textcolor_cooperate);
            PlayerA_pts = 4;
        elseif strcmp(player2_response, 'd') && strcmp(player1_response,'d') %mod(trialorder(i),2)==0
            linea = '\n\n Your response: ______';
            lineb = '\n Player B''s response: ______'; %
            linec = 'You receive 2 points'; %
            lined = '';
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, [linec linea lineb lined],...
                'center',center(2)+y_offset,textcolor_black);
            DrawFormattedText(mainwin, '\n\n                                        Defect',...
                center(1)+x_offset,center(2)+y_offset,textcolor_defect);
            DrawFormattedText(mainwin, '\n\n\n                                             Defect',...
                center(1)+x_offset,center(2)+y_offset,textcolor_defect);
            PlayerA_pts = 2;
        elseif strcmp(player2_response, 'd') && strcmp(player1_response,'c') %mod(trialorder(i),2)==0
            linea = '\n\n Your response: _________';
            lineb = '\n Player B''s response: ______'; %
            linec = 'You receive 1 point'; %
            lined = '';
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, [linec linea lineb lined],...
                'center',center(2)+y_offset,textcolor_black);
            DrawFormattedText(mainwin, '\n\n                                     Cooperate',...
                center(1)+x_offset,center(2)+y_offset,textcolor_cooperate);
            DrawFormattedText(mainwin, '\n\n\n                                             Defect',...
                center(1)+x_offset,center(2)+y_offset,textcolor_defect);
            
            PlayerA_pts = 1;
        elseif strcmp(player2_response, 'c') && strcmp(player1_response,'d') %mod(trialorder(i),2)==0
            linea = '\n\n Your response: ______';
            lineb = '\n Player B''s response: _________'; %
            linec = 'You receive 6 points'; %
            lined = '';
            Screen('TextSize', mainwin, txtsize);
            DrawFormattedText(mainwin, [linec linea lineb lined],...
                'center',center(2)+y_offset,textcolor_black);
            DrawFormattedText(mainwin, '\n\n                                        Defect',...
                center(1)+x_offset,center(2)+y_offset,textcolor_defect);
            DrawFormattedText(mainwin, '\n\n\n                                         Cooperate',...
                center(1)+x_offset,center(2)+y_offset,textcolor_cooperate);
            PlayerA_pts = 6;
        end
        
        if jj == 2
            lineg = '\n\n\n\n\n\n\n Press spacebar to proceed';
            DrawFormattedText(mainwin, lineg,...
                'center',center(2)+y_offset,textcolor_keypresses);
        end
        
        Screen('Flip',mainwin );
        Time_scrn_flip_trials5(a,jj) = toc(time_scrn_flip_trials5);
        
        if jj == 2
            time_postscrn_flip_trials5 = tic;
        elseif  jj == 1
            WaitSecs(spacebar_wait)
        end
        
        jj = jj+1;
        
    end
    
    
    
    choice_matrix_player1(a,1) = player1_response;
    choice_matrix_player2(a,1) = player2_response;
    playerA_pts_summary(a,1) = PlayerA_pts;
    
    
    FlushEvents();
    keyIsDown=0;
    
    while 1
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(Key_spacebar)
                break ;
            elseif keyCode(Key_esc)
                ShowCursor;
                fclose(outfile);
                Screen('CloseAll');
                return;
            end
        end
    end
    
    
    
    timing_wholesession_trials(a,1) = toc(wholesession);

    Time_postscrn_flip_trials5(a,1) = toc(time_postscrn_flip_trials5);
    
end




%AT 2/10/20 Intro timing for two variables below should match 
timing_sumTictocs_intro = Introtime;
timing_wholesession_intro = Intro_wholesession;
 

%AT 2/10/20 Intro timing for two variables below should match 
timing_sumTictocs_intro = Time_scrn_flip_intro1(1, 2)+Time_scrn_flip_intro2(1, 6)+Time_scrn_flip_intro3(1, 2)+Time_postscrn_flip_intro1+Time_postscrn_flip_intro2+Time_postscrn_flip_intro3;
timing_wholesession_introScreens = IntroScreens_wholesession - Intro_wholesession;
 
%AT 2/10/20 doing some processing on wholesession tictoc so I can get the
%trial by trial duration

for aa = 1:trialNumb
    timing_sumTictocs_trial_n(aa,1) = Time_scrn_flip_trials1(aa, 2)+Time_scrn_flip_trials2(aa, 2)+Time_scrn_flip_trials3(aa, 2)+Time_scrn_flip_trials4(aa, 2)+Time_scrn_flip_trials5(aa, 2)+Time_postscrn_flip_trials1(aa,1)+Time_postscrn_flip_trials2(aa,1)+Time_postscrn_flip_trials3(aa,1)+Time_postscrn_flip_trials4(aa,1)+Time_postscrn_flip_trials5(aa,1);
end

timing_wholesession_trial_n(1,1) = timing_wholesession_trials(1,1) - IntroScreens_wholesession;
for nn = 2:trialNumb
    timing_wholesession_trial_n(nn,1) = timing_wholesession_trials(nn,1) - timing_wholesession_trials((nn-1),1);
end



fclose(outfile);
fprintf('\n\n\n\n\n This block is now concluded! We appreciate your participation...\n\n');
wholesessionT = toc(wholesession);


%AT 1/23/20; point of taskoutput is to provide struct that stores relevant
%task information
taskoutput.choice_matrix_player1 = choice_matrix_player1;
taskoutput.choice_matrix_player2 = choice_matrix_player2;

taskoutput.rxnTime_player1 = rxnTime_player1;
taskoutput.rxnTime_player2 = rxnTime_player2;

taskoutput.durationWholeSession = wholesessionT;

if strcmp(practiceblock, 'no')
    taskoutput.probeResponse_playerAcoop = probeResponse_playerAcooperativity;
    taskoutput.probeResponse_playerAcoop_rxntime = probeResponse_playerAcoop_rxntime;
    
    taskoutput.probeResponse_playerBcoop = probeResponse_playerBcooperativity;
    taskoutput.probeResponse_playerBcoop_rxntime = probeResponse_playerBcoop_rxntime;
end

taskoutput.playerA_pts_summary = playerA_pts_summary;


%AT below is the timing of tictocs
taskoutput.timing.introtime = introtime;
taskoutput.timing.time_scrn_flip_intro1 = time_scrn_flip_intro1;




timing_wholesession = toc(wholesession);




