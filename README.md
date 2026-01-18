# Home Server Monitoring & Backup System 

![Docker](https://img.shields.io/badge/-Docker-2496ED?style=flat&logo=docker)
![Prometheus](https://img.shields.io/badge/-Prometheus-E6522C?style=flat&logo=prometheus)
![Grafana](https://img.shields.io/badge/-Grafana-F46800?style=flat&logo=grafana)

> *Low-resource monitoring + automated backups for Plex server (1.5GB RAM, Pentium 4)*

## Table of Contents
- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Monitoring & Visualization](#monitoring--visualization)
- [Backup Strategy](#backup-strategy)
- [Automation](#automation)
- [Validation](#validation)
- [Future Enhancements](#future-enhancements)

## Project Overview

Self-hosted monitoring and backup solution for low-resource home server running Plex + Docker services.

**Why this matters**:
- **Prevent Silent Failures:** Constrained hardware is prone to OOM (Out of Memory) errors; monitoring catches these early.
- **Disaster Recovery:** Automated `rsync` ensures that even if the 20-year-old hardware fails, the metadata and configs are safe.
- **Efficiency:** Uses lightweight exporters to keep overhead minimal.

## Tech Stack

| Category | Tools |
|----------|-------|
| Monitoring | Prometheus, Grafana, Node Exporter |
| Backup | `rsync`, `cron`, AntiX Linux |
| Container | Docker |
| Network | WireGuard VPN |
## Architecture

#### **Server Specifications**
| Server | CPU | RAM | Storage | OS |
|--------|-----|-----|---------|----|
| Main | Pentium 4 | 1.5GB | 2TB HDD | Ubuntu Server 24.04 LTS |
| Backup | Pentium 4 | 0.75GB | 80GB HDD | AntiX 32-bit |

The main server hosts the primary services, such as Plex and Docker containers, and the backup server acts as a passive repository for backups.

## Monitoring & Visualization

#### **Tools Stack**

The stack focuses on the Prometheus ecosystem. Node Exporter runs as a container to scrape hardware metrics.

**The Flow**

1. **Collection:** Node Exporter scrapes hardware and kernel related metrics on my Linux system.

2. **Storage:** Prometheus scrapes the exporter and stores data in a local time-series database.

3. **Visualization:** Grafana provides a web-based UI for visualizing dashboards and setting up alerts.

**Metrics tracked:**

- **CPU:** Load averages and I/O wait.
- **RAM:** Tracking the 1.5GB limit.
- **Disk:** Monitoring the 2TB library health.

**Grafana Alerts:**

When the following thresholds are met, an email alert is sent to my personal email address.
- **Critical Disk:** Usage > 90%
- **Memory Pressure:** RAM usage > 80% sustained for 5 minutes.


## Backup Strategy

To save resources, backups are incremental via `rsync`. This avoids the high CPU overhead of compression (like .tar.gz) during the transfer process.

#### **Included Paths**

- `/etc`: System-level configurations.
- `/home/younes/monitoring`: The Docker-compose and Prometheus YAMLs.
- `/var/lib/plexmediaserver`: Specifically the metadata.

#### **Schedule & Retention**

Backups are triggered weekly on Sunday at 1 am to balance disk wear and data safety.

## Automation

The entire flow is governed by a simple `cron` job on the Main Server. By using SSH Keys, the script logs into the AntiX backup server without manual intervention.

1. **Trigger:** Sunday at 1:00 AM.

2. **Sync:** Sequential `rsync` of defined paths.

3. **Log:** Status written to `/home/younes/logs/backups.log`.

4. **Cleanup:** Removes backups older than 30 days on the backup server.

## Validation

I performed a data loss simulation test to ensure the system works:

1. **Simulated Failure:** Deleted the monitoring directory.

2. **Restore:** Pulled data back from the AntiX server.

3. **Result:** Docker monitoring containers were fully intact and functional.

## Future Enhancements
- **cAdvisor:** Adding container-specific metrics (if RAM allows).
- **Custom Dashboards:** Creating a "Legacy Hardware" dashboard for the community.
- **Plex Exporter:** To see active stream counts directly in Grafana.
