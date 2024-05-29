# osu! RME Tournament Rating System


## Datasets
I collected the data used in this project by querying the [osu! API](https://osu.ppy.sh/docs/index.html) for multiplayer matches and users. 

The first dataset, **Scores**, records 2 million scores set in tournament matches from about Jan 1, 2023 to May 20, 2024. The second, **Players**, records information about each of the 20 thousand players who appear in **Scores**, including official rank, calculated RME rating, and country. 

There are 8 variables in **Scores**:
- Match ID - the ID of the tournament match
- Tourney Abbreviation - the tourney this match was part of
- Datetime - when the score was set (expressed in UTC)
- Map ID - what map was played 
- Player ID - who played this map
- Username - who played this map
- Mods - which mods the player played with
- Score - the score the player achieved

You can download **Scores** [here](https://remui.s-ul.eu/McnTR8ejDw1vAN1.zip) and **Players** [here](https://remui.s-ul.eu/0w8a2i9WshTf30t.zip).


These include all scores set in tourney matches 

## Limitations
Elo-based models 