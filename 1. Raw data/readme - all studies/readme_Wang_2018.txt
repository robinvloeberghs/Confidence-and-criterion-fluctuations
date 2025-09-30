Contributor: Shuo Wang (shuo.wang@mail.wvu.edu) and Sai Sun

Citation:
Wang S. 2018. Face size biases emotion judgment through eye movement. Scientific Reports 8: 317

Description of variables:
Stimulus Level: 1: 100% fearful, 2: 70% fearful, 3: 60% fearful, 4: 50% fearful, 5: 40% fearful, 6: 30% fearful, 7: 0% fearful.

Response: 1: judging face as fear, 2: judging face as happy, NaN: missing button press.

RT: Note that this task is not a speeded task, i.e., participants were instructed to press the button after stimulus offset (stimulus duration = 1s).

Confidence scale: 3: very sure, 2: sure, 1: unsure

Condition: face size.

Participants:
Data from twenty-four healthy individuals (16 female, 22.3 ± 3.39 years) are included. Each participant viewed both large faces and small faces. 
There were 252 trials in 3 consecutive blocks (36 trials per morph level) for large faces, and 252 trials in 3 consecutive blocks for small faces. 
The order of blocks of large faces and small faces was counterbalanced.

Detailed description of task and stimuli:
We asked participants to discriminate between two emotions, fear and happiness. We selected faces of four individuals (2 female) each posing fear and happiness expressions from the STOIC database, 
which are expressing highly recognizable emotions. 
Selected faces served as anchors, and were unambiguous exemplars of fearful and happy emotions as evaluated with normative rating data provided by the creators.
 To generate the morphed expression continua for this experiment, we interpolated pixel value and location between fearful exemplar faces and happy exemplar faces
 using a piece-wise cubic-spline transformation over a Delaunay tessellation of manually selected control points. 
 We created 5 levels of fear-happy morphs, ranging from 30% fear/70% happy to 70% fear/30% happy in a step of 10%. 
 Low-level image properties were equalized by the SHINE toolbox (The toolbox features functions for specifying the (rotational average of the) Fourier amplitude spectra, 
 for normalizing and scaling mean luminance and contrast, and for exact histogram specification optimized for perceptual visual quality). 

A face was presented for 1 second followed by a question prompt asking participants to make the best guess of the facial emotion, 
either by pushing the left button (using left hand) to indicate that the face was fearful, or by pushing the right button (using right hand) to indicate that the face was happy. 
Participants had 2 seconds to respond, otherwise the trial was aborted and there was a beep to indicate time-out. 
Participants were instructed to respond as quickly as possible after stimulus offset. 
After emotion judgment and a 500 ms blank screen, participants were asked to indicate their confidence of judgment, 
by pushing the button ‘1’ for ‘very sure’, ‘2’ for ‘sure’ or ‘3’ for ‘unsure’. This question also had 2 seconds to respond. 
No feedback message was displayed either questions. An inter-trial-interval (ITI) was jittered between 1 to 2 seconds. 
The order of faces was completely randomized for each participant. Participants practiced 5 trials before the experiment to familiarize themselves with the task. 
In the end, the overall percentage of “correct answers” (calculated by the morph levels) was displayed to participants as a motivation.

