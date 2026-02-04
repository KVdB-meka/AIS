# Raspberry Pi AIS Station: Receiver & Global Data Logger

This project documents the setup of a Raspberry Pi 4 that serves two purposes simultaneously:
1.  **AIS Feeder:** Receives local ship data via a dAISy HAT antenna and forwards it via UDP to aggregators like AISHub and VesselFinder.
2.  **Global Data Logger:** Downloads global AIS data via API every 30 minutes, stores it on a Synology NAS, and builds a rolling SQLite database for research analysis.

## 🏗 Hardware Setup
* **Computer:** Raspberry Pi 4 Model B
* **Receiver:** [dAISy HAT](https://wegmatt.com/) (AIS Receiver for Raspberry Pi)
* **Antenna:** Marine VHF Antenna (tuned to 162 MHz)
* **Storage:** Synology NAS (mounted via CIFS/SMB)
* **OS:** Raspberry Pi OS (Debian Bookworm)

---

## 🚀 Part 1: Receiving & Forwarding Local Data

The Pi receives raw NMEA messages from the dAISy HAT via the serial port (`/dev/serial0`) and forwards them via UDP.

### 1. Serial Configuration
Ensure the dAISy HAT serial port is accessible:
* Disable Bluetooth overlay to free up the PL011 UART.
* Disable the serial console.
* Port used: `/dev/serial0` (linked to `/dev/ttyAMA0`).

### 2. The Forwarder Service
We use a `systemd` service to pipe the serial data directly to `netcat` (nc). This allows forwarding to multiple destinations (e.g., AISHub and VesselFinder) simultaneously using `tee`.

**Service File:** `/etc/systemd/system/ais-forwarder.service`

```ini
[Unit]
Description=Forward AIS to AISHub & VesselFinder
Wants=network-online.target
After=network-online.target

[Service]
# Reads from serial0 and tees the output to two UDP destinations
ExecStart=/bin/bash -lc 'cat /dev/serial0 | tee >(nc -u data.aishub.net 3810) >(nc -u ais.vesselfinder.com 6325) > /dev/null'
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
