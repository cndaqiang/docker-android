# 基于原作者的镜像
# 此处我使用了镜像, 若镜像失效替换为新的镜像地址
FROM dockerhub.anzu.vip/halimqarroum/docker-android:api-33

# 修改 /opt/start-emulator.sh 脚本
COPY start-emulator.mod.sh /opt/start-emulator.mod.sh

# 给新脚本添加执行权限
RUN chmod +x /opt/start-emulator.mod.sh

# 设置容器启动时默认执行新脚本
ENTRYPOINT ["/opt/start-emulator.mod.sh"]