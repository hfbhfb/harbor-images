
CMD1=/usr/bin/cp -f myca.crt /etc/pki/ca-trust/source/anchors/ ; /usr/bin/rm -f /etc/ssl/certs/myca.crt; /usr/bin/ln -s /etc/pki/ca-trust/source/anchors/myca.crt  /etc/ssl/certs/myca.crt; /usr/bin/update-ca-trust
CMD2=systemctl restart docker


helmAppName=myharbor1
Space=harbor

ltsName="lts-aa111"
# cnName=myharbor1.com
cnName=myharborlts.com

# x509　　签发X.509格式证书命令。
# -req　　 表示证书输入请求。
# -days　 表示有效天数
# -extensions 表示按OpenSSL配置文件v3_req项添加扩展。
# -CA 　　表示CA证书,这里为ca.crt
# -CAkey　　表示CA证书密钥,这里为ca.key
# -CAcreateserial 表示创建CA证书序列号
# -extfile　　指定文件    


build-template2: ns
	rm -Rf template-out-${helmAppName}
	touch values.yaml
	helm template harbor/ --namespace  ${Space} --values ./values-https.yaml --name-template ${helmAppName} --output-dir template-out-${helmAppName} --debug



build-template: ns
	rm -Rf template-out-${helmAppName}
	touch values.yaml
	helm template harbor/ --namespace  ${Space} --values ./values.yaml --name-template ${helmAppName} --output-dir template-out-${helmAppName} --debug

optName=/C=CN/ST=Beijin/O=Devops/CN=${cnName}

install: nscreate
	-kubectl create ns harbor
	helm install harbor/ --namespace  ${Space} --values ./values.yaml --name-template ${helmAppName}


installold: nscreate create-tls
	-kubectl create ns harbor
	helm install harbor/ --namespace  ${Space} --values ./values.yaml --name-template ${helmAppName}

uninstall:
	helm uninstall  --namespace  ${Space}  ${helmAppName}

nscreate:
	-kubectl create ns  ${Space}


root-ca:
	mkdir rootca;
	# 创建CA私钥
	cd rootca;openssl genrsa -out myca.key 2048
	# 生成CA待签名证书
	# 由私钥创建待签名证书 .csr (配置证书要请求的信息)
	cd rootca;openssl req  -new -key ./myca.key -out myca.csr -subj "/C=CN/ST=Beijin/O=Devops/CN=*.com"
	# openssl req -new -key ./myca.key -out ./myca.csr
	# 查看证书中的内容
	# openssl req -text -in ./myca.csr -noout
	# 生成CA根证书
	cd rootca;openssl x509 -req -in ./myca.csr -extensions v3_ca -signkey ./myca.key -out ./myca.crt

create-tls:  # 生成证书
	@echo “生成证书 开始”
	@echo "生成私钥 由私钥创建待签名证书 .csr"
	cd pki; openssl genrsa -out ${cnName}.key 2048
	# 由私钥创建待签名证书 .csr (配置证书要请求的信息)
	cd pki; openssl req  -new -key ./${cnName}.key -out pub.csr -subj "/C=CN/ST=Beijin/O=Devops/CN=${cnName}" -config ./csr.conf
	@echo “对服务器证书签名”
	cd pki;openssl x509 -days 3650 -req -CAkey /d/projs/good-docs/a-k8s相关/a-ingress-nginx主題/ingress-nginx配置缺省泛域名证书/m2/myca.key -CA /d/projs/good-docs/a-k8s相关/a-ingress-nginx主題/ingress-nginx配置缺省泛域名证书/m2/myca.crt -CAcreateserial  -in ./pub.csr  -out ./${cnName}.crt -extfile ./csr.conf -extensions v3_req
	@echo "k8s 操作"
	-kubectl delete secret ${ltsName} -n ${Space}
	cd pki;kubectl create secret tls -n ${Space}  ${ltsName} --key ${cnName}.key --cert ${cnName}.crt
	@echo “生成证书 完成”
	cd pki; openssl x509 -in ${cnName}.crt -text -noout 


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

