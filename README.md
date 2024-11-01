![Taumux Logo](https://github.com/avirsaha/taumux/blob/main/taumux-logo.png?raw=true)

# Taumux

**Taumux** is a custom tmux configuration designed to provide a dark, minimal color scheme and efficient plugins for a streamlined and productive terminal workflow. This project enhances your tmux experience by combining aesthetic simplicity with powerful functionality, making it ideal for developers and power users alike.

## Features

- **Dark Minimal Color Scheme**: A visually pleasing theme that minimizes eye strain during long coding sessions.
- **Essential Plugins**: Comes pre-configured with useful plugins to extend tmux's functionality, such as:
  - **Tmux Plugin Manager (TPM)** for easy plugin management.
  - **vim-tmux-navigator** for seamless navigation between vim and tmux panes.
  - **tmux-yank** for improved copy-paste capabilities.
  - **tmux-themepack** to easily switch between themes.
- **Customizable Settings**: Tailor your tmux experience with simple modifications to the configuration files.
- **Automatic Backups**: The script automatically backs up your existing configurations to prevent data loss.
- **User-Friendly Installation**: An easy-to-use bootstrap script guides you through the setup process with clear prompts and options.
- **Verbose Logging**: Detailed logs of the installation process help track changes and troubleshoot issues.

## Installation

### Prerequisites

To use Taumux, ensure you have the following installed:

- **tmux**: If tmux is not already installed, you can install it via your package manager. For Arch Linux users, run:
  ```bash
  sudo pacman -S tmux
  ```

- **git**: Required for cloning the Tmux Plugin Manager (TPM). Install it if it's not already available:
  ```bash
  sudo pacman -S git
  ```

### Steps to Install

1. **Clone the Repository**:
   First, clone the Taumux repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/taumux.git
   cd taumux
   ```

2. **Run the Bootstrap Script**:
   Execute the installation script to set up your tmux configuration:
   ```bash
   ./bootstrap_tmux.sh
   ```

   - For a list of options and flags, use:
     ```bash
     ./bootstrap_tmux.sh --help
     ```

3. **Follow the Prompts**:
   The script will guide you through the setup process, prompting for:
   - Backing up existing configuration files.
   - Confirming the creation of symlinks for new settings.
   - Customizing the tmux prefix key and enabling debug mode if desired.

## Configuration Options

The installation script offers several command-line options to tailor the process to your needs:

- `-h, --help`: Display help information.
- `-b, --backup`: Backup existing tmux config files before making changes.
- `-n, --no-install`: Skip the installation of Tmux Plugin Manager.
- `-d, --debug`: Enable debug mode for verbose output.
- `-p, --prefix KEY`: Set a custom prefix key for tmux (default: `C-Space`).
- `-a, --auto-consent`: Automatically confirm all prompts during installation, streamlining the process.

## Error Handling

The bootstrap script includes robust error handling to ensure a smooth installation process. Key features include:

- **Error Codes**: Each potential error is associated with a specific code for easier debugging. If an error occurs, the script will revert any changes made to restore your previous configuration.

### Error Codes

| Error Code | Description                                       |
|------------|---------------------------------------------------|
| 1          | Tmux is not installed.                            |
| 2          | Configuration file `.tmux.conf` is missing.      |
| 3          | Failed to create a symlink for `.tmux.conf`.     |
| 4          | Failed to install Tmux Plugin Manager.            |
| 5          | Failed to start the Tmux session for plugin installation. |
| 6          | Invalid command-line option provided.             |
| 7          | Failed to create the `.tmux` directory.          |
| 8          | Expected file was not found during the process.  |
| 9          | Failed to detect the shell type for command adjustments. |
| 10         | Failed to update the prefix key in `.tmux.conf`. |
| 11         | Failed to restore a backup during cleanup.       |
| 12         | Failed to create a backup for an existing file.  |
| 13         | Symlink already exists, preventing overwrite.     |
| 14         | An unknown error occurred during installation.    |

## Logging

The script generates a log file (`bootstrap_tmux.log`) that records all actions taken during the installation process. This log provides a clear history of what changes were made, which can be helpful for troubleshooting any issues that arise.

## Contributing

Contributions are welcome! If you have ideas for improvements or new features, feel free to fork the repository and submit a pull request. If you encounter any issues, please open an issue in the repository.

### Guidelines for Contribution

- Ensure that your contributions align with the project's goals.
- Include clear commit messages explaining your changes.
- Write documentation for new features or changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by various community-driven tmux configurations.
- Special thanks to the developers of tmux and Tmux Plugin Manager for their contributions to the terminal ecosystem.

## Contact

For questions, support, or feedback, please reach out via [your email or GitHub profile link].

---

With Taumux, elevate your terminal experience and maximize your productivity! Enjoy your new tmux setup!
                       |
