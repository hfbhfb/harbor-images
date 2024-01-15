
CMD1=/usr/bin/cp -f myca.crt /etc/pki/ca-trust/source/anchors/ ; /usr/bin/rm -f /etc/ssl/certs/myca.crt; /usr/bin/ln -s /etc/pki/ca-trust/source/anchors/myca.crt  /etc/ssl/certs/myca.crt; /usr/bin/update-ca-trust
CMD2=systemctl restart docker


helmAppName=myharbor1
Space=harbor

ltsName="lts-aa111"
cnName="myharbor1.com"

# x509　　签发X.509格式证书命令。
# -req　　 表示证书输入请求。
# -days　 表示有效天数
# -extensions 表示按OpenSSL配置文件v3_req项添加扩展。
# -CA 　　表示CA证书,这里为ca.crt
# -CAkey　　表示CA证书密钥,这里为ca.key
# -CAcreateserial 表示创建CA证书序列号
# -extfile　　指定文件    



build-template: ns
	rm -Rf template-out-${helmAppName}
	touch values.yaml
	helm template harbor/ --namespace  ${Space} --values ./values.yaml --name-template ${helmAppName} --output-dir template-out-${helmAppName} --debug


install: create-tls
	-kubectl create ns harbor
	helm install harbor/ --namespace  ${Space} --values ./values.yaml --name-template ${helmAppName}

uninstall:
	helm uninstall  --namespace  ${Space}  ${helmAppName}


create-tls:  # 生成证书
	@echo “生成证书 开始”
	@echo "生成私钥 由私钥创建待签名证书 .csr"
	cd pki; openssl genrsa -out ${cnName}.key 2048
	# 由私钥创建待签名证书 .csr (配置证书要请求的信息)
	cd pki; openssl req  -new -key ./${cnName}.key -out pub.csr -subj "/C=CN/ST=Beijin/O=Devops/CN=${cnName}" -config ./csr.conf
	@echo “对服务器证书签名”
	cd pki;openssl x509 -days 3650 -req -CAkey /Users/hfb/Desktop/good-docs/a-k8s相关/a-ingress-nginx主題/ingress-nginx配置缺省泛域名证书/m2/myca.key -CA /Users/hfb/Desktop/good-docs/a-k8s相关/a-ingress-nginx主題/ingress-nginx配置缺省泛域名证书/m2/myca.crt -CAcreateserial  -in ./pub.csr  -out ./${cnName}.crt -extfile ./csr.conf -extensions v3_req
	@echo "k8s 操作"
	-kubectl delete secret ${ltsName} -n ${Space}
	cd pki;kubectl create secret tls -n ${Space}  ${ltsName} --key ${cnName}.key --cert ${cnName}.crt
	@echo “生成证书 完成”
	cd pki; openssl x509 -in ${cnName}.crt -text -noout 


ca-to-alldevice:
	@echo "上传根证书到服务器并重启"
	# scp ./m2/myca.crt a:/root
	# scp ./m2/myca.crt b:/root
	# scp ./m2/myca.crt c:/root
	# scp ./m2/myca.crt d:/root
	# @echo "部署"
	# ssh a "${CMD1}"
	# ssh b "${CMD1}"
	# ssh c "${CMD1}"
	# ssh d "${CMD1}"
	# @echo "重启docker"
	# ssh a "${CMD2}"
	# ssh b "${CMD2}"
	# ssh c "${CMD2}"
	# ssh d "${CMD2}"

test1:
	kubectl apply -f test1.yaml

ns:
	-kubectl create ns $(Space)

# 下载helm包
pull-helm-tar:
	helm repo add harbor https://helm.goharbor.io
	# helm repo update harbor
	# helm search repo harbor -l
	helm pull harbor/harbor  --untar --version 1.13.1

