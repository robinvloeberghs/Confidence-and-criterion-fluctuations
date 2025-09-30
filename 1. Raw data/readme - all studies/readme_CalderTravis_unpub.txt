## Contributor of data
Joshua Calder-Travis, j.calder.travis@gmail.com

## Citation
Calder-Travis, J. M., Charles, L., Bogacz, R., & Yeung, N. (2020). Bayesian confidence in optimal decisions. PsyArXiv. https://doi.org/10.31234/osf.io/j8sxz

## Stimulus
Participants were presented with two clouds of dots. Every 50ms the number of dots in the two clouds was drawn independently from two truncated normal distributions. 
The mean of one of these distributions was greater than the mean of the other. Participants were asked to report which cloud they thought contained more dots on average. 
In the dataset, stimulus "1" indicates that the distribution for the left-hand cloud had a greater mean, and "2" indicates the distribution for the right-hand cloud had the greater mean.

## Confidence scale
Participants reported confidence by clicking along a semi-circular arc. The left hand side of the arc was labelled "Definitely wrong", the centre "Don't know", and the right hand side "Definitely correct". Note that the left half of the scale was for cases where the participant thought they were incorrect. Participants were encouraged to use the whole range of the scale. The selected point on the arc was converted to a value between -90 and 90 ("definitely wrong" to "definitely correct", with 0 at "don't know").

## Manipulations
Each block in the experiment was either a "free response" block or a "forced response" block. In a free response block participants could respond whenever they wanted, but were asked to be "as accurate and fast as possible". 
In a forced response block participants could only respond when the stimuli disappeared from the screen and a red cross appeared. At this point they had 1 second to respond. 
The "Condition" variable in the dataset is 0 for free response trials, and 1 for forced response trials.

## Block size
40 trials.

## Feedback
Trial-to-trial feedback was not included, however, at the end of each block participants were told how many trials they had got right. 
Additionally, participants were told their highest scores for a free response, and a forced response block, so far.

## NaN fields
NaNs can occur for several reasons. (A) If participants responded before the stimulus appeared the trial was abandoned. 
(B) In forced response trials, if a participant responded too early (before the stimulus cleared and the red cross appeared), or too late (outside the 1 second window) the trial was abandoned. 

## Subject population
Participants in the age ranges 18-25, and 26-35 took part.

## Response device
Participants responded on the mouse with a left or right button click. They then used the mouse to report their confidence.

## Experiment setting
Individual booths in the Oxford University Department of Experimental Psychology were used for the experiment.

## Training
Participants completed one training block for each condition prior to the experiment. 

## Experiment code
The code will be made available on publication of the primary research project associated with the data.

## Experiment dates
Data was collected in May and June of 2018.

## Stimulus details
On each 50ms frame the number of dots in each cloud was randomly and independently drawn from two truncated normal distributions. The means of these two distributions (prior to truncation) were 90 dots apart, and each had a standard deviation of 220 dots (prior to truncation). The mid-point between the means of the two distributions was itself randomly selected on a trial-by-trial basis, and this reference value is shown in the dataset under Stim_ref.  

## Additional database fields
Dot_diff: This is a measure derived from the stimulus shown on a particular trial. The total number of dots shown in every frame up until the response is summed, separately for the left and the right hand box. Then the sum for the left box is subtracted from the sum for the right.
Stim_duration: The amount of time the stimulus was presented for. This will typically be less than the response time in forced response trials.