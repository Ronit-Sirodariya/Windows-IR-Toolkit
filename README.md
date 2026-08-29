# Windows IR Toolkit

A modular PowerShell-based Windows Incident Response toolkit for collecting,
organizing, correlating, and analyzing host-level forensic evidence.

The toolkit is designed as a learning-oriented security engineering project
that demonstrates practical Windows incident response automation using
PowerShell.

---

## Overview

The Windows IR Toolkit automates the initial collection and organization of
host-level evidence during a Windows incident response investigation.

The toolkit currently collects information related to:

- System information
- Local users
- Running processes
- Network information
- Windows services
- Startup items
- Startup shortcuts
- Registry Run / RunOnce persistence
- Scheduled Tasks
- Windows authentication events
- Sysmon process creation events
- Filesystem metadata
- SHA-256 file hashes

Collected evidence is organized into a timestamped case directory.

The toolkit also provides:

- Persistence/process correlation
- Timeline generation
- Basic analytic findings
- Collection status tracking
- Human-readable investigation reports

---

## Goals

The project was designed around four main goals:

1. Automate repetitive Windows IR collection tasks.
2. Preserve collected evidence in structured formats.
3. Correlate evidence from different sources.
4. Produce an investigation-friendly summary.

The project also serves as a practical PowerShell learning project,
where PowerShell concepts are applied to real incident response workflows.

---

## Architecture

The toolkit follows a modular architecture:

```text
                    IRToolkit.ps1
                         |
                         v
                   Initialization
                         |
                         v
                    Collection
                         |
       +-----------------+------------------+
       |                 |                  |
       v                 v                  v
    System            Processes          Network
    Users             Services           Events
    Filesystem        Persistence        Hashes
       |                 |                  |
       +-----------------+------------------+
                         |
                         v
                     Correlation
                         |
                         v
                      Timeline
                         |
                         v
                      Findings
                         |
                         v
                       Report