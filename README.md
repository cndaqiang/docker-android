## 说明
* 因为原始的镜像[HQarroum/docker-android](https://github.com/HQarroum/docker-android/tree/main)只是基础功能, 自定义参数少, 且缺乏手册
* 本仓库仍以原始仓库的镜像为基础进行构建, 并添加自定义的功能, 如存储空间大小, 并补充相关手册
* GitHUB自动编译发布地址: [cndaqiang/docker-android](https://hub.docker.com/r/cndaqiang/docker-android)
* 我也试图从头构建[docker-android-emulator](https://github.com/cndaqiang/docker-android-emulator), 但此版本无法运行WZRY等APP.

## 使用
下载原作者镜像, 目前仅能通过镜像站下载
```
docker pull dockerhub.anzu.vip/halimqarroum/docker-android:api-33
```

## 构建镜像
* 本项目主要修改了原始脚本的[start-emulator.sh](https://github.com/HQarroum/docker-android/blob/main/scripts/start-emulator.sh)
* `Dockerfile` 本项目的Dockerfile, 如需替换原始项目的不同版本, 则修改其中的`FROM`
* `start-emulator.mod.sh` 本项目修改后的启动脚本

```
cndaqiang@vmnode:~/git/docker-android$ docker build -t docker-android.mod:latest .
[+] Building 0.2s (8/8) FINISHED                                                             docker:default
 => [internal] load build definition from Dockerfile                                                   0.0s
 => => transferring dockerfile: 452B                                                                   0.0s
 => [internal] load .dockerignore                                                                      0.0s
 => => transferring context: 2B                                                                        0.0s
 => [internal] load metadata for dockerhub.anzu.vip/halimqarroum/docker-android:api-33                 0.0s
 => [internal] load build context                                                                      0.0s
 => => transferring context: 2.64kB                                                                    0.0s
 => CACHED [1/3] FROM dockerhub.anzu.vip/halimqarroum/docker-android:api-33                            0.0s
 => [2/3] COPY start-emulator.mod.sh /opt/start-emulator.mod.sh                                        0.0s
 => [3/3] RUN chmod +x /opt/start-emulator.mod.sh                                                      0.1s
 => exporting to image                                                                                 0.0s
 => => exporting layers                                                                                0.0s
 => => writing image sha256:13706163958f9256b0caf7b2c3d96b57d8a29103f920615a9a220b98954bd83e           0.0s
 => => naming to docker.io/library/docker-android.mod:latest                                           0.0s
```

查看镜像
```
cndaqiang@vmnode:~/git/docker-android$ docker images
REPOSITORY                                       TAG       IMAGE ID       CREATED         SIZE
docker-android.mod                               latest    13706163958f   16 seconds ago   6.83GB
dockerhub.anzu.vip/halimqarroum/docker-android   api-33    829e36bda510   6 months ago     6.83GB
```


## 创建容器

```bash
docker run -d --device /dev/kvm -p 5555:5555 -v androiddata:/data -e PARTITION=16384 -e EMULATOR_ARGS="-timezone Asia/Shanghai" -e MEMORY=4096 -e CORES=2 --name docker-android docker-android.mod:latest
```


* **`-d`**: 
   - **含义**：后台运行容器。
   - **说明**：该参数会让容器在后台启动，并返回容器的ID，而不会占用当前的终端。

* **`--device /dev/kvm`**:
   - **含义**：将主机的 `/dev/kvm` 设备挂载到容器中，允许容器访问主机的 KVM 硬件加速功能。
   - **说明**：Android 模拟器使用 KVM 进行硬件加速，这个参数确保容器能够访问到主机的 KVM 设备，从而提升模拟器的性能。

* **`-p 5555:5555`**:
   - **含义**：将主机的端口 5555 映射到容器内的 5555 端口。
   - **说明**：Android 模拟器使用端口 5555 来进行 ADB（Android Debug Bridge）连接，通过这个映射，允许你从主机连接到容器中的模拟器。

* **`-v androiddata:/data`**:
   - **含义**：将一个 Docker 卷（`androiddata`）挂载到容器内的 `/data` 目录。
   - **说明**：这会将模拟器的数据（如用户数据和虚拟设备配置）存储在 Docker 卷 `androiddata` 中，使得数据在容器停止或删除时得以保留。`/data` 是 Android 模拟器存储数据的默认位置。
   - **查看androiddata的位置**: `docker volume inspect androiddata`
   - **删除androiddata**: `docker volume rm androiddata`

* **`-e PARTITION=16384`**:
   - **含义**：设置环境变量 `PARTITION` 为 `16384`。
   - **说明**：这个环境变量通常用于指定模拟器的分区大小。在 Android 模拟器中，分区大小决定了虚拟设备的存储容量（单位是 MB）。`16384` 表示设置分区大小为 16GB。这个值会影响模拟器内部虚拟设备存储的大小（例如应用安装和数据存储空间）。

* **`-e EMULATOR_ARGS="-timezone Asia/Shanghai"`**:  
   - **含义**：自定义启动 Android 模拟器时的参数，此处设置时区为`Asia/Shanghai`。
   - **说明**：该环境变量用于向模拟器传递额外的启动选项。你可以通过设置 `EMULATOR_ARGS` 来定制模拟器的行为。例如：`-no-accel -no-boot-anim`。

* **`-e MEMORY=4096`**:
   - **含义**：设置环境变量 `MEMORY` 为 `4096`。
   - **说明**：这个环境变量用于设置模拟器的内存大小，单位为 MB。`4096` 表示模拟器分配 4GB 的内存给虚拟设备运行。增加内存可以提升模拟器的性能，但也会增加对主机资源的占用。

* **`-e CORES=2`**:
   - **含义**：设置环境变量 `CORES` 为 `2`。
   - **说明**：这个环境变量用于设置模拟器的 CPU 核心数。`2` 表示分配 2 个 CPU 核心给虚拟设备。分配更多的核心可以提高模拟器的多任务处理能力，但也会占用更多的主机 CPU 资源。

* **`--name docker-android`**:
   - **含义**：为容器指定一个名称 `docker-android`。
   - **说明**：这个参数允许你给容器起一个自定义名称，以便在后续操作中（如停止容器、查看日志等）更加方便地引用该容器。

* **`docker-android.mod:latest`**:
   - **含义**：指定要使用的 Docker 镜像名和标签。
   - **说明**：`docker-android.mod:latest` 是你构建的 Android 模拟器镜像。`latest` 是标签，表示使用该镜像的最新版本。




## 如何调试
* 使用`-entrypoint`禁止程序自动启动

```bash
docker run -it --entrypoint /bin/bash --rm --device /dev/kvm -p 5555:5555 -e PARTITION=4096  -e MEMORY=4096 -e CORES=2 docker-android.mod:latest
```

## 推送到dockerhub

配置代理
```
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo nano /etc/systemd/system/docker.service.d/http-proxy.conf
#
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
#
sudo systemctl daemon-reload
sudo systemctl restart docker
#
docker login
```

推送
```
cndaqiang@vmnode:~/git/docker-android$ docker tag docker-android.mod:latest cndaqiang/docker-android:api-33
cndaqiang@vmnode:~/git/docker-android$ docker push cndaqiang/docker-android:api-33
```

## 你可以使用我预编译的这个版本

```
docker run -d --rm --device /dev/kvm -p 5555:5555 -v data:/data -e PARTITION=24576 -e EMULATOR_ARGS="-timezone Asia/Shanghai" -e MEMORY=6144 -e CORES=4 --name docker-android cndaqiang/docker-android:api-33-mod
```