#!/usr/bin/env bash

# Exits if error occurs
set -e

# Check if IsaacLab directory exists
if [ ! -d "IsaacLab" ]; then
    echo -e "[ERROR] IsaacLab directory not found!" >&2
    echo -e "\tPlease ensure:" >&2
    echo -e "\t1. You have initialized git submodules: git submodule update --init --recursive" >&2
    echo -e "\t2. You are running this script from the correct directory" >&2
    exit 1
fi

# Set IsaacLab path
export ISAACLAB_PATH="$(pwd)/IsaacLab"

#==
# Helper functions
#==

# check if input directory is a python extension and install the module
install_isaaclab_extension() {
    # if the directory contains setup.py then install the python module
    if [ -f "$1/setup.py" ]; then
        echo -e "\t module: $1"
        python -m pip install --editable $1 "numpy<2.0" "numba>=0.59" "build123d<0.8"
    fi
}

#==
# Main
#==

# Check if running in a Pixi environment
if [ -z "${PIXI_PROJECT_ROOT}" ]; then
    echo -e "[ERROR] Not running in a Pixi environment!" >&2
    echo -e "\tPlease activate your Pixi environment first with:" >&2
    echo -e "\t    pixi shell" >&2
    exit 1
fi

echo "[INFO] Installing extensions inside the Isaac Lab repository..."

# recursively look into directories and install them
# this does not check dependencies between extensions
export -f install_isaaclab_extension

# source directory
find -L "${ISAACLAB_PATH}/source/extensions" -mindepth 1 -maxdepth 1 -type d -exec bash -c 'install_isaaclab_extension "{}"' \;

# NOTE: These RL libraries come with a whole lot of dependencies, so not doing it now.
# # install the python packages for supported reinforcement learning frameworks
# echo "[INFO] Installing extra requirements such as learning frameworks..."
# # install all rl-frameworks by default
# python -m pip install -e ${ISAACLAB_PATH}/source/extensions/omni.isaac.lab_tasks["all"]

# unset local variables
unset install_isaaclab_extension