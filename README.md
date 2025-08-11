# Slurm Utils

A collection of bash scripts and functions to make the slurm environment easier to navigate.

## Setup Instructions

1. Clone the repository

    ```bash
    git clone git@github.com:AADeLucia/slurm-utils.git
    ```

2.  Copy the configuration template and edit it for your cluster's setup.

    ```bash
    cd slurm-utils
    cp config.sh.example config.sh
    vim config.sh
    ```

3.  Add the scripts to your `PATH` and source the helpers for interactive use by adding the following lines to your `~/.bashrc` file. And load the changes.

    ```bash
    # This command must be run from inside the slurm-utils directory
    echo "" >> ~/.bashrc
    echo "# Load Slurm utility scripts and functions" >> ~/.bashrc
    echo "export PATH=\"$(pwd):\$PATH\"" >> ~/.bashrc
    echo "source \"$(pwd)/slurm_helpers.sh\"" >> ~/.bashrc
    source ~/.bashrc
    ```
