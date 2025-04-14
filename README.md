# ramsy
Hi, I'm Ramsy! Let’s boost your project in RAM!

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
