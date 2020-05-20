
# k42s
<a id="markdown-k42s" name="k42s"></a>

>k42s is a full multinode Kubernetes Vagrant stack with a real load balancer.

## <img src=".img/architecture.png" alt="Kubernetes" width="600"/>
<a id="markdown-%3Cimg%20src%3D%22.img%2Farchitecture.png%22%20alt%3D%22Kubernetes%22%20width%3D%22600%22%2F%3E" name="%3Cimg%20src%3D%22.img%2Farchitecture.png%22%20alt%3D%22Kubernetes%22%20width%3D%22600%22%2F%3E"></a>

## Why “k42s”?

This project is the result of getting my hands dirty with Kubernetes trying to fulfil my innate curiosity to
understand how things work. In the beginning I have started poking around with Minikube, which at that
time was quite convenient to run my experiments and demos. However, moving forward I have realised that
to have a holistic understanding of Kubernetes ecosystem I had to play with something near running it
in a real multinode production cluster where would possible to experiment with  network policies, load balancers,
ingress controllers, storage and more. Hence, I decided to build my own portable  Kubernetes lab and share it with the
world.


 <img src=".img/warning.png" alt="Kubernetes" width="50"/> This is by no means a Kubernetes production grade setup,
 do not expose ports, services, endpoints to the internet.


## What is Kubernetes?

According to the official [website](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/):

_Kubernetes is a portable, extensible open-source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation. It has a large, rapidly growing ecosystem. Kubernetes services, support, and tools are widely available._


## Features
<a id="markdown-Features" name="Features"></a>

Pod network: [Weave](https://www.weave.works/docs/net/latest/overview/)

K8 Package management: [Helm](https://helm.sh)

Load LoadBalancer: [MetalLB](https://metallb.universe.tf/)

Ingress: [Nginx](https://kubernetes.github.io/ingress-nginx/)

DNS Resolution: [Nip.io](http://nip.io/)

Vagrant base images and templates.

https://app.vagrantup.com/p0bailey/boxes/k8-stable

https://github.com/p0bailey/packer-templates/tree/master/k8


## Installation
<a id="markdown-Installation" name="Installation"></a>

**Requirements**

OS X & Linux:

- Ansible - https://www.ansible.com 
- Virtualbox - https://www.virtualbox.org
- Vagrant - https://www.vagrantup.com
- Heml - https://helm.sh - v3 :)
- k9s - https://k9ss.io


**Other useful tools and plugins**


**Setup**


## Usage example
<a id="markdown-Usage%20example" name="Usage%20example"></a>

**Quickstart:**

`git clone git@github.com:p0bailey/k42s.git`

`make bootstrap`

At the end of the cluster bootstrap you must get this output showing 1 master and 2 worker nodes along with several pods.

<img src=".img/status.png" alt="Kubernetes" width="600"/>

At the end to the bootstrap a KUBECONFIG can be found in the repo root directory, at this point you would need to set KUBECONFIG as an environment variable.

To get the full path of KUBECONFIG and the environment variable values type and use it to set your favourite shell ie. .zshrc , .bashrc  

`K8CONFIG=$(realpath .admin.conf) | echo export KUBECONFIG=$K8CONFIG`


### Hello world

`helm upgrade --install  -f kubernetes/helm/charts/helloworld/values.yaml helloworld ./kubernetes/helm/charts/helloworld`

```
Release "helloworld" has been upgraded. Happy Helming!
NAME: helloworld
LAST DEPLOYED: Wed May 20 09:03:17 2020
NAMESPACE: default
STATUS: deployed
REVISION: 2
NOTES:
1. Get the application URL by running these commands:
  http://helloworld-192-168-56-240.nip.io/
```

<img src=".img/helloworld.png" alt="Kubernetes" width="600"/>

Useful commands:

`kubectl get pods --all-namespaces`

**Advanced:**


## Release History
<a id="markdown-Release%20History" name="Release%20History"></a>

See [CHANGELOG.md](CHANGELOG.md)

## Meta
<a id="markdown-Meta" name="Meta"></a>

Phillip Bailey– [@p0bailey](https://twitter.com/@p0bailey) – phillip@bailey.st

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/p0bailey/k42s](https://github.com/p0bailey/k42s)

## Contributing
<a id="markdown-Contributing" name="Contributing"></a>

1. Fork it (<https://github.com/p0bailey/k42s>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
