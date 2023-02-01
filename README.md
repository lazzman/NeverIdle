# NeverIdle

*我喜欢你，但别删我机，好么？*

本程序随手写的，下面介绍也是随心写的，不喜勿碰。

## 一键脚本【小白推荐】

```shell
wget -O NeverIdle.sh "https://raw.githubusercontents.com/lazzman/NeverIdle/master/NeverIdle.sh" && chmod +x NeverIdle.sh && ./NeverIdle.sh
```

> ORACLE AMD 只有 1G 内存，所以内存参数不会生效。

## Usage

从 Release 下载可执行文件。注意区分 amd64 和 arm64。

在服务器上启动一个 screen，然后执行本程序，用法自己搜。

命令参数：

```shell
./NeverIdle -cc 2 -cp 25 -m 2 -n 1h
```

其中：

-cc 指浪费的 CPU 核心数。
配合`-cp`指令使用，默认为全核心数。

-cp 指浪费的核心 CPU 使用率，0-100。  
如控制CPU使用率为33%，则为 33。按照格式填。

-m 指启用浪费的内存量，后面是一个数字，单位为 GiB。  
启动后会占用对应量的内存，并且保持不会释放，直到手动杀死进程。

-n 指启用网络定期浪费，后面跟随每次浪费的间隔时间。  
格式同 CPU。会定期执行一次 Ookla Speed Test（还会输出结果哦！）

*启动该程序后即立刻执行一次你配置的所有功能，可以观察效果。*

## docker

https://hub.docker.com/r/nodcat/neveridle