Contributor(s):
Samuel Recht (samuel.recht_at_gmail.com)
Vincent de Gardelle
Pascal Mamassian

Citation: No associated paper.

Stimulus: This task uses a classical exogenous cueing paradigm (non-predictive cues), with confidence judgment. 
The stimulus can be either clockwise (‘1’) or counter-clockwise (‘-1’). 

Confidence scale: After each decision, participants estimated their confidence in their response (confidence: higher or lower than average?). 
Lower is encoded as ‘0’ and higher as ‘1’. 

Manipulations (see 'procedure' below for more details): 
Validity: the cue was valid (target location, ‘V’) or invalid (non-target location ‘I’), the probability of a valid cue was at chance level (50%).
CTOA: the delay between the cue and the target (5 levels, value in ms)
Cue_position: the cue can appear on the left ('-1') or right ('1') side of the fixation cross. 

Block size: Each block consisted of 560 trials, each participant completed 3 blocks. 

Feedback: No feedback. 

Procedure:
Participants sat in a dark room during the experiment, 57 cm from the screen (CRT monitor, 1920×1080 pixels, 100 Hz refresh rate), 
using a chin rest. Stimuli were generated using Python programming language and the PsychoPy toolbox on a Linux Ubuntu computer. 
Each trial started with the fixation dot being displayed on a grey background for a variable time period (from 300 to 1000 ms). 
At the end of this delay, a cue was flashed during 60ms to induce an automatic, exogenous orienting of visuo-spatial attention at cued location. 
After a variable cue-to-target onset asynchrony (5 different CTOAs conditions: 100, 150, 250, 450 and 850ms), 
both target and distractor were displayed on each side of the fixation dot for 30ms. 
Target was oriented either clockwise or counter-clockwise relative to vertical, and distractor was always horizontal. 
Participants were requested to make a discrimination of the target by mean of a key press (type-I decision).  
Accuracy rates were titrated at the 75% threshold by adjusting target's orientation to each participant using a staircase procedure before the experiment.

In 50% of the trials, the cue appeared at the same location as the target (“valid” condition), and for the remaining trials at distractor location (“invalid” condition). The cue was therefore fully non-predictive, 
and participant had no incentives to orient their attention voluntarily towards the cued location. After their response, participant were requested to report their confidence by mean of a key press (type-II decision): 
is your confidence for this trial higher or lower than average? Each trial was separated by a 200ms inter-trial interval. 
Participants started with 10 practice trials with feedback prior to the calibration part, the later being followed by the main experiment. Participant had a 10-seconds break every 60 trials. 
The design was fully factorial with 5 CTOAs conditions X valid/invalid conditions, with a pseudo randomization per virtual blocks of 20 trials. Note that confidence RTs were not recorded.
 
Stimuli:
Target and distractor consisted in two 2-degrees Gabor patches (spatial frequency: 5 cpd; fixed 12 % contrast) with Gaussian envelop. A 0.4-degrees fixation dot was presented at the center of the screen. They were displayed on each side of the fixation at 5-degrees eccentricity from the center of the screen, on the horizontal midline. The cue consisted in a 0.4 x 0.1 degrees black rectangle displayed 1.5° above the target/distractor center.


