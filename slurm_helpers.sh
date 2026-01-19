#!/bin/bash
##################
# slurm_helpers.sh
#
# Misc. helper functions for basic Slurm tasks
##################
source config.sh


# Function: Check the status of all of $USER jobs
check_jobs() {
  squeue --all -u "${USER}"
}


# Function: Check the status of all jobs in the specified account
check_account_jobs() {
  squeue --all --account="${ACCOUNT}"
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


# Function: Given a port, check if the port is open
# Returns 0 (true) if the port is available, or 1 (false) if the port is in use or an invalid port was provided.
check_port_availability() {
    local port="$1"

    # --- Debugging: Separated validation checks ---
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Port '${port}' is not a number." >&2
        return 1
    fi
    if [ "$port" -lt 1 ]; then
        echo "Error: Port '${port}' is less than 1." >&2
        return 1
    fi
    if [ "$port" -gt 65535 ]; then
        echo "Error: Port '${port}' is greater than 65535." >&2
        return 1
    fi

    # Use python to quickly check if the port is available by trying to bind to it.
    if python -c "import socket; s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); exit(0) if s.bind(('127.0.0.1', $port)) is None else exit(1)" 2>/dev/null; then
        return 0 # Success, port is available
    else
        # Port is in use. Use lsof to find out what process is using it.
        if command -v lsof >/dev/null 2>&1; then
            # Get process info. -n and -P make it faster by skipping name resolution.
            local process_info
            process_info=$(lsof -i :${port} -sTCP:LISTEN -n -P | awk 'FNR == 2 {print "PID: " $2 ", Command: " $1}')
            if [ -n "$process_info" ]; then
                echo "Port ${port} is in use by -> ${process_info}" >&2
            else
                echo "Port ${port} is in use, but process info could not be determined." >&2
            fi
        else
            echo "Port ${port} is in use. 'lsof' not found to get process details." >&2
        fi
        return 1 # Failure, port is not available
    fi
}
