# 在服务器上本地安装 DeepSomatic r1.9（无需 Docker）

## 环境要求
- `ubuntu 22.04`
- `python 3.10.12`
- CPU 支持 `SSE4` 和 `AVX` 指令集
- `sudo` 权限

## 安装步骤

1. 下载预编译的 DeepSomatic 二进制文件
2. 下载 DeepSomatic 模型
3. 使用 `apt` 准备 `/usr/bin/python3` 和 `DeepSomatic` 运行环境
4. 使用 `run-prereq.sh` 准备 `DeepSomatic` 运行环境

    4.1 在 `/usr/bin/python3` 中安装 `DeepSomatic` 依赖

    4.2 或使用 conda/micromamba 虚拟环境安装 `DeepSomatic` 依赖，例如 `tf` 虚拟环境

5. 将 `DeepSomatic` 安装到 `/opt`
6. `Tensorflow` CUDA 相关问题
7. 备份已安装的 DeepSomatic 二进制文件和模型

### 1. 下载预编译的 DeepSomatic 二进制文件

```bash
gsutil -m rsync -r "gs://deepvariant/binaries/DeepVariant/1.9.0/DeepVariant-1.9.0" .


# 本地共享目录
/t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/DeepVariant-1.9.0
```

### 2. 下载 DeepSomatic 模型

```bash
# deepsomatic 模型
DEST="./models/deepsomatic/1.9.0/"
mkdir -p "${DEST}"

gsutil -m rsync -r \
  "gs://deepvariant/models/DeepSomatic/1.9.0/" \
  "${DEST}"


# 本地共享目录
/t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/models
```

### 3. 使用 `apt` 准备 `/usr/bin/python3` 和 `DeepSomatic` 运行环境

```bash
sudo apt update
sudo apt install apt-utils build-essential python3-dev python3-pip python3-pip-whl \
  libcairo2-dev libgirepository1.0-dev pkg-config libdbus-1-dev parallel
```

### 4. 使用 `run-prereq.sh` 准备 `DeepSomatic` 运行环境

```bash
bash run-prereq.sh


# 本地目录
bash dv_tf/run-prereq.sh
```

#### 4.1 在 `/usr/bin/python3` 或指定的 `python 3.10` 中安装 `DeepSomatic` 依赖

```bash
/usr/bin/python3 -m pip install -r requirements.txt --no-deps -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
```

#### 4.2 使用 conda/micromamba 虚拟环境安装 `DeepSomatic` 依赖

```bash
# 也可以使用任意已准备好的 python 3.10 环境
micromamba create -n tf -c conda-forge -c nvidia tensorflow=2.13.1=cuda118py310h189a05f_1 python=3.10.12 cudatoolkit cudnn
micromamba run -n tf pip install -r requirements.txt --no-deps -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
# 如果 pip 安装到了 ${HOME}/.local，需要添加前缀
PIP_USER=false micromamba run -n tf pip install -r requirements.txt --no-deps -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple


# 或使用 uv 安装
micromamba create -n tf -c conda-forge -c nvidia tensorflow=2.13.1=cuda118py310h189a05f_1 python=3.10.12 cudatoolkit cudnn uv pygobject=3.42.1 pkg-config pkgconfig
PIP_USER=false micromamba run -n tf uv pip install -r requirements.txt --no-deps -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple


# 如果安装 tensorflow 时遇到问题，请检查 ${HOME}/.condarc
# 确保其中没有自定义的 channels
cat ~/.condarc
```


### 5. 将 `DeepSomatic` 安装到 `/opt`

**如有需要请使用 `sudo`**

```bash
mkdir -p /opt/deepvariant/bin/deepsomatic/

# 将 https://github.com/google/deepvariant/raw/refs/heads/r1.9/scripts/run_deepsomatic.py 复制到 /opt/deepvariant/bin/deepsomatic
cp /path/to/run_deepsomatic.py /opt/deepvariant/bin/deepsomatic/

# 将预编译二进制文件复制到 /opt/deepvariant/bin
rsync -avP /path/to/deepvariant/binaries /opt/deepvariant/bin/
# 如果使用非 /usr/bin/python3 的自定义 python3，需要对二进制文件打补丁
# 根据需要修改
# `BIN_DIR` 和
# `PYTHON` 变量
cd patch && bash patch_dv_stub.sh

# 将 deepsomatic 模型复制到 /opt/models/deepsomatic
mkdir -p /opt/models/deepsomatic
# 根据需要修改 `SRC_BASE`
# 记得将 `rsync -avPn` 改为 `rsync -avP`
bash rsync_install_deepsomatic_models.sh

# 生成命令行工具
# 记得修改 `PYTHON` 变量
bash make_cli.sh
```

#### 本地共享目录版本

```bash
mkdir -p /opt/deepvariant/bin/deepsomatic/

# 复制本地共享的 run_deepsomatic.py
cp /t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/deepvariant/scripts/run_deepsomatic.py /opt/deepvariant/bin/deepsomatic/

# 将预编译二进制文件复制到 /opt/deepvariant/bin
rsync -avP /t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/DeepVariant-1.9.0/ /opt/deepvariant/bin/
# 如果使用非 /usr/bin/python3 的自定义 python3，需要对二进制文件打补丁
# 根据需要修改
# `BIN_DIR` 和
# `PYTHON` 变量
bash patch/patch_dv_stub.sh

# 将 deepsomatic 模型复制到 /opt/models/deepsomatic
# 记得将 `SRC_BASE` 路径修改为 /t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/models/deepsomatic/1.9.0/savedmodels
# 记得将 `rsync -avPn` 改为 `rsync -avP`
mkdir -p /opt/models/deepsomatic
bash rsync_install_deepsomatic_models.sh

# 生成命令行工具
# 记得修改 `PYTHON` 变量
bash make_cli.sh
```


### 6. `Tensorflow` CUDA 相关问题

待完善（WIP）

### 7. 备份已安装的 DeepSomatic 二进制文件和模型

- `/opt/deepvariant`
- `/opt/models`
- `/usr/bin/python3` 环境
- 或 conda/micromamba `python3` 虚拟环境

## 通过 `rsync` 安装预配置的二进制文件

```bash
sudo rsync -avP /t9k/mnt/joey/bio_utilities/deepvariant_opt/ /opt/
```

## 测试

__https://github.com/google/deepsomatic/blob/r1.9/docs/deepsomatic-case-study-wes.md__
