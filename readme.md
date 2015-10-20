# MIR
## Beat Extraction

```
This code will extract beats from an audio track to be used as vibration pattern in Blee
```

# Brief description of Idea
Two main streams of ideas

1. Metronome/ Beats problem
2. Classification and democratic playlist problem

## Part 1
Metronome has the following use cases
* Dancers
* Singers
* Deaf artists
* Music/Dance Academies

## Part 2
Pubs, bars and restaurants can have the following scene
* You enter and your app shows you what songs are on today's playlist
* The big burly guy in the black tshirt touches you in places you don't like, but also gives you a cool wearable device that vibrates (he's completely into you)

* You demand a particular song via the app (Bro why you no play Summer of 69 bro?)
* or you demand a genre/ tempo via the app(Duuuude, play sth jazzy duuuuude)
* The wearable vibrates according to the groove/rhythm/beat in the song, giving you a musicorgasm

Now lets get to the work that needs to be done

1. Beat tracking (as opposed to metronome tracking)
2. Classification of songs into genre

---**For classification, we can intially have an app which does not in itself classify songs into genres, but searches for it on the internet**
---Windows Media Player actually does the same. Will have to understan how that can be done.
---A quick Google search pointed me to [MusicBrainz](https://www.musicbrainz.org "Website") and their [GitHub Repo](https://github.com/metabrainz/musicbrainz-server)

When the user inputs his preference for "Reggae", the system will display most popular Reggae songs and/or artists for instance *Roots Rock Reggae by Bob Marley*

---**The next stage is automatic classification** 
---Extract features such as ADSR values, beat, music texture (whatever that means), etc and then our old friend ML
