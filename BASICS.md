# Project Basics

## Overview
This document covers the fundamental aspects of the project to help you get started quickly.

## RAMsy
RAMsy is a macOS utility that accelerates development workflows by creating RAM disks for your projects. It automatically clones project directories to fast in-memory storage while maintaining real-time synchronization with the original disk location. This approach significantly improves IDE performance and build times, especially for large projects, by leveraging the superior read/write speeds of RAM compared to traditional storage. RAMsy handles the complexity of RAM disk management and file synchronization, allowing developers to focus on coding while enjoying faster file operations.

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
        sleep 30  # every 30 second
    done
    ```
    3.2 `fswatch` + `rsync`
    ```bash
    brew install fswatch
    ```
    ```bash
    #!/bin/bash
    SRC="/Volumes/RamDisk/project/"
    DEST="$HOME/path/to/project/"
    fswatch -o "$SRC" | while read f; do
        rsync -a --delete "$SRC" "$DEST"
    done
    ```
    3.3
4. Working with `.git`
    4.1 Exclude git files
    ```bash
    rsync -a --exclude='.git' ~/path/to/project/ /Volumes/RamDisk/project/
    ```
    4.2 Symlink to it
    ```bash
    ln -s ~/path/to/project/.git /Volumes/RamDisk/project/.git
    ```