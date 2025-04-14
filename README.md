# ramsy
Hi, I'm Ramsy! Let's boost your project in RAM!

<pre><code>_____________________  ___               
___  __ \__    |__   |/  /___________  __
__  /_/ /_  /| |_  /|_/ /__  ___/_  / / /
_  _, _/_  ___ |  /  / / _(__  )_  /_/ / 
/_/ |_| /_/  |_/_/  /_/  /____/ _\__, /  
Let's boost your project in RAM!/____/</code></pre>

## RamDisk Sync for macOS

A utility script that creates a RAM disk for your current project directory and automatically syncs changes back to the original disk in real time.

Use it to accelerate your IDE or dev workflow with temporary in-memory file access, while keeping your changes safe.

## Requirements

- macOS operating system
- [Homebrew](https://brew.sh/) package manager
- fswatch (will be installed automatically via Homebrew)
- Sufficient available RAM to accommodate your project size

## Installation

1. Install Homebrew if you don't have it:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/SoundBlaster/ramsy.git
   cd ramsy
   ```

3. Make the script executable:
   ```bash
   chmod +x ramsy.sh
   ```

## Usage

1. Navigate to your project directory:
   ```bash
   cd /path/to/your/project
   ```

2. Run the script:
   ```bash
   /path/to/ramsy.sh
   ```

3. To stop the sync, press Ctrl+C

## License

MIT License

## Credits

- Created by SoundBlaster
- Implementation support by ChatGPT (OpenAI)

## TODO

### Test Suite Improvements

- [ ] Complete implementation of all test cases:
  - [x] Test 1: Basic script execution
  - [ ] Test 2: RAM disk creation
  - [ ] Test 3: File synchronization
  - [ ] Test 4: Git directory handling
  - [ ] Test 5: Excluded directories
  - [ ] Test 6: Error handling

- [ ] Add more test cases:
  - [ ] Test RAM disk size configuration
  - [ ] Test cleanup on script termination
  - [ ] Test handling of large files
  - [ ] Test handling of file permissions
  - [ ] Test handling of symlinks
  - [ ] Test handling of special characters in filenames

- [ ] Test environment improvements:
  - [ ] Add test for different project sizes
  - [ ] Add test for concurrent file operations
  - [ ] Add test for system resource usage
  - [ ] Add test for different file types and structures

- [ ] CI/CD integration:
  - [ ] Set up GitHub Actions for automated testing
  - [ ] Add test coverage reporting
  - [ ] Add automated test runs on pull requests

- [ ] Documentation:
  - [ ] Add test coverage documentation
  - [ ] Add test troubleshooting guide
  - [ ] Add test environment setup guide
  - [ ] Document test dependencies and requirements
