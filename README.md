# home-run-leaderboard
Provides an up-to-the-minute leaderboard of my family's MLB HR draft, where the team w/ the most HR from their top-5 players wins at the end of the year. Includes a graph to show progress since our June Draft Day.

Published as a shiny.io app at https://jacksonroah.shinyapps.io/hr_derby_2024/

Pulls live json data of every MLB HR from https://zuriteapi.com/homers/api/homeruns/?format=json&year=2024

Creates a leaderboard of all MLB player's HRs for the 2024 season. I input by hand the list of players on each of the 4 drafted teams, and the leaderboard then filters to be only those who are one of the 4 teams. 

Then I created two types of leaderboards: The *overall* and the *team* leaderboard. 

At the top of the page, you can find the current ranking, where each team is in order of their Top 5 players' HR totals on the season. We also drafted 2 extra players as back ups, but their totals do not count. I threw the Team Total column on the end so we could see who had the deepest bench. 

Underneath, you can see each team's individual player rankings on their team, along with their home run totals on the season. If they are outside the top 5 on their team, they are greyed out, as their stats do not count towards the overall leaderboard.

Finally, at the bottom, becuase we drafted in June, I was curious to see how teams would progress as the season went on, but also how they were performing before we drafted. When we drafted, we decided to count the players' current home run totals, instead of only counting who hit the most post-draft. The total season chart displays how a team performed before draft day, well as after.

I designed this specifically for mobile use, as I knew all teams would only look at the leaderboard on their phones, sorry that the Desktop view is rather ugly.  
