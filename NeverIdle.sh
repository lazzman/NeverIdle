#!/bin/bash
# Author: lazzman
# Date: 2023-01-31

. /etc/profile

function log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] - $1"
}

function echoColor() {
  case $1 in
  # 红色
  "red")
    echo -e "\033[31m${printN}$2 \033[0m"
    ;;
    # 天蓝色
  "skyBlue")
    echo -e "\033[1;36m${printN}$2 \033[0m"
    ;;
    # 绿色
  "green")
    echo -e "\033[32m${printN}$2 \033[0m"
    ;;
    # 白色
  "white")
    echo -e "\033[37m${printN}$2 \033[0m"
    ;;
  "magenta")
    echo -e "\033[31m${printN}$2 \033[0m"
    ;;
    # 黄色
  "yellow")
    echo -e "\033[33m${printN}$2 \033[0m"
    ;;
    # 紫色
  "purple")
    echo -e "\033[1;;35m${printN}$2 \033[0m"
    ;;
    #
  "yellowBlack")
    # 黑底黄字
    echo -e "\033[1;33;40m${printN}$2 \033[0m"
    ;;
  "greenWhite")
    # 绿底白字
    echo -e "\033[42;37m${printN}$2 \033[0m"
    ;;
  esac
}

function checkRoot() {
  user=$(whoami)
  if [ ! "${user}" = "root" ]; then
    echoColor red "Please run as root user!"
    exit 0
  fi
}

function get_latest_info() {
  local latest_info_file='/tmp/NeverIdle-latest-info.json'
  wget -q -O ${latest_info_file} https://api.github.com/repos/lazzman/NeverIdle/releases/latest
  [[ $? -ne 0 ]] && log "Failed to get latest info" && exit 1
  latest_version=$(grep tag_name ${latest_info_file} | cut -d '"' -f 4)
  latest_comments=$(grep body ${latest_info_file} | cut -d '"' -f 4)
  rm -f ${latest_info_file}
}

function download() {
  local base_download_url="https://github.com/lazzman/NeverIdle/releases/download"
  local filename="NeverIdle-${platform}"
  download_dir="/tmp"
  local download_url="${base_download_url}/${latest_version}/${filename}"

  mkdir -p $download_dir
  rm -f ${download_dir}/NeverIdle

  log "Downloading ${download_url} to ${download_dir}/NeverIdle ..."
  wget -q -O ${download_dir}/NeverIdle ${download_url}
  [[ $? -ne 0 ]] && log "Download ${filename} failed" && exit 1

  chmod +x ${download_dir}/NeverIdle
}

function run() {
  local mem_test="-m $2"
  if [[ $mem_total -lt 4 ]]; then
    log "AMD doesn't need to test memory !"
    local mem_test=''
  elif [[ $mem_total -lt 13 ]]; then
    log "The memory test size is 1G"
    local mem_test='-m 1'
  else
    log "The memory test size is $2G"
  fi
  nohup ${download_dir}/NeverIdle -cp $1 ${mem_test} -n $3 >${download_dir}/NeverIdle.log 2>&1 &
  local pid=$(pgrep NeverIdle)
  log "NeverIdle [${pid}] is running"
  log "run 'pkill NeverIdle' to stop it."
  log "log file: ${download_dir}/NeverIdle.log"
}

function stop() {
  pkill NeverIdle
}

function init() {
  case $(uname -m) in
  "x86_64")
    platform="linux-amd64"
    ;;
  "aarch64")
    platform="linux-arm64"
    ;;
  *)
    log "Unsupported platform !"
    exit 1
    ;;
  esac
  mem_total=$(free -g | awk '/Mem/ {print $2}')
}

function menu() {
  clear
  cat <<EOF
 -------------------------------------------
|**********      Hi NeverIdle       **********|
|**********    Author: lazzman   **********|
|**********     Version: $(echoColor red "${latest_version}")    **********|
 -------------------------------------------
Tips:$(echoColor green "./NeverIdle")命令再次运行本脚本.
$(echoColor skyBlue ".............................................")
$(echoColor purple "###############################")

$(echoColor skyBlue ".....................")
$(echoColor yellow "1) 运行NeverIdle CPU15%负载 MEM2G 测速间隔1H")
$(echoColor yellow "2) 运行NeverIdle CPU25%负载 MEM3G 测速间隔1H ")
$(echoColor magenta "3) 停止运行NeverIdle")

$(echoColor purple "###############################")

$(echoColor magenta "0)退出")
$(echoColor skyBlue ".............................................")
EOF
  read -p "请选择:" input
  case $input in
  1)
    run 15 2 1h
    ;;
  2)
    run 25 3 1h
    ;;
  3)
    stop
    ;;
  0)
    exit 0
    ;;
  *)
    echoColor red "Input Error !!!"
    exit 1
    ;;
  esac
}

function main() {
  checkRoot
  init
  get_latest_info
  download
  menu
}
main
