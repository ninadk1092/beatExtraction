# MIR Progress
### Tejas Gokhale

* 2015-10-06:	Algo for finding peaks written.
- Sampling Rate = 44100 Hz
- According to ```London, J. (2004). Hearing in Time: Psychological Aspects of Musical Meter. Oxford: Oxford University Press.``` the fastest perceptual musical separation possible is 100-130ms
- Therefore, I chose 4096 samples ~= 92ms as the downsampling ratio (block size)
- Peak detection algo runs on 8/16/32 such blocks

## *2015-10-07*: The problem of double peaks:
|---|---|--||---|  persists
- Trying to sort it out through windowing

## *2015-10-08*: 	
- Arrived to the conclusion (after listening to many Mozart/Beethoven songs) that peak detection might not yield satisfactory results
- LPF/ HPF approach will work on most, but not on instrumentals (as illustrated by Vivaldi Concerto for Guitar)
- How about we have an all-inclusive MIR device with note/chord identification, beat tracking and instrument identification
- One crude method for getting vibration pattern implemented. 
It involves 
1. computing an array (timestamp_intervals) with the durations/intervals between adjacent peaks
2. computing the histogram (to find which duration has the maximum tendency)
3. Getting mode(hist)
4. Computing the most frequent beat interval from it
5. Using this beat interval to create the vibration pattern with equidistant beats

## *2015-10-09
- Implemented the above algo and tested it on instant_crush.wav
- Gives good results
- However, other songs with non-trivial rhythm and/or multiple instruments playing out of sync will need further investigation.

## *2015-10-12
- For many songs, the drum/percussion although very evident to the human ear is not the peak.
- In the waveform it does appear periodically, but is never recognized as the peak due to other instruments
- Trying an LPF on Smooth Criminal by Michael Jackson
- Fuck LPF HPF. It is useless.
- Found Daniel Ellis' webpage and paper. Seems to be a rigorous research with working MATLAB script

## *2015-10-17

### Remove non-music parts of the audio
1. This is very important as is demonstrated by *'Boris Dancing'* by Ian Anderson.
2. The real question is whether we want the user to manually remove this non-music part such as 
applause (Jethro Tull), 
talk (Dave Matthews), 
initial silence (Nirvana), 
musician's own playing around (John Mayer) or 
complete randomness (David Bowie) 
that presents itself frequently in live music
3. If we want this to happen automatically, can it be done.
4. Can we identify music as a texture (This becomes another research topic)

## What can Dan Ellis' code do
1. Almost everything
2. Although I havent understood it completely, the output is a metronome with very high accuracy even on difficult songs with funky beat
3. However, as I have stated, removal of non-music parts of audio is important.