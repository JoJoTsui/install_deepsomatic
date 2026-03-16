#!/usr/bin/env bash
# =============================================================================
# DeepSomatic r1.9 本地目录自动安装脚本
# 适用于已从本地共享目录获取二进制文件和模型的场景
# =============================================================================

set -euo pipefail

# =============================================================================
# 配置区 —— 根据实际情况修改以下变量
# =============================================================================

# 本地共享的预编译二进制文件目录
SRC_BINARIES="/t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/DeepVariant-1.9.0"

# 本地共享的 run_deepsomatic.py 路径
SRC_RUN_DEEPSOMATIC="/t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/deepvariant/scripts/run_deepsomatic.py"

# 本地共享的模型目录（savedmodels 层级）
SRC_MODELS="/t9k/mnt/WorkSpace/data/ngs/xuzhenyu/dv/models/deepsomatic/1.9.0/savedmodels"

# 安装目标目录
DEST_BIN="/opt/deepvariant/bin"
DEST_MODELS="/opt/models/deepsomatic"

# Python 解释器配置
# 使用系统 python3：PYTHON="/usr/bin/python3"
# 使用 micromamba 虚拟环境：PYTHON="micromamba run -n tf python3"
PYTHON="${PYTHON:-micromamba run -n tf python3}"

# 是否对二进制文件打补丁（使用非 /usr/bin/python3 时需要）
# 设为 "true" 启用，"false" 跳过
PATCH_BINARIES="${PATCH_BINARIES:-true}"

# 脚本所在目录（用于定位 patch/ 子目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# 工具函数
# =============================================================================

info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*" >&2; }
die()   { echo "[ERROR] $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" &>/dev/null || die "未找到命令: $1，请先安装后再运行本脚本"
}

# =============================================================================
# 步骤 3：使用 apt 安装系统依赖
# =============================================================================
step3_apt_deps() {
  info "=== 步骤 3：安装系统依赖 ==="
  sudo apt-get update -qq
  sudo apt-get install -y \
    apt-utils build-essential python3-dev python3-pip python3-pip-whl \
    libcairo2-dev libgirepository1.0-dev pkg-config libdbus-1-dev parallel
  info "系统依赖安装完成"
}

# =============================================================================
# 步骤 4：运行 run-prereq.sh 并安装 Python 依赖
# =============================================================================
step4_python_deps() {
  info "=== 步骤 4：准备 Python 运行环境 ==="

  local prereq_script="${SCRIPT_DIR}/dv_tf/run-prereq.sh"
  if [[ -f "$prereq_script" ]]; then
    info "运行 run-prereq.sh ..."
    bash "$prereq_script"
  else
    warn "未找到 ${prereq_script}，跳过"
  fi

  local req_file="${SCRIPT_DIR}/requirements.txt"
  [[ -f "$req_file" ]] || die "未找到 requirements.txt: ${req_file}"

  info "安装 Python 依赖（使用清华镜像）..."
  PIP_USER=false ${PYTHON} -m pip install -r "$req_file" \
    --no-deps \
    -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
  info "Python 依赖安装完成"
}

# =============================================================================
# 步骤 5：安装 DeepSomatic 到 /opt
# =============================================================================
step5_install() {
  info "=== 步骤 5：安装 DeepSomatic 到 /opt ==="

  # 5a. 创建目录
  sudo mkdir -p "${DEST_BIN}/deepsomatic"
  sudo mkdir -p "${DEST_MODELS}"

  # 5b. 复制 run_deepsomatic.py
  [[ -f "$SRC_RUN_DEEPSOMATIC" ]] || die "未找到 run_deepsomatic.py: ${SRC_RUN_DEEPSOMATIC}"
  info "复制 run_deepsomatic.py ..."
  sudo cp "$SRC_RUN_DEEPSOMATIC" "${DEST_BIN}/deepsomatic/"

  # 5c. 同步预编译二进制文件
  [[ -d "$SRC_BINARIES" ]] || die "未找到二进制文件目录: ${SRC_BINARIES}"
  info "同步预编译二进制文件到 ${DEST_BIN} ..."
  sudo rsync -avP "${SRC_BINARIES}/" "${DEST_BIN}/"

  # 5d. 对二进制文件打补丁（可选）
  if [[ "$PATCH_BINARIES" == "true" ]]; then
    info "对二进制文件打补丁（PYTHON=${PYTHON}）..."
    local patch_script="${SCRIPT_DIR}/patch/patch_dv_stub.sh"
    [[ -f "$patch_script" ]] || die "未找到补丁脚本: ${patch_script}"
    # 将配置好的 PYTHON 和 BIN_DIR 传入补丁脚本
    BIN_DIR="${DEST_BIN}" PYTHON="${PYTHON}" bash "$patch_script"
  else
    info "跳过二进制文件补丁（PATCH_BINARIES=false）"
  fi

  # 5e. 同步模型文件
  [[ -d "$SRC_MODELS" ]] || die "未找到模型目录: ${SRC_MODELS}"
  info "同步 DeepSomatic 模型到 ${DEST_MODELS} ..."
  _rsync_models

  # 5f. 生成命令行包装脚本
  info "生成命令行工具 ..."
  local make_cli="${SCRIPT_DIR}/make_cli.sh"
  [[ -f "$make_cli" ]] || die "未找到 make_cli.sh: ${make_cli}"
  PYTHON="${PYTHON}" bash "$make_cli"

  info "DeepSomatic 安装完成"
}

# 内部函数：按照 rsync_install_deepsomatic_models.sh 的逻辑同步模型
_rsync_models() {
  local prefix="deepsomatic."
  local suffix=".savedmodel"

  for src_path in "${SRC_MODELS}"/*/; do
    [[ -d "$src_path" ]] || continue
    local src_name
    src_name=$(basename "${src_path%/}")
    # 去掉前缀和后缀，得到目标目录名
    local tmp="${src_name#$prefix}"
    local dest_name="${tmp%$suffix}"
    local dest_path="${DEST_MODELS}/${dest_name}"

    info "  同步模型: ${src_name} -> ${dest_path}"
    sudo rsync -avP "${src_path}/" "${dest_path}"
  done
}

# =============================================================================
# 主流程
# =============================================================================
main() {
  info "======================================================"
  info " DeepSomatic r1.9 本地安装脚本"
  info "======================================================"
  info "二进制文件来源 : ${SRC_BINARIES}"
  info "模型来源       : ${SRC_MODELS}"
  info "安装目标       : ${DEST_BIN}"
  info "模型目标       : ${DEST_MODELS}"
  info "Python 解释器  : ${PYTHON}"
  info "打补丁         : ${PATCH_BINARIES}"
  info "======================================================"
  echo

  require_cmd rsync
  require_cmd sudo

  # 解析命令行参数，支持跳过特定步骤
  local run_apt=true
  local run_python=true
  local run_install=true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-apt)     run_apt=false ;;
      --skip-python)  run_python=false ;;
      --skip-install) run_install=false ;;
      --help|-h)
        echo "用法: $0 [选项]"
        echo "  --skip-apt      跳过 apt 系统依赖安装（步骤 3）"
        echo "  --skip-python   跳过 Python 依赖安装（步骤 4）"
        echo "  --skip-install  跳过 DeepSomatic 安装到 /opt（步骤 5）"
        echo ""
        echo "环境变量："
        echo "  PYTHON          Python 解释器命令（默认: micromamba run -n tf python3）"
        echo "  PATCH_BINARIES  是否打补丁，true/false（默认: true）"
        exit 0
        ;;
      *) die "未知参数: $1，使用 --help 查看帮助" ;;
    esac
    shift
  done

  [[ "$run_apt"     == "true" ]] && step3_apt_deps
  [[ "$run_python"  == "true" ]] && step4_python_deps
  [[ "$run_install" == "true" ]] && step5_install

  echo
  info "======================================================"
  info " 全部步骤完成"
  info " 测试参考: https://github.com/google/deepsomatic/blob/r1.9/docs/deepsomatic-case-study-wes.md"
  info "======================================================"
}

main "$@"
