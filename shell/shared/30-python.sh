# Activate the CUDA-enabled PyTorch venv:  torch-env
torch-env() { source "$HOME/venvs/torch/bin/activate"; }

# Keep pip from installing into the system python by accident.
export PIP_REQUIRE_VIRTUALENV=true
# ...but let pipx and explicit --user installs through:  pip-sys install <pkg>
pip-sys() { PIP_REQUIRE_VIRTUALENV=false pip "$@"; }
