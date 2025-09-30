Contributors
Marta Siedlecka (siedlecka.marta@gmail.com)
Marcin Koculak (koculak.marcin@gmail.com)


Citation
Siedlecka, M., Koculak, M., & Paulewicz, B. (2021). Confidence in action: differences between perceived accuracy of decision and motor response. Psychonomic Bulletin & Review, 1-9.

Stimulus
Two grids of dots presented simultaneously on the left and right of the center of the screen. In each trial stimulus was displayed for 167ms (10 frames on a 60Hz monitor). Stimulus was dynamically generated for each trial, 
so patterns of dots on the grid were random.
Participants had to decide on which side there are more dots, which is reflected in the Stimulus column (1 - more dots on the left, 2 - more on the right). Columns L_dots and R_dots code the exact number of dots on each side.

Confidence scale
Typical four-point Confidence Rating was used (from 1 to 4). Additionally, participants could instead report making a mistake while assessing the number of dots, by pressing a dedicated key. 
Confidence column has five possible codes (1,2,3,4 - for CR and NaN for reporting a mistake).

Manipulations
Participants were instructed at the beginning of the experiment to press a space bar when they will decide there is more dots on the designated side of the screen. 
Instruction pointed either to left side or right side (this was counter-balanced between participants). 
For example, in the first block participant was instructed to press the space bar when there will be more dots on the left side. 
If more dots would be on the right, no action was required. 
In the second block, the instruction was reversed - press space bar when more dots on the right, if more on the left, do nothing.

There were three difficulty levels of the stimuli:
- easy - dots ration 55:45 - code 1
- medium - dots ratio 52:48 - code 2
- hard - dots ratio 51:49 - code 3

Block size
There were two blocks - each with a different instruction (as mentioned in the section above).
Each of those blocks was composed of 13 mini blocks of 30 trials each (summing up to 390 trials per big block).

Feedback
Participants received a visual feedback about their accuracy and percentage of space bar presses after each mini block (30 trials).
They were instructed to perform as accurate as possible while maintaining around 50% of space bar presses.

NaN fields
NaN's in Response column are predominantly an effect of participants deciding not to respond (as explained in the Manipulations section).
On top of that responses to stimuli were only recorded for 1000ms after the stimulus. Similarly, confidence responses were recorded for 2000ms. After this time the procedure progressed to the next part.
Finally, NaN for confidence means that subjects reported making an error with the Response.

Subject population
Students of Jagiellonian Universtiy (Cracow, Poland) recruited through a dedicated system.

Response device
Computer keyboard.

Experiment goal
Testing hypotheses about influence of motor response on metacognition.

Main result
In prep.

Experiment dates
Data were collected between April and May, 2019.

Location of data collection
Institute of Psychology, Jagiellonian Universtiy (Cracow, Poland).

Language of data collection
Polish.

Category
Perception.

--------------------------------------------

Fields in the .csv file: 

'Subj_idx'  	: subject identification number (1 to 54).
'Gender'	: participant's gender as described by themselves.
'Age'		: participant's age as described by themselves.
'Fix_time'	: duration of the fixation cross before stimulus presentation.
'Block'		: number of the block as described in Manipulations.
'Stimulus'  	: 1 - more dots on the left; 2 - more dots on the right.
'Response'  	: 1 - space bar, NaN - no response.
'RT_dec'	: reaction time of the response, NaN where no reaction was made.
'Conf_key'	: keyboard key used to respond to the question about confidence.
'RT_conf' 	: reaction time for the confidence decision.
'Trial'		: number of the trial in the block (block as in column Block).
'L_dots' 	: number of dots presented on the left side of the screen.
'R_dots' 	: number of dots presented on the right side of the screen.
'Condition'	: 1 - press space bar if more dots on the left; 2 - press space when more dots on the right.
'Accuracy'	: 0 - an error was made; 1 - correct response.
'Confidence'	: 1,2,3,4 - CR scale; NaN - report of making an error with the Response.
'Difficulty'	: 1 - easy; 2 - medium; 3 - hard.