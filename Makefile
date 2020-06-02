#Authored by Phillip Bailey
.PHONY: all
.SILENT:
SHELL := '/bin/bash'
export KUBECONFIG=.admin.conf

ISTIO_VERSION := 1.6.0

all:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bootstrap: up  ## Start and provision k42s cluster.
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-bootstrap.yml; \
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-join.yml; \
	kubectl apply -f  kubernetes/manifests/namespaces.yaml; \
	helm repo add stable https://kubernetes-charts.storage.googleapis.com; \
	helm   install   metallb -n metallb -f  kubernetes/helm/charts/metallb/values.yaml stable/metallb; \
	make full; \
	make status


status:  ## Show k42s cluster status.
	echo "All K8 Pods";\
	KUBECONFIG=.admin.conf kubectl  get pods --all-namespaces -o wide; \
	echo "All K8 Services";\
	KUBECONFIG=.admin.conf kubectl get svc --all-namespaces -o wide; \
	echo "All K8 Cluster nodes";\
	KUBECONFIG=.admin.conf kubectl  get nodes -o wide


join_node: up  ## Join new node into k42s cluster.
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-join.yml

up: ## Start k42s cluster.
	  vagrant up --parallel

down: ## Stop k42s cluster.
	  vagrant halt

Destroy: ## Destroy k42s cluster!!!.
	  vagrant destroy --force; \
		rm -f .admin.conf; \
		rm -f dashboard_token.txt


#kubectl label namespace monitoring  istio-injection=enabled || true; \

#### Istio
istio_install:
	kubectl create ns istio-system || true;
	KUBECONFIG=../../.admin.conf && cd kubernetes/istio-$(ISTIO_VERSION) && istioctl manifest apply \
	--set profile=demo --set values.grafana.enabled=false \
	--set values.prometheus.enabled=true --set values.kiali.enabled=true  --set values.gateways.istio-egressgateway.enabled=false; \
	helm upgrade --install istio-gateway-config --namespace istio-system -f ../helm/charts/istio-config/values.yaml ../helm/charts/istio-config; \
	cd ../certs/ && kubectl create -n istio-system secret tls  nip.io --key=nip.io.key --cert=nip.io.pem || true 
 
istio_delete:	
	KUBECONFIG=../../.admin.conf && cd kubernetes/istio-$(ISTIO_VERSION)  && istioctl manifest generate --set profile=demo | kubectl delete -f - || true \
	&& kubectl delete secrets nip.io   -n istio-system || true && kubectl delete namespace istio-system || true

istio_certs_install:  
	KUBECONFIG=../../.admin.conf && cd kubernetes/certs && kubectl create -n istio-system secret tls  nip.io --key=nip.io.key --cert=nip.io.pem || true

istio_certs_delete:
	KUBECONFIG=../../.admin.conf && cd kubernetes/certs && kubectl delete secrets nip.io   -n istio-system || true
 
prometheus_install:
	kubectl create ns monitoring || true; \
	helm upgrade --install prometheus --namespace monitoring -f kubernetes/helm/charts/prometheus-operator/values.yaml  stable/prometheus-operator; \
	make status

prometheus_delete:
	helm uninstall prometheus -n monitoring || true; \
	kubectl delete ns monitoring

weave_install:
	kubectl create ns weave-scope  || true; \
	helm upgrade --install   weave-scope --namespace weave-scope stable/weave-scope

weave_delete:
	helm uninstall weave-scope -n weave-scope || true; \
	kubectl delete ns weave-scope

full:
	make istio_install; \
	make prometheus_install; \
	make weave_install; \
	make status

clean:
	make istio_delete; \
	make prometheus_delete; \
	make weave_delete; \
	make status


## Demo 1
demo_1_install:
	kubectl create namespace demo1 || true; \
	helm upgrade --install --namespace  demo1 -f kubernetes/helm/charts/demo1/values.yaml demo1 ./kubernetes/helm/charts/demo1


demo_1_delete:
	helm uninstall demo1 || true; \
	kubectl delete namespaces demo1 || true





