#Authored by Phillip Bailey
.PHONY: all
.SILENT:
SHELL := '/bin/bash'


all:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bootstrap: up  ## Start and provision k42s cluster with  Nginx ingress and Metallb.
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-bootstrap.yml -v; \
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-join.yml -v; \
	KUBECONFIG=.admin.conf kubectl apply -f  kubernetes/manifests/namespaces.yaml; \
	KUBECONFIG=.admin.conf helm repo add stable https://kubernetes-charts.storage.googleapis.com; \
	KUBECONFIG=.admin.conf helm   install   metallb -n metallb -f  kubernetes/helm/charts/metallb/values.yaml stable/metallb; \
	KUBECONFIG=.admin.conf helm upgrade --install nginx-ingress  stable/nginx-ingress --set rbac.create=true; \
	make status


status:  ## Show k42s cluster status.
	echo "All K8 Services";\
	KUBECONFIG=.admin.conf kubectl get svc --all-namespaces; \
	echo "All K8 Pods";\
	KUBECONFIG=.admin.conf kubectl  get pods --all-namespaces; \
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

hello_world_install:
	KUBECONFIG=.admin.conf helm upgrade --install  -f kubernetes/helm/charts/helloworld/values.yaml helloworld ./kubernetes/helm/charts/helloworld

hello_world_delete: 
	KUBECONFIG=.admin.conf helm uninstall helloworld || true


prometheus_install:
	KUBECONFIG=.admin.conf helm upgrade --install prometheus --namespace monitoring -f kubernetes/helm/charts/prometheus-operator/values.yaml  stable/prometheus-operator


prometheus_delete:
	KUBECONFIG=.admin.conf helm uninstall prometheus -n monitoring|| true

nginx_ingress_install:
	KUBECONFIG=.admin.conf helm upgrade --install nginx-ingress  stable/nginx-ingress --set rbac.create=true


nginx_ingress_delete:
	KUBECONFIG=.admin.conf helm uninstall nginx-ingress || true
