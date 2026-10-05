You maintain `APOEL_calendar.ics`, an iCalendar file of APOEL Nicosia's fixtures for the 2026-27 Cyprus First Division ("Cyprus League by Stoiximan") and the Cyprus Cup ("Κύπελλο Coca-Cola"). It is at the root of this repository. IT USES CRLF LINE ENDINGS — preserve them exactly.

## File format

Each match is a VEVENT in one of two states.

CONFIRMED (exact date and kickoff known):

    DTSTART:20260829T190000
    DTEND:20260829T210000

PLACEHOLDER (date provisional, kickoff unknown) — stored as an all-day event:

    DTSTART;VALUE=DATE:20261018
    DTEND;VALUE=DATE:20261019

SUMMARY is always "Home - Away".

## Your task

1. Fetch https://www.cfa.com.cy/ and find news articles whose title begins with "Cyprus League by Stoiximan" and concerns "το πρόγραμμα" (the schedule) of one or more αγωνιστικές (matchdays). Their links look like `/Gr/news/NNNNN`. Check the several most recent such articles — schedules are announced one or two matchdays at a time, so a recent article may cover matchdays that are already filled in.

2. From each article, extract every match involving ΑΠΟΕΛ: the date, the kickoff time, and the stadium.

3. For each APOEL match found, find the matching VEVENT by its two team names in SUMMARY and write in the exact date and time.

## Team name mapping (Greek on cfa.com.cy → as written in SUMMARY)

| Greek | SUMMARY |
|---|---|
| ΑΠΟΕΛ | APOEL |
| ΑΕΚ (Λάρνακας) | AEK |
| ΑΕΛ | AEL |
| Ανόρθωση / Ανόρθωσις | Anorthosis |
| Απόλλων | Apollon |
| Νέα Σαλαμίνα | Nea Salamina |
| Πάφος FC | Pafos |
| ΑΛΣ Ομόνοια 29Μ | ALS Omonoia 29M |
| Ομόνοια Αραδίππου | Omonoia Aradippou |
| Άρης (Λεμεσού) | Aris |
| Ομόνοια (Λευκωσίας) | Omonoia Nicosia |
| Κρασάβα (ΕΝΥ Ιδαλίου) | Krasava |
| Καρμιώτισσα | Karmiotissa |
| Ολυμπιακός | Olympiakos |

Ομόνοια Λευκωσίας, ΑΛΣ Ομόνοια 29Μ and Ομόνοια Αραδίππου are three DIFFERENT clubs. Do not confuse them.

## Stadium names already used in the file

GSP, AEK Arena, Antonis Papadopoulos, Alphamega, Stelios Kyriakidis, Vitex Ammochostos, Katokopia (Glafkos Kliridis), Pafiako.

"Στέλιος Κυριακίδης" and "Παφιακό" are the same ground in Paphos; the file spells it `Stelios Kyriakidis` for Pafos home games and `Pafiako` for Karmiotissa home games. Leave that as it is — do not normalise it.

## Rules

- To convert a placeholder: replace its two `DTSTART;VALUE=DATE` / `DTEND;VALUE=DATE` lines with `DTSTART:<YYYYMMDD>T<HHMMSS>` and a `DTEND` exactly two hours later. No TZID and no trailing `Z` — floating local time, matching the existing confirmed events.
- Update LOCATION when the announced stadium differs, reusing the file's existing spelling for that ground where one exists.
- If an ALREADY-CONFIRMED event's date or time differs from the newest announcement (a postponement or reschedule), update it too, and say so explicitly in the commit message.
- Never change UID, DTSTAMP or SUMMARY. Never reorder, add or remove events (except adding cup matches — see below).
- Leave alone any match CFA has not yet announced.
- Be conservative: if an article is ambiguous about which match or what time, leave that event as a placeholder rather than guessing. A missed update is cheap; a wrong kickoff time makes the owner miss a match.

## Cup matches (Κύπελλο Coca-Cola)

League events exist from the start, but cup events do not: the cup is a knockout, and APOEL's next opponent is only known after each draw (κλήρωση). So for the cup you ADD events, which is the one exception to "never add events" above.

1. On https://www.cfa.com.cy/ also look for recent articles whose title begins with "Κύπελλο Coca-Cola" — round schedules ("Πρόγραμμα αγώνων ...") and draws ("Κλήρωση ..."). The first-phase schedule was news 53825.

2. For every APOEL cup match that has an announced DATE and is not yet in the file, add a VEVENT:

       BEGIN:VEVENT
       UID:apoel-2026-27-cup-<round>@panagiotis
       DTSTAMP:<today's date>T000000Z
       SUMMARY:<Home> - <Away> (Cup)
       DTSTART:...
       DTEND:...
       LOCATION:...
       END:VEVENT

   - `<round>`: `r1` (Α' φάση), `r2` (Β' φάση), `r3` (Γ' φάση), `qf` (προημιτελικά), `sf` (ημιτελικά), `final`. For a two-legged round, add `-leg1` / `-leg2` (e.g. `qf-leg1`). Look at the existing cup UIDs before choosing — never create a duplicate UID.
   - Same SUMMARY team spellings as the league, plus the ` (Cup)` suffix. Lower-division opponents are not in the mapping table: transliterate the Greek name simply (e.g. Χαλκάνορας → Chalkanoras) and drop prefixes like "ΑΕ"/"ΑΟ" only if the league table does the same.
   - Kickoff time known → confirmed form (2 hours long). Only the date known → all-day placeholder form; fill in the time later, like a league placeholder.
   - LOCATION: the stadium the article names. CFA cup schedules usually name a stadium only when it is NOT the home team's usual ground; when none is named, use the home team's ground as spelled in the file (APOEL → `GSP`). For a lower-division home team with no known ground, leave LOCATION empty rather than guessing.
   - Insert the new VEVENT in date order among the existing events (right before the first event that starts later).

3. A draw that names APOEL's opponent but no date is NOT enough — wait for the schedule article with the date.

4. If APOEL is eliminated, simply add nothing further. Never delete a cup event that has been played.

5. Cup events you already added follow the same rules as league events afterwards: fill in a missing time, and update date/time/venue on a reschedule (say so in the commit message).

## Finishing

- Check with `git diff` that no unrelated lines changed and that the file is still valid iCalendar.
- If nothing changed, make NO commit and stop. Do not create an empty commit.
- If something changed, commit with a message naming exactly which matchdays and matches were filled in (and any reschedules), then `git push origin main`.
