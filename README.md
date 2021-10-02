# Docker in Docker 技術研究

Docker-in-Docker 技術目前已知兩種方式：

1. 啟用任意容器並掛入本機 docker.sock 網址
2. 使用 Docker 官方提供的容器

這兩種方式概念不同，但原理上後者因官方長期維護，較建議場用此方式，且當前 Jenkins、Gitlab runner 官方說明亦採用此方式。

## 議題

本次研究專案，除完成 Docker-in-Docker 使用外，另外需針對一向議題進行多平台驗證與測試。

**掛入當前容器內的目錄，再次掛給經由 Docker-in-DOcker 啟用的容器，將無法顯示目錄內容**
> 此項議題主要發生於 Jenkins 實務時，為便於保存專案與緩存資訊而將 Jenkins 主要資訊掛載於目錄內，然而當 Jenkins Job 執行並藉由 Docker-in-Docker 啟用容器進行專案編譯時，卻發現掛入內容僅有目錄沒有相應程式碼。

## 研究與測試項目

### 1、Docker-in-Docker

僅使用 Dokcer-in-Docker 容器驗證

+ Docker pull docker:binb
+ Docerk run docker:binb -v %cd%
+ Inside docker, use docker run debin:slim -v ${PWD}

### 2、docker-compose

使用 docker-compose 啟用 Docker-in-Docker 容器與藉由網路使用 Docker 服務的執行容器

+ Docker pull docker:binb, and Docker pull debin:slim
+ Docerk run docker:binb and debin:slim in them same network, and -v %cd%
+ Inside debin:slim docker, use docker run debin:slim -v ${PWD}

### 3、TEST CASE 1、2 run at linux VM

由於本機為 Windows 環境，考量 Windows、Linux 環境差異，因此將啟用一個 Ubuntu 18.04 作業系統於 VirtualBox 中，並撰寫相同驗證項目於 Shell 腳本

## 參考

+ Docker-in-Docker with docker.sock
    - [Docker Tips : about /var/run/docker.sock](https://betterprogramming.pub/about-var-run-docker-sock-3bfd276e12fd)
    - [Control Docker containers from within container](https://fredrikaverpil.github.io/2018/12/14/control-docker-containers-from-within-container/)
+ Docker-in-Docker with offical image
    - [Docker in Docker!](https://hub.docker.com/_/docker)
    - [Docker Privileged - Should You Run Privileged Docker Containers?](https://phoenixnap.com/kb/docker-privileged)
