# Slurm Utils

A collection of bash scripts and functions to make the slurm environment easier to navigate.

## Setup Instructions

1.  Clone the repository

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

---

## Usage

This repository provides both standalone scripts and helper functions that you can call directly from your terminal after completing the setup.

### Scripts

These can be run from anywhere in your terminal.

#### `launch_marimo_server`

Submits a Slurm job to run a marimo notebook. The script will wait for the job to start and then print the log file containing the SSH tunnel command you need to connect from your local machine.

**Usage:**
```bash
launch_marimo_server [--gpu] <path_to_notebook.py>
```

**Example (CPU Job):**
```bash
launch_marimo_server notebooks/my_analysis.py
```

**Example (GPU Job):**
```bash
launch_marimo_server --gpu notebooks/deep_learning.py
```

### Interactive Functions

These functions are loaded from `slurm_helpers.sh` into your environment and can be called directly from your command prompt.

#### `quick_cpu`

Starts a 2-hour interactive CPU job on the partition defined in your `config.sh`. This is useful for quick debugging or development tasks.

**Usage:**
```bash
quick_cpu
```

#### `quick_gpu`

Starts a 2-hour interactive GPU job on the partition and account defined in your `config.sh`.

**Usage:**
```bash
quick_gpu
```

#### `check_jobs`

A simple shortcut to list all of your current jobs in the Slurm queue. Equivalent to `squeue -u $USER`.

**Usage:**
```bash
check_jobs
