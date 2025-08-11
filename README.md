# Windows Scripts and Utilities 🧰

A collection of personal Windows automation scripts and utilities for everyday tasks and system management.

## Overview

Practical PowerShell scripts and tools for common Windows scenarios like safe device removal, cloud photo syncing, and system maintenance. These scripts are designed for personal use and can be easily adapted for similar needs.

## Tools

### **[SafeUndock](./SafeUndock/)**
Safely removes external drives and devices by flushing write buffers, stopping conflicting services, and properly ejecting drives with write caching enabled.

**Use case**: Prevents data corruption when disconnecting external storage devices

### **[StopEAService](./StopEAService/)**
Stops EA Background Service to enable safe USB device removal.

**Use case**: Resolves "device in use" errors when trying to eject USB devices

### **[iCloudDownloader](./iCloudDownloader/)**
Synchronizes iCloud Photos and shared albums to local folders using icloudpd.

**Use case**: Local backup of iCloud photos or offline access to photo libraries

## Usage

- Each tool is organized in its own folder with documentation
- Scripts are designed for Windows 10/11 
- Many are optimized for use with Windows Task Scheduler
- See individual tool folders for specific setup instructions

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Administrative privileges may be required for some scripts

## Installation

1. Download or clone the repository
2. Navigate to the specific tool folder you need
3. Follow the README instructions in each folder
4. Test scripts before scheduling or regular use

## Contributing

These are personal utilities that others might find useful. Feel free to suggest improvements or report issues.

## License

MIT License - Free to use, modify, and share.

---

*Personal Windows automation utilities by [@haakonwibe](https://github.com/haakonwibe)*
