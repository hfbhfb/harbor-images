

## 以k8s的方式配置harbor
   - 如何配置harbor docker镜像服务器images register

1. 部署
make install

2. 上传根证书到服务器并重启docker
make ca-to-alldevice

3. 上传镜像
docker login myharbor1.com:32443
docker tag nginx:1.14.2 myharbor1.com:32443/library/nginx:1.14.2
docker push myharbor1.com:32443/library/nginx:1.14.2


4. 使用刚上传的镜像
make test1



#### 访问   harborAdminPassword: "Harbor12345" 
https://myharbor1.com:32443/
