# Automatic fixture updates

The Cyprus FA announces kickoff times one or two matchdays at a time, so most of
`APOEL_calendar.ics` starts life as all-day placeholder events that get exact
times filled in later. This directory automates that.

## What runs

`update-fixtures.cmd` is registered as a Windows scheduled task named
**APOEL calendar fixtures**, running daily at 14:00. It pulls the latest commit,
then hands `update-fixtures-prompt.md` to Claude Code in headless mode. Claude
reads cfa.com.cy, fills in any newly announced dates, times and venues, and
commits and pushes only if something actually changed.

`StartWhenAvailable` is set, so a run missed because the machine was off happens
at the next opportunity instead of being skipped.

## Tools it is allowed to use

The task grants a deliberately narrow set: read and edit files, fetch
`www.cfa.com.cy`, and the handful of git subcommands needed to commit and push.
It cannot run arbitrary shell commands.

## Logs

One file per day in `logs/` (gitignored). Each records which articles were
checked and what changed, which is the first place to look if the calendar
stops updating.

## Managing the task

    # see it / check the next run
    Get-ScheduledTask -TaskName 'APOEL calendar fixtures'
    Get-ScheduledTaskInfo -TaskName 'APOEL calendar fixtures'

    # run it now
    Start-ScheduledTask -TaskName 'APOEL calendar fixtures'

    # turn it off / back on
    Disable-ScheduledTask -TaskName 'APOEL calendar fixtures'
    Enable-ScheduledTask  -TaskName 'APOEL calendar fixtures'

The script locates `claude.exe` inside the newest installed VS Code extension
directory, so extension upgrades do not break it. Uninstalling the extension
does — the log will say the CLI was not found.
