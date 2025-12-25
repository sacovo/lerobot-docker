#!/bin/bash

# Source the virtual environment
source /work/.venv/bin/activate

# Execute the command passed to the container
exec "$@"
