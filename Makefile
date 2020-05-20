#Authored by Phillip Bailey
.PHONY: all
.SILENT:
SHELL := '/bin/bash'


all:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

bootstrap: up  ## Start and provision k42s cluster with  Nginx ingress and Metallb.
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-bootstrap.yml -vv; \
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-join.yml -vv; \
	./kubectl create ns metallb || true; \
	./helm repo add stable https://kubernetes-charts.storage.googleapis.com; \
	./helm   install   metallb -n metallb -f  kubernetes/helm/charts/metallb/values.yaml stable/metallb; \
	./helm upgrade --install nginx-ingress  stable/nginx-ingress --set rbac.create=true; \
	make status



status:  ## Show k42s cluster status.
	echo "All K8 Services";\
	./kubectl get svc --all-namespaces; \
	echo "All K8 Pods";\
	./kubectl  get pods --all-namespaces; \
	echo "All K8 Cluster nodes";\
	./kubectl  get nodes -o wide


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


hello_world:
	./helm upgrade --install  -f kubernetes/helm/charts/helloworld/values.yaml helloworld ./kubernetes/helm/charts/helloworld

kube_helm_delete: 
	./helm uninstall metallb nginx-ingress helloworld || true