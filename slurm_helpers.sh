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

  # Capture both stdout and stderr from squeue
  local squeue_output
  squeue_output=$(squeue --job="${job_id}" 2>&1)

  # Check if the command failed because the job ID is no longer valid
  if echo "${squeue_output}" | grep -q "Invalid job id specified"; then
    # The job is no longer in the queue, likely completed or cancelled.
    echo "COMPLETED"
    return
  fi

  # If the job is still in the queue, parse the status (5th field of the 2nd line)
  echo "${squeue_output}" | awk 'FNR == 2 {print $5}' | tr -d ' '
}


# Function: Given a job ID, wait for the job to start running
wait_for_job_start() {
  local job_id="$1"
  echo "Waiting for job ${job_id} to start..."

  while true; do
    job_status=$(get_squeue_value "${job_id}")

    if [[ "${job_status}" == "R" ]]; then
      echo "Job ${job_id} is now Running."
      break
    elif [[ "${job_status}" == "COMPLETED" || -z "${job_status}" ]]; then
      echo "Job ${job_id} is no longer in the queue. Assuming it completed or failed."
      break
    else
      echo "Job state is '${job_status}'..."
      sleep 5
    fi
  done
}

