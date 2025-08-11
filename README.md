# Slurm Utils

A collection of bash scripts and functions to make the slurm environment easier to navigate.

## Setup Instructions

1. Clone the repository

```bash
git clone git@github.com:AADeLucia/slurm-utils.git
```

1. Edit `config.sh` to your cluster's setup
1. Add this directory to your PATH in `~/.bashrc`

```bash
cd slurm-utils
echo "export PATH=\"$(pwd):\$PATH\"" >> ~/.bashrc
echo "source \"$(pwd)/slurm_helpers.sh\"" >> ~/.bashrc
```
