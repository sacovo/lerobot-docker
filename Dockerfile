ARG CUDA_VERSION=12.9.1
ARG OS_VERSION=24.04

FROM nvidia/cuda:${CUDA_VERSION}-base-ubuntu${OS_VERSION}

ARG PYTHON_VERSION=3.12


ENV DEBIAN_FRONTEND=noninteractive \
  MUJOCO_GL=egl \
  CUDA_VISIBLE_DEVICES=0 \
  TEST_TYPE=single_gpu \
  DEVICE=cuda


RUN apt-get update && apt-get install -y --no-install-recommends \
  software-properties-common build-essential git curl sudo tmux neovim htop nvtop \
  libglib2.0-0 libgl1 libglx-mesa0 ffmpeg openssh-server cmake \
  libusb-1.0-0-dev speech-dispatcher libgeos-dev portaudio19-dev \
  && add-apt-repository -y ppa:deadsnakes/ppa \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  python${PYTHON_VERSION} \
  python${PYTHON_VERSION}-venv \
  python${PYTHON_VERSION}-dev \
  && curl -LsSf https://astral.sh/uv/install.sh | sh \
  && mv /root/.local/bin/uv /usr/local/bin/uv \
  && useradd --create-home --shell /bin/bash user \
  && usermod -aG sudo user \
  && echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && mkdir /work \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /work

RUN chown -R user:user /work

USER user

RUN uv venv --python python${PYTHON_VERSION} && uv pip install "lerobot[pi,smolvlva,async]" wandb

RUN echo "source /work/.venv/bin/activate" >> /home/user/.bashrc


CMD ["bash", "-c", "sudo chown user /work; mkdir -p /home/user/.ssh; chmod 700 /home/user/.ssh; echo $PUBLIC_KEY; echo \"$PUBLIC_KEY\" >> /home/user/.ssh/authorized_keys; chmod 700 /home/user/.ssh/authorized_keys; sudo service ssh start; bash"]
