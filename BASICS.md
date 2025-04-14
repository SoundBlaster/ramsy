# Project Basics

## Overview
This document covers the fundamental aspects of the project to help you get started quickly.

## RAMsy
RAMsy is a project designed to clone folders to RAM disk and keep them synchronized with the original location.

## Prerequisites
- ...

## Conception

1. Use RAM disk provided by `diskutil`.
```bash
diskutil erasevolume HFS+ "RamDisk" `hdiutil attach -nomount ram://8388608`
```
2. Clone files 
```bash
rsync -a ~/path/to/project/ /Volumes/RamDisk/project/
```
3. Syncing
3.1 `rsync` in a cycle
```bash
#!/bin/bash
SRC="/Volumes/RamDisk/project/"
DEST="$HOME/path/to/project/"
while true; do
    rsync -a --delete "$SRC" "$DEST"
    sleep 30  # синхронизация каждые 30 секунд
done
```


## Getting Help
- Check the [documentation]
- Open an [issue]
- Join our [community chat]

## License
[License information] 