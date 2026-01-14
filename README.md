# Install DeepSomatic r1.9 locally on your server without docker

## Requirements
- `ubuntu 22.04`
- CPUs support SSE4 & AVX
- sudo privilege

## Install

1. Download prebuilt DeepSomatic binaries
1. Download DeepSomatic models
1. Prepare environment for `/usr/bin/python3` & `DeepSomatic` using `apt`
1. Prepare environment for `DeepSomatic` using `run-prereq.sh`
1. Install `DeepSomatic` requirements in `/usr/bin/python3`
1. `Tensorflow` CUDA issues

### Download prebuilt DeepSomatic binaries

```bash
gsutil -m rsync -r "gs://deepvariant/binaries/DeepVariant/1.9.0/DeepVariant-1.9.0" .


# local directory
/t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/DeepVariant-1.9.0
```

### Download DeepSomatic models

```bash
# deepsomatic models
DEST="./models/deepsomatic/1.9.0/"
mkdir -p "${DEST}"

gsutil -m rsync -r \
  "gs://deepvariant/models/DeepSomatic/1.9.0/" \
  "${DEST}"


# local directory
/t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/models
```

### Prepare environment for `/usr/bin/python3` & `DeepSomatic` using `apt`

```bash
sudo apt update
sudo apt install apt-utils build-essential python3-dev python3-pip python3-pip-whl \
  libcairo2-dev libgirepository1.0-dev pkg-config libdbus-1-dev parallel
```

### Prepare environment for `DeepSomatic` using `run-prereq.sh`

```bash
bash run-prereq.sh


# local directory
bash dv_tf/run-prereq.sh
```

### Install `DeepSomatic` requirements in `/usr/bin/python3` or specified `python 3.10`

```bash
/usr/bin/python3 -m pip install -r requirements.txt --no-deps -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple


# or use whatever prepared python 3.10 you like
micromamba create -n tf -c conda-forge -c nvidia tensorflow=2.13.1=cuda118py310h189a05f_1 python=3.10.12 cudatoolkit cudnn
micromamba run -n tf pip install -r requirements.txt --no-deps -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
# if pip installed to ${HOME}/.local, add prefix
PIP_USER=false micromamba run -n tf pip install -r requirements.txt --no-deps -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
```

### Install `DeepSomatic` to `/opt`

**Use `sudo` if needed**

```bash
mkdir -p /opt/deepvariant/bin/deepsomatic/

# copy https://github.com/google/deepvariant/raw/refs/heads/r1.9/scripts/run_deepsomatic.py to /opt/deepvariant/bin/deepsomatic
cp /path/to/run_deepsomatic.py /opt/deepvariant/bin/deepsomatic/

# copy prebuilt binaries to /opt/deepvariant/bin
rsync -avP /path/to/deepvariant/binaries /opt/deepvariant/bin/
# if use customized python3 other than /usr/bin/python3, patch the binaries
# modify the BIN_DIR and PYTHON when needed
bash patch/patch_dv_stub.sh

# copy deepsomatic models to /opt/models/deepsomatic
mkdir -p /opt/models/deepsomatic
bash rsync_install_deepsomatic_models.sh

# generate command cli
bash make_cli.sh
```

#### Local shared directory

```bash
mkdir -p /opt/deepvariant/bin/deepsomatic/

# copy locally shared run_deepsomatic.py
cp /t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/deepvariant/scripts/run_deepsomatic.py /opt/deepvariant/bin/deepsomatic/

# copy prebuilt binaries to /opt/deepvariant/bin
rsync -avP /t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/DeepVariant-1.9.0/ /opt/deepvariant/bin/
# if use customized python3 other than /usr/bin/python3, patch the binaries
# modify the BIN_DIR and PYTHON when needed
bash patch/patch_dv_stub.sh

# copy deepsomatic models to /opt/models/deepsomatic
# remember to modify SRC_BASE path to /t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/models/deepsomatic/1.9.0/savedmodels
mkdir -p /opt/models/deepsomatic
bash rsync_install_deepsomatic_models.sh

# generate command cli
# remember to modify PYTHON variables and 
bash make_cli.sh
```


### `Tensorflow` CUDA issues

WIP

## Test

__https://github.com/google/deepsomatic/blob/r1.9/docs/deepsomatic-case-study-wes.md__
