#!/bin/bash

#SBATCH --output=slurms/slurm-%j.out
#SBATCH --job-name=active_drying
#SBATCH --nodes=1
#SBATCH --partition compute
#SBATCH --ntasks=64
#SBATCH --cpus-per-task=1
#SBATCH --time=14-00:00:00
#SBATCH --mem-per-cpu=100M
#SBATCH --account=PHYS030385

# This is a submission script. Test input scripts on the login node before submitting,
# since the login nodes differ from compute nodes in their configurations.
# Adjust runtime estimates carefully: too short and the job may fail; too long and it may sit longer in the queue.
# 'short' partition allows jobs up to 3 days, making it more suitable for this task than the 'test' partition.
# The 'test' partition is limited to short jobs with a maximum time of 1 hour and high resource contention.

# Cancel jobs if needed with:
# $ scancel <job_id>
# Check pending reasons with:
# $ scontrol show job <job_id>. Example: Reason=PartitionTimeLimit indicates issues with allowed time.
# Check node availability with:
# $ sinfo -p short. Focus on the number of 'idle' and 'mix' nodes.
# If all nodes are in 'alloc' or 'down' states, this job cannot be scheduled until resources are freed.

# Add the required module (use whatever module you compiled the code with)
module add openmpi/5.0.3
export OMPI_MCA_mca_base_component_show_load_errors=0

# Set fixed variables
SEED=1
RHO=0.75
LY=12 # half of Ly = 24σ (Ly = 16, 24, 32, 44σ), chosen to compare with Fig. S6

# Create timestamp variables for date and time
DATE=$(date +%y%m%d)
TIME=$(date +%H%M)

# Run the LAMMPS job for EPS values incrementing by 4 from 2 to 38
for EPS in {2..38..4}; do
  FILENAME="${DATE}.${TIME}.eps.${EPS}.ly.$((2*LY))"
  echo "Running with EPS=$EPS"
  mpirun --bind-to none -n 64 $HOME/mylammps/src/lmp_mpi -in abp3d-wet.lmp \
    -var dumpfolder dumps \
    -var dumpfile $FILENAME \
    -var seed $SEED \
    -var rho $RHO \
    -var eps $EPS \
    -var ly $LY
done