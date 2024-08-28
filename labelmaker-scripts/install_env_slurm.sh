#!/usr/bin/bash
#SBATCH --job-name="labelmaker-vibus"
#SBATCH --output=mask3d_env_build.out
#SBATCH --time=2:00:00
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
conda create --name $env_name --yes python=3.10
eval "$(conda shell.bash hook)"
conda activate $env_name

INSTALLED_GCC_VERSION="9.5.0"
INSTALLED_CUDA_VERSION="11.3.1"
INSTALLED_CUDA_ABBREV="cu113"
INSTALLED_PYTORCH_VERSION="1.12.1"
INSTALLED_TORCHVISION_VERSION="0.13.1"
INSTALLED_TORCHAUDIO_VERSION="0.12.1"

conda install -y cuda cuda-nvcc cuda-toolkit -c "nvidia/label/cuda-${INSTALLED_CUDA_VERSION}" --override-channels
conda install -y -c conda-forge gxx=${INSTALLED_GCC_VERSION} sysroot_linux-64=2.17 libcxx
conda install -y -c anaconda openblas="0.3.20"

conda_home="$(conda info | grep "active env location : " | cut -d ":" -f2-)"
conda_home="${conda_home#"${conda_home%%[![:space:]]*}"}"

conda deactivate
conda activate ${env_name}

pip install torch==${INSTALLED_PYTORCH_VERSION} torchvision==${INSTALLED_TORCHVISION_VERSION} torchaudio==${INSTALLED_TORCHAUDIO_VERSION} --index-url https://download.pytorch.org/whl/${INSTALLED_CUDA_ABBREV}

conda deactivate
conda activate ${env_name}

which nvcc
nvcc --version

export BUILD_WITH_CUDA=1
export CUDA_HOST_COMPILER="$conda_home/bin/gcc"
export CUDA_PATH="$conda_home"
export PATH="$conda_home/bin:$PATH"
export CUDA_HOME=$CUDA_PATH
export FORCE_CUDA="1"
export MAX_JOBS=12
export TORCH_CUDA_ARCH_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6"

pip3 install torch-scatter -f https://data.pyg.org/whl/torch-${INSTALLED_PYTORCH_VERSION}+${INSTALLED_CUDA_ABBREV}.html
pip3 install 'git+https://github.com/facebookresearch/detectron2.git@710e7795d0eeadf9def0e7ef957eea13532e34cf' --no-deps

REPO_DIR=/cluster/scratch/guanji/labelmaker-Mask3D
mkdir -p ${REPO_DIR}/third_party
cd ${REPO_DIR}/third_party

rm -rf MinkowskiEngine
git clone --recursive "https://github.com/NVIDIA/MinkowskiEngine"
cd MinkowskiEngine
git checkout 02fc608bea4c0549b0a7b00ca1bf15dee4a0b228
python setup.py install --force_cuda --blas=openblas

cd ${REPO_DIR}/third_party
rm -rf ScanNet
git clone https://github.com/ScanNet/ScanNet.git
cd ScanNet/Segmentator
git checkout 3e5726500896748521a6ceb81271b0f5b2c0e7d2
make

cd ${REPO_DIR}/third_party/pointnet2
python setup.py install

pip install pip==24.0
pip install pandas
pip3 install pytorch-lightning==1.9.0
pip install "cython<3.0.0" wheel
pip install "pyyaml==5.4.1" --no-build-isolation
pip install volumentations==0.1.8
pip install albumentations==1.2.1
pip install pillow==9.5.0
pip install pycocotools
pip install cloudpickle==2.1.0
pip install fvcore==0.1.5.post20220512
pip install wandb==0.15.0
pip install torchmetrics==0.11.4
pip install trimesh==3.14.0
pip install imageio==2.21.1
pip install pyviz3d==0.2.28
pip install python-dotenv==0.20.0
pip install plyfile==0.7.4
pip install open3d==0.17.0
pip install joblib==1.2.0
pip install loguru==0.6.0
pip install natsort==8.3.1
pip install omegaconf==2.0.6 hydra-core==1.0.5
pip install fire==0.4.0
