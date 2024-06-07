

## 以k8s的方式配置harbor
   - 如何配置harbor docker镜像服务器images register

1. 部署
make install

2. 上传根证书到服务器并重启docker
make ca-to-alldevice

3. 上传镜像
docker login myharbor1.com
docker pull ubuntu/nginx:1.18-20.04_beta
docker tag ubuntu/nginx:1.18-20.04_beta myharbor1.com/library/ubuntu/nginx:latest
docker tag ubuntu/nginx:1.18-20.04_beta myharbor1.com/library/ubuntu/nginx:1.18-20.04_beta
docker push myharbor1.com/library/ubuntu/nginx:latest
docker push myharbor1.com/library/ubuntu/nginx:1.18-20.04_beta

# harbor页面新创建一个项目group2
# docker tag ubuntu/nginx:1.18-20.04_beta myharbor1.com/group2/ubuntu/nginx:1.18-20.04_beta
# docker push myharbor1.com/group2/ubuntu/nginx:1.18-20.04_beta




4. 使用刚上传的镜像
make test1



#### 访问   harborAdminPassword: "Harbor12345" 
https://myharbor1.com/

curl -k -X GET -u 'admin:Harbor12345' https://myharbor1.com/v2/_catalog 

