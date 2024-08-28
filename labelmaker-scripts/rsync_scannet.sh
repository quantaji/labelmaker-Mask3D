#!/usr/bin/bash
#SBATCH --job-name="labelmaker-mask3d"
#SBATCH --output=mask3d_scannet_rsync_scannet.out
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH -A ls_polle
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=4G
#SBATCH --tmp=32G

# rsync scennet necessary files to a temporary folder
source_dir=/mnt/ScanNet
target_dir=/cluster/scratch/guanji/scannet

# need:
# rgb _vh_clean_2.ply
# instance *.aggregation.json
# instance [0-9].segs.json
# semantic label .labels.ply

rsync -r -v -e ssh \
    --include='scannetv2-labels.combined.tsv' \
    --include='**/*_vh_clean_2.ply' \
    --include='**/*.aggregation.json' \
    --include='**/*[0-9].segs.json' \
    --include='**/scene[0-9][0-9][0-9][0-9]_[0-9][0-9].txt' \
    --include='**/*.labels.ply' \
    --include='*/' \
    --exclude='*' \
    --exclude='**/data/' \
    --exclude='**/data_compressed/' \
    --exclude='**/instance-filt/' \
    --exclude='**/label-proc/' \
    quanta@rowletew.hopto.org:$source_dir/* \
    $target_dir
