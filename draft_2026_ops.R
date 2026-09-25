# Pull 2026 MLB draftees and rank their pro debut OPS
# Source: MLB Stats API (statsapi.mlb.com)
# Caveat: small samples. Median draftee has ~75 PA. This is noise, not talent.

pkgs <- c("jsonlite", "dplyr", "purrr")
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing) > 0) install.packages(missing)

library(jsonlite)
library(dplyr)
library(purrr)

# 1. Every 2026 draft pick
draft <- fromJSON("https://statsapi.mlb.com/api/v1/draft/2026", flatten = TRUE)
picks <- bind_rows(draft$drafts$rounds$picks) |>
  filter(!is.na(person.id)) |>
  select(pick = pickNumber, player_id = person.id, name = person.fullName,
         pos = person.primaryPosition.abbreviation, org = team.name)

# 2. 2026 minor league hitting, every level (AAA, AA, A+, A, Rookie/Complex)
get_level <- function(sport_id) {
  url <- paste0("https://statsapi.mlb.com/api/v1/stats?stats=season&group=hitting",
                "&season=2026&playerPool=ALL&limit=10000&sportId=", sport_id)
  fromJSON(url, flatten = TRUE)$stats$splits[[1]]
}
pro <- map_dfr(c(11, 12, 13, 14, 16), get_level)

# 3. Join, combine levels, rebuild OPS from counting stats
leaders <- pro |>
  filter(!is.na(team.id)) |>
  inner_join(picks, by = c("player.id" = "player_id")) |>
  group_by(pick, name, pos, org) |>
  summarise(PA = sum(stat.plateAppearances), AB = sum(stat.atBats),
            H = sum(stat.hits), X2B = sum(stat.doubles), X3B = sum(stat.triples),
            HR = sum(stat.homeRuns), BB = sum(stat.baseOnBalls),
            HBP = sum(stat.hitByPitch), SF = sum(stat.sacFlies), .groups = "drop") |>
  mutate(OBP = (H + BB + HBP) / (AB + BB + HBP + SF),
         SLG = (H + X2B + 2*X3B + 3*HR) / AB,
         OPS = OBP + SLG) |>
  filter(PA >= 75) |>
  arrange(desc(OPS))

View(leaders)

