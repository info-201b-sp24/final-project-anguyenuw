import constants
import asyncio
import time
import sys
import re
import sqlite3
import csv
import datetime
import traceback
import aiohttp
from time import sleep
from constants import *
from ossapi import OssapiAsync, UserLookupKey, GameMode, RankingType, MatchEventType, BeatmapsetCompact, Ossapi
from ossapi import User

api = OssapiAsync(CLIENT_ID, API_KEY)
aapi = Ossapi(CLIENT_ID, API_KEY)
db = sqlite3.connect("awesome.db")

#print(api.user(12092800, mode="osu").username)
#print(api.beatmap(221777).id)

# a tournament match is defined as a multiplayer match whose name fits the format
#   name: (team 1) vs (team 2)
tourney_re = re.compile(r".*: \(.*\) [vV][sS]?\.? \(.*\)")

async def scrape_all(mod):
    # range history
    # 105970000 
    # 107000000
    # 108173700
    # 109998000
    # 111300000
    # 113000000
    # 113956974
    start_id = 113000000
    end_id =   113956974
    overwrite = False
    dest = f"csvfiles/mp_data/all_mps_{mod}.csv"
    logdest = f"csvfiles/mp_data/id_abbrs_osu_{mod}.csv"
    # if overwrite: 
    #     with open(dest, "w", newline='') as f:
    #         writer = csv.writer(f)
    #         writer.writerow(("MatchID", 
    #                     "TourneyAbbreviation",
    #                     "Datetime", 
    #                     "MapID", 
    #                     "UserID", 
    #                     "Username", 
    #                     "Mods", 
    #                     "Score"))
    prev_time = datetime.datetime.now()
    for i in range(start_id, end_id):
        if not (i%7 == mod):
            continue
        for attempt in range(10):
            try:
                match_response = await api.match(i)
                match_name = match_response.match.name
                valid_match = re.fullmatch(tourney_re, match_name) != None
                if not valid_match: break
                if (i%100 == 0): print(f"match id {i} success")

                abbr = (match_name[0:match_name.find(":")]).strip()
                await write_csv((abbr, i), logdest)

                users = match_response.users
                user_dict = dict()
                for user in users:
                    user_dict[user.id] = user.username
                # gather all of the maps played in this match
                fid = match_response.first_event_id
                events = match_response.events
                lowest = 999999999999
                all_events = list()
                for event in events:
                    lowest = min(lowest, event.id)
                    if event.detail.type == MatchEventType.OTHER:
                        all_events.append(event)
                while lowest > fid:
                    new_match_response = aapi.match(i, before=lowest)
                    for user in new_match_response.users:
                        user_dict[user.id] = user.username
                    more_events = new_match_response.events
                    for event in more_events:
                        if event.detail.type == MatchEventType.OTHER:
                            all_events.append(event)
                        lowest = min(lowest, event.id)

                # skip if no maps were played
                if not all_events: break

                # first pass - find the most common amount of players per map
                playercounts = dict()
                for event in all_events:
                    if not event.detail.type == MatchEventType.OTHER: continue
                    num_players = len(event.game.scores)
                    if num_players not in playercounts:
                        playercounts[num_players] = 0
                    playercounts[num_players] += 1
                most_common_player_count = max(playercounts, key=playercounts.get)

                # second pass - for each map, for each score, write a csv row about that score 
                #     skip any maps with non-osu gamemodes
                #     skip any deleted maps
                #     skip any maps with unusual player counts
                for event in all_events:
                    game = event.game
                    if not game.mode == GameMode.OSU: continue
                    bm = game.beatmap
                    if not bm: continue
                    if not len(game.scores) == most_common_player_count: continue
                    etime = event.timestamp
                    bm_id = game.beatmap_id
                    for score in game.scores:
                        line = (i, 
                                abbr, 
                                etime, 
                                bm_id, 
                                score.user_id, 
                                user_dict[score.user_id], 
                                score.mods, 
                                score.score)
                        await write_csv(line, dest)
            except ValueError:
                # expired mp link
                if (i%500 == 0): 
                    time = datetime.datetime.now()
                    print(f"id {i} process {mod} fail : took {time - prev_time}")
                    prev_time = time
                break
            except ConnectionError:
                print(f"connection error {i}")
            except TypeError:
                #forbidden mp links
                if (i%30 == 0): print(f"private mp {i}")
                break
            except aiohttp.client_exceptions.ServerDisconnectedError:
                print(f"disconnected {i}")
            except aiohttp.client_exceptions.ContentTypeError:
                print(f"content type error {i}")
            except Exception:
                print(f"unknown problem {i}")
                with open("errorlog.txt", "a", newline='', encoding='utf-8') as f:
                    print(f"\n{datetime.datetime.now()} something went wrong id {i} process {mod}", file=f)
                    traceback.print_exc(file=f)
            else:
                break
            finally:
                if attempt >= 9:
                    with open("errorlog.txt", "a", newline='', encoding='utf-8') as f:
                        print(f"\n{datetime.datetime.now()} attempts exhausted {i} process {mod}", file=f)
                    await write_csv((datetime.datetime.now, i), "missing_mps.csv")
    print(f"process {mod} finished")
        

async def gather_players(mod):
    i = 0
    dest = f"csvfiles/user_data/user_data_{mod}.csv"
    overwrite = True
    if overwrite: 
        line = ("UserID", 
                        "Username",
                        "GlobalRank", 
                        "PP", 
                        "Location",
                        "RegistrationDate")
        await write_csv(line, dest, mode="w")
    prev_time = datetime.datetime.now()
    with open("csvfiles/user_data/all_player_ids.csv", "r", newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            i += 1
            if not (i%7 == mod):
                continue
            for attempt in range(10):
                try:
                    id = int(row[0])
                    user_obj = await api.user(id, mode=GameMode.OSU, key=UserLookupKey.ID)
                    user_stats = user_obj.statistics
                    line = (id, 
                                user_obj.username, 
                                user_stats.global_rank, 
                                user_stats.pp,
                                user_obj.country.name,
                                user_obj.join_date)
                    await write_csv(line, dest)
                    if (i%200 == 0):
                        times = datetime.datetime.now()
                        print(f"process {mod} id {i} : took {times - prev_time}")
                        prev_time = times
                except ValueError:
                    print(f"User {row[0]} not found")
                    break
                except Exception as e:
                    print(f"Error {e}")
                    time.sleep(0.2)
                else:
                    break


async def test():
    idsids = (106688657,106688649,106684920,106647595,
              106669944,106682522,106684444,106643259,
              106686882,106687250,106691174,106670157,
              106658486,106689954,106656606,106687881,
              106794631,106776842,106815981,106790536,
              106799336,106800874,106777737,106793462,
              106786766,106818363,106798741,106852090,
              106803191,106820877,106812248,106904898,
              106917336,106923782,106918548,106923863,
              106916011,106886444,106940816,106928547,
              106958795,106929508,106938605,106967008,
              106944371,106925641,107064293,107056176,
              107053416,107058578,107066561,107078386,
              107082999,107163395,107186478,107202847,107202335,107343096,107474593)
    
    with open('known_IDs.txt','w') as f:
        f.write(str({1,3,(3,5)}))  # set of numbers & a tuple

async def write_csv(obj, filename, mode="a"):
    with open(filename, mode, newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(obj)

async def main():
    func = sys.argv[1]
    if func == "scrape_all":
        async with asyncio.TaskGroup() as tg:
            task0 = tg.create_task(scrape_all(0))
            task1 = tg.create_task(scrape_all(1))
            task2 = tg.create_task(scrape_all(2))
            task3 = tg.create_task(scrape_all(3))
            task4 = tg.create_task(scrape_all(4))
            task5 = tg.create_task(scrape_all(5))
            task6 = tg.create_task(scrape_all(6))
    elif func == "scrape_users":
        async with asyncio.TaskGroup() as tg:
            task0 = tg.create_task(gather_players(0))
            task1 = tg.create_task(gather_players(1))
            task2 = tg.create_task(gather_players(2))
            task3 = tg.create_task(gather_players(3))
            task4 = tg.create_task(gather_players(4))
            task5 = tg.create_task(gather_players(5))
            task6 = tg.create_task(gather_players(6))
        print("hey2")


if __name__ == "__main__":
    asyncio.run(main())            
