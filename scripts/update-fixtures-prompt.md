You maintain `APOEL_calendar.ics`, an iCalendar file of APOEL Nicosia's fixtures for the 2026-27 Cyprus First Division ("Cyprus League by Stoiximan"). It is at the root of this repository. IT USES CRLF LINE ENDINGS — preserve them exactly.

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
- Never change UID, DTSTAMP or SUMMARY. Never reorder, add or remove events.
- Leave alone any match CFA has not yet announced.
- Be conservative: if an article is ambiguous about which match or what time, leave that event as a placeholder rather than guessing. A missed update is cheap; a wrong kickoff time makes the owner miss a match.

## Finishing

- Check with `git diff` that no unrelated lines changed and that the file is still valid iCalendar.
- If nothing changed, make NO commit and stop. Do not create an empty commit.
- If something changed, commit with a message naming exactly which matchdays and matches were filled in (and any reschedules), then `git push origin main`.
