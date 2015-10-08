# Progress
### Tejas Gokhale

* 2015-10-06:	Algo for finding peaks written.
- Sampling Rate = 44100 Hz
- According to ```London, J. (2004). Hearing in Time: Psychological Aspects of Musical Meter. Oxford: Oxford University Press.``` the fastest perceptual musical separation possible is 100-130ms
- Therefore, I chose 4096 samples ~= 92ms as the downsampling ratio (block size)
- Peak detection algo runs on 8/16/32 such blocks

* 2015-10-07: The problem of double peaks: ```|---|---|--||---|``` persists
- Trying to sort it out through windowing

* 2015-10-08: 	
- Arrived to the conclusion (after listening to many Mozart/Beethoven songs) that peak detection might not yield satisfactory results
- LPF/ HPF approach will work on most, but not on instrumentals (as illustrated by Vivaldi Concerto for Guitar)