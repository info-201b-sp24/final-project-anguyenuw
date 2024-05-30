# osu! RME Tournament Rating System

## Purpose
osu

## Data
I collected the data used in this project by querying the [osu! API](https://osu.ppy.sh/docs/index.html) for multiplayer matches and users. 

The first dataset, **Scores**, records 2 million osu!standard scores set in tournament matches from about Jan 1, 2023 to May 20, 2024. The second, **Players**, records information about each of the 20 thousand players who appear in **Scores**, including official rank, calculated RME rating, and location. You can download **Scores** [here](https://remui.s-ul.eu/McnTR8ejDw1vAN1.zip) and **Players** [here](https://remui.s-ul.eu/0w8a2i9WshTf30t.zip).

There are 8 variables in **Scores**:
|Variable|Description|
|----|----|
| MatchID | the ID of the tournament match|
| TourneyAbbreviation &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | the tourney this match was part of|
| Datetime | when the score was set (expressed in UTC)|
| MapID | what map was played |
| PlayerID |who played this map|
| Username | who played this map|
| Mods | which mods the player played with|
| Score | the score the player achieved|

&nbsp;

There are 9 variables in **Players**:
|Variable|Description|
|-|-|
| UserID    | this player's ID |
| Username | this player's username|
| GlobalRank  | this player's official rank|
| PP         | this player's total performance points|
| RMERanking | this player's rank in the RME system|
| RME        | this player's RME rating|
| Location | the country displayed on this player's profile |
|RegistrationDate &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | when this player joined osu! (in UTC)|
|Games|the number of scores this player set in **Scores**|

## RME Calculation
To calculate RME, I used the [PlayerRatings](https://cran.r-project.org/package=PlayerRatings) R package created by Alec Stephenson and Jeff Sonas


## Limitations
A fundamental limitation of applying an Elo model to osu! is that, in team-based tournaments, a player is never required to play a map because only a subset of the team plays at any given time. This means that a player will usually play to their strengths. This is very different from what the Elo model assumes, which is that players will have random, normally distributed performance. To give some analogies, in chess this would be like a player [only challenging opponents that they have a better match-up against](https://en.wikipedia.org/wiki/Elo_rating_system#Selective_pairing), and in online competitive gaming, this would be like being free to dodge any game.

The **Scores** dataset excludes some warmups and showcase maps, but I was not able to filter all of them.