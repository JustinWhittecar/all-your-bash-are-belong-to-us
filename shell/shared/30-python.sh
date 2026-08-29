# Python environment, shared by bash AND zsh.
# Function syntax below is valid in both shells.

# Activate the CUDA-enabled PyTorch venv:  torch-env
# Guarded so this file is harmless on machines without the venv (e.g. the Mac).
if [ -d "$HOME/venvs/torch" ]; then
    torch-env() { . "$HOME/venvs/torch/bin/activate"; }
fi

# Keep pip from installing into the system python by accident.
export PIP_REQUIRE_VIRTUALENV=true

# ...but let pipx and explicit --user installs through:  pip-sys install <pkg>
pip-sys() { PIP_REQUIRE_VIRTUALENV=false pip "$@"; }
