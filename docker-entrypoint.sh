#! /bin/sh

USER=mdc
config_file="/config/mdc.ini"

echo "---Setup Timezone to ${TZ}---"
echo "${TZ}" > /etc/timezone
echo "---Checking if UID: ${UID} matches user---"
usermod -o -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
groupmod -o -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Taking ownership of data...---"
if [ ! -d /config ]; then
    echo "---no config folder found, create...---"
    mkdir -p /config
fi
chown -R ${UID}:${GID} /data /config 

echo "Checking if config file exist"
if [ ! -f "${config_file}" ]; then
    cp /app/config.template "${config_file}"
    echo "config file missing, we create a new config file, modify the config file and restart container please!"
    echo "没有找到配置文件，我们创建了一个新的配置文件，请修改后重启镜像"
    exit 1
fi

echo "Starting..."
cd /data

# /Users/zhu0823/Docker/mdc/config
# /Users/zhu0823/Docker/mdc/data
# DELETE_FILES
# DELETE_SIZE

echo "---Clean File  Start---"

# 从环境变量中获取 DELETE_FILES 的值
# 遍历文件名列表并删除文件
#for file in $(echo "$DELETE_FILES" | tr ',' '\n'); do
#    find . -name "$file" -type f -print -delete
#done
# 删除所有小于DELETE_SIZE的文件
if [ -n "${DELETE_SIZE}" ]; then
    find . -name "*.mp4" -type f -size -"${DELETE_SIZE}" -print -delete
fi

echo "---Clean File  End---"

gosu ${USER} /app/Movie_Data_Capture

echo "--- Move JAV_output Start ---"
# 移动整理后的文件到指定目录
if [ -d "dest" ]; then
    mv -v JAV_output/* dest
fi
echo "--- Move JAV_output End ---"
