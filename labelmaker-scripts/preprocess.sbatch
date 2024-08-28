#!/usr/bin/bash
#SBATCH --job-name="labelmaker-mask3d"
#SBATCH --output=mask3d_scannet_preprocess.out
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH -A ls_polle
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=4G
#SBATCH --tmp=32G

set -e

module purge
module load eth_proxy

export PATH="/cluster/project/cvg/labelmaker/miniconda3/bin:${PATH}"

env_name=labelmaker-mask3d
eval "$(conda shell.bash hook)"
conda activate $env_name

conda_home="$(conda info | grep "active env location : " | cut -d ":" -f2-)"
conda_home="${conda_home#"${conda_home%%[![:space:]]*}"}"

conda deactivate
conda activate ${env_name}

which python

export BUILD_WITH_CUDA=1
export CUDA_HOST_COMPILER="$conda_home/bin/gcc"
export CUDA_PATH="$conda_home"
export PATH="$conda_home/bin:$PATH"
export CUDA_HOME=$CUDA_PATH
export FORCE_CUDA=1
export MAX_JOBS=12
export TORCH_CUDA_ARCH_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6"
export LD_LIBRARY_PATH=/cluster/project/cvg/labelmaker/miniconda3/envs/labelmaker-mask3d/lib/python3.10/site-packages/open3d:LD_LIBRARY_PATH

cd /cluster/scratch/guanji/labelmaker-Mask3D

python -m datasets.preprocessing.scannet_preprocessing preprocess \
    --data_dir="/cluster/scratch/guanji/scannet" \
    --save_dir="data/processed/scannet200" \
    --git_repo="/cluster/scratch/guanji/labelmaker-Mask3D/third_party/ScanNet" \
    --scannet200=true
