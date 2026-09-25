# 2026 MLB Draft: Pro Debut OPS

Pulls every 2026 MLB draft pick and their 2026 minor league hitting lines from the MLB Stats API, then ranks draftees by OPS.

## How it works
- Draft picks come from the `/draft/2026` endpoint.
- Hitting stats come from the `/stats` endpoint for every minor league level (AAA through Rookie/Complex).
- Players who played at more than one level get their counting stats summed, then OBP and SLG are rebuilt from the totals. You can't average OPS across levels.
- Minimum 75 PA.

## Read this before the leaderboard
This is not a talent ranking. Of 613 picks, 149 had pro plate appearances in 2026. The median was about 75 PA and the max was 137. OPS at that sample size is mostly noise, and it isn't adjusted for level or league.

## Run it
Open `draft_2026_ops.R` in RStudio and click Source. Missing packages install automatically.

## Next
Working question: TBD
