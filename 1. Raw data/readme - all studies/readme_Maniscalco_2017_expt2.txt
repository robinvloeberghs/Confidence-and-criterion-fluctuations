Contributor
-----------
Brian Maniscalco
bmaniscalco@gmail.com


Citation
--------
Maniscalco, B., McCurdy, L. Y., Odegaard, B., & Lau, H. (2017). Limited Cognitive Resources Explain a Trade-Off between Perceptual and Metacognitive Vigilance. The Journal of Neuroscience, 37(5), 1213–1224. https://doi.org/10.1523/JNEUROSCI.2271-13.2016

Experiment 2


Experiment details
------------------

(for full details, see the paper cited above)

Circular patches of white noise were presented to the left and right of fixation for 33 ms. 
A sinusoidal grating was embedded in either the left or right patch of noise. 
The subject's task was to indicate which patch contained the grating, left or right, with a keypress.

After entering the stimulus discrimination response, subjects rated confidence in the accuracy of their response on a scale of 1 to 4, with 4 being highest. 
No absolute meaning was attributed to the numbers on the scale, but rather, 
they indicated relative levels of confidence for stimulus judgments made in this particular experiment. 
Thus, subjects were encouraged to use all parts of the confidence scale at least some of the time. 

If subjects did not enter response or confidence within 5 seconds of stimulus offset, the next trial commenced automatically. 
However, if subjects entered both response and confidence, then the next trial was initiated shortly after entry of confidence. 
In this way, the pacing of the trials depended on subject RT.

Blocks of the visual perception task were interleaved with blocks of a memory task. 
Each subject completed two experimental sessions on 2 consecutive days.

On day 1, subjects completed two practice blocks of the visual task, a calibration block for the visual task, 
and two blocks of the visual task consisting of 102 trials each. 
Subjects received accuracy feedback on each trial during practice blocks 
(high pitched tone following correct responses, low pitched tone for incorrect or missing responses).

On day 2, subjects completed three more blocks of the visual task, using the stimulus settings acquired from the calibration block on day 1. 
In total across the 2 d, data were collected for 510 trials (five blocks of 102 trials each). There were no experimental manipulations.

In the main experiment, 3 levels of grating contrast were presented based on the results of the calibration block. 
Grating contrast varied pseudo-randomly across trials.

The data included here correspond to the main experiment only (i.e. practice and calibration data are not included).

Data were collected for n=41 subjects. No subjects were excluded from analysis in the manuscript.

[Data from the memory task are not included here; comparison of visual and memory task performance was explored by 

McCurdy LY, Maniscalco B, Metcalfe J, Liu KY, De Lange FP, Lau H (2013) Anatomical coupling between distinct metacognitive systems for memory and visual perception. J Neurosci 33:1897–1906. ]


Data coding
-----------

* Subj_idx
subject number

* Stimulus
0 --> grating was on the left
1 --> grating was on the right

* Response
0 --> subject responded "grating was on the left"
1 --> subject responded "grating was on the right"
NaN --> subject failed to enter response within 5 sec of stimulus offset

* Confidence
1 - 4 --> subject entered confidence 1 - 4
NaN --> subject failed to enter confidence within 5 sec of stimulus offset

* RT_dec
number --> seconds between stimulus onset and entry of response
NaN --> subject failed to enter response within 5 sec of stimulus offset

* RT_conf
number --> seconds between entry of response and entry of confidence
NaN --> subject failed to enter confidence within 5 sec of stimulus offset

* Contrast
Michelson contrast of grating

* ContrastLevel
ordinal contrast level. 1 --> low, 2 --> medium, 3 --> high.

* BlockNumber
block of trials in which current trial was contained