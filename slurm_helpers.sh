#!/bin/bash
##################
# slurm_helpers.sh
#
# Misc. helper functions for basic Slurm tasks
##################
source config.sh


# Function: Check the status of all of $USER jobs
check_jobs() {
  squeue -u "${USER}"
}


# Function: Create an interactive CPU job
# Runs for 2 hours
quick_cpu() {
  salloc --job-name=interactive-cpu \
  --nodes=1 \
  --partition="${CPU_PARTITION}" \
  --account "${ACCOUNT}" \
  --time=02:00:00 \
  srun --pty bash
}


# Function: Create an interactive GPU job
# Runs for 2 hours
quick_gpu() {
  salloc --job-name=interactive-gpu \
    --nodes=1 \
    --partition="${GPU_PARTITION}" \
    --account "${GPU_ACCOUNT}" \
    --gres=gpu:1 \
    --time=02:00:00 \
    srun --pty bash
}


# Function: Get job ID from sbatch submission output
parse_job_id_from_submission_message() {
  # Store the first argument as job submission message
  local sub_message="$1"

  # sub_message format is 'Submitted batch job 292018'
  # Parse the 4th token
  echo "${sub_message}" | awk '{print $4}'
}


# Function: Get the status of a job when provided a job ID
get_squeue_value() {
  # Format is 'JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)'
	local job_id="$1" # Store the first argument as job_id
    if [[ -z "$job_id" ]]; then # Check if job_id is empty
    echo "Usage: get_squeue_value <job_id>" >&2 # Print error to stderr
    return 1 # Return non-zero to indicate error
	fi

  # Execute the command and return the result
  # Want the 5th item on the 2nd line
  # and remove trailing whitespace
  squeue --job="${job_id}" | awk 'FNR == 2 {print $5}' | tr -d ' '
}


# Function: Given a job ID, wait for the job to start running
wait_for_job_start() {
  # Save first argument as the job ID
  local job_id="$1"

  # Get the initial status
  job_status=$(get_squeue_value "${job_id}")

  # Wait for job state to become "R" for "Running"
  while [[ ${job_status} != "R" ]]
  do
      job_status=$(get_squeue_value "${job_id}")
      echo "Job state is ${job_status}"
      sleep 5
  done
}

