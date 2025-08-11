#!/bin/bash
# -----------------------------------------------------------------------------
# Configuration for Slurm scripts
#
# INSTRUCTIONS:
#     Edit the values below to match your cluster's setup.
#     Add other variables as needed.
# -----------------------------------------------------------------------------

# The public-facing address of your cluster's login node.
# This is the address you use to SSH into the cluster from your local machine.
# If you use a nickname in your local SSH config, you can put there here instead.
PUBLIC_LOGIN_NODE="your-cluster.edu"

# Your primary Slurm account name. Used for all jobs by default.
ACCOUNT=$(id -gn)

# The name of the partition/queue for CPU jobs.
CPU_PARTITION="cpu"

# The name of the partition/queue for GPU jobs.
GPU_PARTITION="gpu"

# The account to use for GPU jobs. Default is ACCOUNT.
# Useful if your GPU allocation is under a different project/account.
GPU_ACCOUNT="${ACCOUNT}"

# Location for marimo/Jupyter Notebook log files
NOTEBOOK_LOGS="${HOME}/logs"
