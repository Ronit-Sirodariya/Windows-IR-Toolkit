# Windows IR Toolkit

A modular PowerShell-based Windows Incident Response toolkit for automated
host triage, evidence collection, persistence investigation, timeline
generation, basic detection, and investigation reporting.

This project was built as a practical cybersecurity and PowerShell learning
project, with the goal of turning individual Windows forensic collection
techniques into a repeatable incident-response workflow.

---

## Overview

During a Windows incident investigation, responders may need to collect
evidence from many different sources, including:

- Operating system information
- Local user accounts
- Running processes
- Network information
- Windows services
- Persistence mechanisms
- Authentication events
- Sysmon telemetry
- Filesystem metadata
- File hashes

Collecting these artifacts manually can be repetitive and inconsistent.

The Windows IR Toolkit automates the initial host-level triage process and
organizes collected evidence into a timestamped investigation directory.

The toolkit uses a modular architecture where individual PowerShell modules
are responsible for specific collection or analysis tasks, while
`IRToolkit.ps1` acts as the main orchestration script.

---

# Features

## System Information

Collects information about the Windows operating environment, including:

- Computer name
- Current user
- PowerShell version
- Administrator status
- Windows operating system information
- Windows version/build information
- System boot information

---

## Local User Collection

Collects local Windows user information such as:

- Username
- Account status
- Last logon information
- Password requirements

This information can help identify unexpected, disabled, or suspicious
local accounts during an investigation.

---

## Process Collection

Collects information about currently running processes, including:

- Process name
- Process ID
- Parent process ID
- Executable path
- Command line

Parent/child process relationships can provide useful context when
investigating suspicious execution.

---

## Network Collection

Collects available network information from the investigated Windows host.

The collected information provides current-state network context that can
support further investigation.

---

## Windows Service Collection

Collects Windows service information that can be examined for:

- Unexpected services
- Suspicious executable paths
- Unusual service configurations
- Potential service-based persistence

---

# Persistence Investigation

The toolkit investigates several common Windows persistence mechanisms.

### Startup Folders

Examines Windows Startup locations for programs that execute when a user
logs in.

### Startup Shortcuts

Analyzes startup shortcuts and extracts information such as:

- Shortcut target
- Arguments
- Working directory
- Shortcut metadata

### Registry Run / RunOnce

Examines commonly used Registry persistence locations:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Run
HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce

HKLM\Software\Microsoft\Windows\CurrentVersion\Run
HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce
```

### Scheduled Tasks

Collects scheduled task information that can be examined for suspicious
execution and persistence.

### Persistence / Process Correlation

The toolkit performs basic correlation between startup shortcut targets
and currently running processes.

Example:

```text
Startup Shortcut
       |
       v
Target Executable
       |
       v
Running Process
       |
       v
Potential Correlation
```

This moves the toolkit beyond simple artifact collection toward basic
evidence correlation.

---

# Windows Event Logs

The toolkit collects selected Windows authentication-related events.

These events can provide useful investigation context for:

- Successful logons
- Failed logons
- Authentication activity
- Potential brute-force activity
- Suspicious account usage

The availability of event data depends on the Windows logging
configuration of the investigated system.

---

# Sysmon

When Sysmon is installed and configured, the toolkit collects available
Sysmon process-creation telemetry.

This can provide additional context such as:

- Process creation
- Parent process relationships
- Executable paths
- Command-line information

Sysmon is optional.

If Sysmon telemetry is unavailable, the toolkit treats it as an unavailable
evidence source rather than assuming that the system is clean.

---

# Filesystem Collection

The filesystem collector gathers metadata from the configured collection
scope.

This information can be used to identify:

- Recently created files
- Recently modified files
- Files in suspicious locations
- Files requiring further investigation

---

# File Hashing

The toolkit calculates SHA-256 hashes for collected files where possible.

SHA-256 values can help:

- Identify files consistently
- Compare files across systems
- Support malware investigation
- Support IOC matching
- Provide a cryptographic identifier for collected files

### Live-System Limitation

Some files may be locked by running processes or otherwise unavailable
during live collection.

Therefore, a hashing failure does not necessarily indicate a failure of
the entire collection process.

The toolkit is designed to continue processing other files when individual
files cannot be hashed.

---

# Timeline Generation

The toolkit combines timestamped information from multiple evidence sources
into a chronological timeline.

Conceptually:

```text
Filesystem
     |
Processes
     |
Event Logs
     |
Sysmon
     |
Persistence
     |
     v
  Timeline
     |
     v
Chronological Investigation View
```

A timeline allows an investigator to examine events chronologically rather
than reviewing every evidence source independently.

---

# Findings & Analytics

The toolkit contains a basic analytic layer that examines collected
evidence and produces investigation findings.

For example, processes executing from temporary directories may be flagged
for review.

A finding should be treated as an **investigation lead**, not automatic
proof of malicious activity.

Future versions will expand the analytic layer with additional rules and
cross-source correlation.

---

# Investigation Report

The toolkit generates a human-readable report containing information such
as:

- Case information
- Collection summary
- Findings
- Timeline statistics
- Output directory

The report provides a quick overview of the collection and analysis process.

---

# Architecture

The toolkit follows a modular PowerShell architecture.

```text
                         IRToolkit.ps1
                              |
                              v
                    Environment Initialization
                              |
                              v
                     Case Directory Creation
                              |
                              v
                     Evidence Collection
                              |
       +----------+-----------+-----------+----------+
       |          |           |           |          |
       v          v           v           v          v
    System      Users     Processes    Network    Services
       |          |           |           |          |
       +----------+-----------+-----------+----------+
                              |
                    +---------+---------+
                    |                   |
                    v                   v
               Persistence          Event Logs
                    |                   |
                    +---------+---------+
                              |
                              v
                           Sysmon
                              |
                              v
                        Filesystem
                              |
                              v
                           Hashes
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
```

The main script handles orchestration, while individual modules implement
specific collection and analysis functionality.

---

# Project Structure

```text
Windows-IR-Toolkit/
│
├── IRToolkit.ps1
│
├── modules/
│   ├── Logging.ps1
│   ├── System.ps1
│   ├── Users.ps1
│   ├── Processes.ps1
│   ├── Network.ps1
│   ├── Services.ps1
│   ├── Persistence.ps1
│   ├── EventLogs.ps1
│   ├── Sysmon.ps1
│   ├── FileSystem.ps1
│   ├── Hashes.ps1
│   ├── Timeline.ps1
│   ├── Findings.ps1
│   └── Report.ps1
│
├── output/
│   └── .gitkeep
│
├── .gitignore
└── README.md
```

---

# Module Responsibilities

| Module | Responsibility |
|---|---|
| `Logging.ps1` | Logging and collection-status functionality |
| `System.ps1` | Windows system information |
| `Users.ps1` | Local user collection |
| `Processes.ps1` | Running process collection |
| `Network.ps1` | Network information |
| `Services.ps1` | Windows service collection |
| `Persistence.ps1` | Windows persistence investigation |
| `EventLogs.ps1` | Authentication event collection |
| `Sysmon.ps1` | Sysmon telemetry collection |
| `FileSystem.ps1` | Filesystem metadata collection |
| `Hashes.ps1` | SHA-256 file hashing |
| `Timeline.ps1` | Timeline construction |
| `Findings.ps1` | Basic analytic rules |
| `Report.ps1` | Investigation report generation |

---

# Requirements

## Operating System

- Windows 10 or later recommended

## PowerShell

- Windows PowerShell 5.1 or PowerShell 7+

## Privileges

Administrator privileges are recommended because some Windows evidence
sources require elevated access.

## Optional Components

### Sysmon

Sysmon is optional.

When installed and configured, Sysmon provides additional process-creation
telemetry that can improve investigation context.

---

# Usage

Clone the repository:

```powershell
git clone https://github.com/Ronit-Sirodariya/Windows-IR-Toolkit.git
```

Navigate into the project:

```powershell
cd Windows-IR-Toolkit
```

Run the toolkit:

```powershell
.\IRToolkit.ps1
```

The toolkit creates a timestamped investigation directory under:

```text
output/
```

Example:

```text
output/
└── IR_HOSTNAME_20260829_140154/
```

---

# Output Structure

Each execution creates a separate case directory:

```text
IR_HOSTNAME_TIMESTAMP/
│
├── Metadata/
├── System/
├── Users/
├── Processes/
├── Services/
├── Network/
├── Persistence/
├── EventLogs/
├── Sysmon/
├── Filesystem/
├── Hashes/
├── Timeline/
├── Findings/
└── Report/
```

Separating each collection run into its own case directory prevents
evidence from different investigations from being mixed together.

---

# Evidence Flow

The toolkit follows this general workflow:

```text
Windows Host
     |
     v
Collection Modules
     |
     v
Structured Evidence
     |
     +-------------------+
     |                   |
     v                   v
Correlation          Timeline
     |                   |
     +---------+---------+
               |
               v
            Findings
               |
               v
             Report
```

The original collected evidence is kept separate from derived artifacts
such as timelines and analytic findings.

---

# Error Handling

The toolkit is designed to continue collecting available evidence when an
individual evidence source is unavailable.

For example:

```text
System       → SUCCESS
Users        → SUCCESS
Processes    → SUCCESS
Network      → SUCCESS
Services     → SUCCESS
Persistence  → SUCCESS
Event Logs   → SUCCESS
Sysmon       → UNAVAILABLE
Filesystem   → SUCCESS
Hashes       → PARTIAL
```

An unavailable evidence source does not automatically mean that the system
is clean.

It means that the corresponding telemetry could not be collected or was
not available.

---

# Forensic Considerations

This project performs live-system collection.

Running collection tools on a live system can modify system state and may
generate additional artifacts.

This toolkit should therefore be considered a host triage and incident
response automation tool rather than a replacement for a full forensic
acquisition platform.

For formal forensic investigations, organizations should follow their
approved:

- Evidence acquisition procedures
- Chain-of-custody procedures
- Evidence preservation requirements
- Legal and organizational policies

---

# Limitations

The current version has several limitations.

### Live Collection

Evidence is collected from a running Windows system.

### Locked Files

Files currently in use may not be readable or hashable.

### Sysmon Dependency

Sysmon-specific telemetry is only available when Sysmon is installed and
configured.

### Network History

Network collection primarily represents information available from the host
at collection time and is not a complete historical network record.

### Detection Coverage

The current analytic rules are intentionally limited and should not be
considered a complete malware-detection engine.

### Persistence Coverage

The toolkit currently focuses on selected common Windows persistence
locations and does not cover every possible persistence mechanism.

---

# Development Roadmap

The project is being developed incrementally.

Planned improvements include:

- [ ] Dedicated metadata collector
- [ ] Consistent collection-status reporting
- [ ] Improved hash failure reporting
- [ ] Expanded persistence analysis
- [ ] Improved Scheduled Task analysis
- [ ] Additional Registry persistence locations
- [ ] Expanded Windows Event Log analysis
- [ ] Additional Sysmon event types
- [ ] Additional timeline sources
- [ ] Cross-source evidence correlation
- [ ] Additional analytic rules
- [ ] Improved severity classification
- [ ] Improved investigation reports
- [ ] Configuration support
- [ ] Automated testing
- [ ] Documentation expansion

---

# Learning Objectives

This project provides practical experience with:

## PowerShell

- Variables
- Objects
- `PSCustomObject`
- Functions
- Parameters
- Pipelines
- `Where-Object`
- `Select-Object`
- `ForEach-Object`
- `Export-Csv`
- `Get-CimInstance`
- `Get-WinEvent`
- Error handling
- Dot-sourcing
- Path handling
- File operations

## Windows Security

- Windows processes
- Parent/child process relationships
- Local accounts
- Windows services
- Registry persistence
- Startup persistence
- Scheduled Tasks
- Windows Event Logs
- Sysmon
- Filesystem artifacts
- File hashing

## Incident Response

- Evidence collection
- Evidence organization
- Persistence investigation
- Timeline construction
- Basic detection
- Evidence correlation
- Investigation reporting

## Git & GitHub

- Repository initialization
- Branch management
- Staging
- Commits
- `.gitignore`
- Remote repositories
- Version control

---

# Responsible Use

This project is intended for:

- Authorized incident response
- Defensive security research
- Security education
- Windows security testing
- Cybersecurity portfolio development

Only run the toolkit on systems that you are authorized to investigate.

---

# Disclaimer

This project is provided for educational and defensive security purposes.

The toolkit does not guarantee detection of malicious activity and should
not be treated as a complete forensic investigation platform.

Findings should be validated using additional evidence and appropriate
investigative procedures.

---

# License

This project is intended to be released under the MIT License.