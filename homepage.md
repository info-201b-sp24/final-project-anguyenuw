# osu! RME Tournament Rating System


## Data
I collected the data used in this project by querying the [osu! API](https://osu.ppy.sh/docs/index.html) for multiplayer matches and users. 

The first dataset, **Scores**, records 2 million osu!standard scores set in tournament matches from about Jan 1, 2023 to May 20, 2024. The second, **Players**, records information about each of the 20 thousand players who appear in **Scores**, including official rank, calculated RME rating, and location. 

You can download **Scores** [here](https://remui.s-ul.eu/McnTR8ejDw1vAN1.zip) and **Players** [here](https://remui.s-ul.eu/0w8a2i9WshTf30t.zip).

There are 8 variables in **Scores**:
|Variable|Description|
|---|---|
| MatchID | the ID of the tournament match|
| TourneyAbbreviation | the tourney this match was part of|
| Datetime | when the score was set (expressed in UTC)|
| MapID | what map was played |
| PlayerID |who played this map|
| Username | who played this map|
| Mods | which mods the player played with|
| Score | the score the player achieved|

&ensp;

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
|RegistrationDate| when this player joined osu! (in UTC)|
|Games|the number of scores this player set in **Scores**|

**Scores** excludes some warmups and showcase maps, but I couldn't filter all of them.

## Limitations
A fundamental limitation of applying an Elo model to osu! is that, in team-based tournaments, a player is never required to play a map. Only a subset of a team plays at any given time, so if a person doesn't want to play a map, they can have their teammates fill in. 

This means that a player can almost always play to their strengths. In chess, this would be like a player [only challenging opponents that they have a better match-up against](https://en.wikipedia.org/wiki/Elo_rating_system#Selective_pairing), and in online competitive gaming, this would be like being free to dodge any game.

A hypothetical player who always plays well on a single type of map and never plays any other map could theoretically top the rankings, despite most people valuing well-roundedness when talking about the "best" tournament players.