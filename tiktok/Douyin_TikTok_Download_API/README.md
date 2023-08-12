#### 🚩 「Douyin_TikTok_Download_API」是一个开箱即用的高性能异步抖音|TikTok数据爬取工具，支持API调用，在线批量解析及下载
#### 🚩 先下载配置文件放入docker需要映射的目录，config.ini里面可以修改默认端口
#### 🚩 项目地主：https://github.com/Evil0ctal/Douyin_TikTok_Download_API

#### 🚩 下载配置文件config.ini里面可以修改默认端口
```sh
wget https://raw.githubusercontent.com/shidahuilang/pve/main/tiktok/Douyin_TikTok_Download_API/config.ini
或下载作者的config.ini文件  修改Web_APP里面的80端口
wget  https://raw.githubusercontent.com/Evil0ctal/Douyin_TikTok_Download_API/main/config.ini
```
```sh
docker run -d \
  --name douyin_tiktok_download_api \
  --network host \
  -v /volume1/docker/Douyin_TikTok/config.ini:/app/config.ini \
  -e TZ=Asia/Shanghai \
  evil0ctal/douyin_tiktok_download_api
```
