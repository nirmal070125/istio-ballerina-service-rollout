# istio-ballerina-service-rollout


## install docker
```bash
sudo apt-get update
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
```
    
## install kubectl

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo su
kubectl version
```
***eg:***
<pre>
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.0", GitCommit:"e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529", GitTreeState:"clean", BuildDate:"2019-06-19T16:40:16Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
</pre>

**NOTE: k8s server will be installed in next step.**

## install minikube

```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64   && chmod +x minikube
sudo cp minikube /usr/local/bin && rm minikube
minikube start --memory=6000 --cpus=4 --vm-driver=none
kubectl version 
```
***eg:***
<pre>
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.0", GitCommit:"e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529", GitTreeState:"clean", BuildDate:"2019-06-19T16:40:16Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.3", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:36:19Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
</pre>

```bash
$ kubectl get pods -n kube-system
NAME                               READY   STATUS             RESTARTS   AGE
coredns-fb8b8dccf-gjz8v            0/1     CrashLoopBackOff   5          5m49s
coredns-fb8b8dccf-jcg4j            0/1     CrashLoopBackOff   5          5m49s
etcd-minikube                      1/1     Running            0          4m45s
kube-addon-manager-minikube        1/1     Running            0          5m59s
kube-apiserver-minikube            1/1     Running            0          5m3s
kube-controller-manager-minikube   1/1     Running            0          4m38s
kube-proxy-z5rtw                   1/1     Running            0          5m49s
kube-scheduler-minikube            1/1     Running            0          4m41s
storage-provisioner                1/1     Running            0          5m48s
```

**NOTE: that the coredns pods are not starting up properly due to the loop crash issue**

### Fix loop crash of coredns 
(solve the issue with loop back crash: https://github.com/kubernetes/kubeadm/issues/998#issuecomment-456824912)

```bash
kubectl -n kube-system edit configmap coredns
# comment the line containing "loop", save and exit (:x).
kubectl -n kube-system delete pod -l k8s-app=kube-dns
```
**NOTE: now you shouldn't see the above error**

```bash
# kubectl get pods -n kube-system
NAME                               READY   STATUS    RESTARTS   AGE
coredns-fb8b8dccf-h5d2t            1/1     Running   0          13s
coredns-fb8b8dccf-ljsc2            1/1     Running   0          13s
etcd-minikube                      1/1     Running   0          10m
kube-addon-manager-minikube        1/1     Running   0          11m
kube-apiserver-minikube            1/1     Running   0          10m
kube-controller-manager-minikube   1/1     Running   0          10m
kube-proxy-z5rtw                   1/1     Running   0          11m
kube-scheduler-minikube            1/1     Running   0          10m
storage-provisioner                1/1     Running   0          11m
```

## install istio

```bash
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.7 sh -
cd istio-1.1.7
export PATH=$PWD/bin:$PATH
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
kubectl apply -f install/kubernetes/istio-demo.yaml
kubectl get pods -n istio-system

# after a few minutes, you should see pods are either Running or completed.

$ kubectl get pods -n istio-system
NAME                                      READY   STATUS      RESTARTS   AGE
grafana-67c69bb567-clwkv                  1/1     Running     0          6m7s
istio-citadel-fc966574d-khs7f             1/1     Running     0          6m7s
istio-cleanup-secrets-1.1.7-sm7pj         0/1     Completed   0          6m8s
istio-egressgateway-6b4cd4d9f-n8x2f       1/1     Running     0          6m7s
istio-galley-cf776876f-x64dv              1/1     Running     0          6m7s
istio-grafana-post-install-1.1.7-drkxj    0/1     Completed   0          6m8s
istio-ingressgateway-59cc6ccbcb-gzbq5     1/1     Running     0          6m7s
istio-pilot-7b4dd9b748-zsk6h              2/2     Running     0          6m7s
istio-policy-5bcc859488-7cn4h             2/2     Running     5          6m7s
istio-security-post-install-1.1.7-5sb2l   0/1     Completed   0          6m8s
istio-sidecar-injector-c8ddbb99c-7jhbh    1/1     Running     0          6m6s
istio-telemetry-7678c9bb4d-n8gv9          2/2     Running     4          6m7s
istio-tracing-5d8f57c8ff-dq8sz            1/1     Running     0          6m6s
kiali-d4d886dd7-9wphp                     1/1     Running     0          6m7s
prometheus-d8d46c5b5-96smr                1/1     Running     0          6m7s
```

## install open jdk

```bash
apt install openjdk-8-jre-headless
# add JAVA_HOME to the end of the ~/.bashrc file.
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc
source ~/.bashrc
echo $JAVA_HOME
```

## install ballerina

```bash
cd /home/ubuntu
wget https://product-dist.ballerina.io/nightly/0.991.1-SNAPSHOT/ballerina-0.991.1-SNAPSHOT.zip
apt-get install zip
unzip -q ballerina-0.991.1-SNAPSHOT.zip
cd ballerina-0.991.1-SNAPSHOT 
echo  'export PATH=$PWD/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
ballerina version 
```

## install the sample

```bash
cd /home/ubuntu
git clone https://github.com/nirmal070125/istio-ballerina-service-rollout.git
cd istio-ballerina-service-rollout
ballerina build welcome-v1.bal
# verify the docker image was built
docker images |grep welcome 
kubectl label namespace default istio-injection=enabled
kubectl apply -f welcome.yaml 
kubectl get pods 
  NAME                         READY   STATUS    RESTARTS   AGE
  welcome-v1-bbbb87dc9-5tzb8   2/2     Running   0          98s
kubectl apply -f welcome-gateway.yaml
# IP of the k8s cluster
minikube ip 
kubectl get svc -n istio-system | grep istio-ingressgateway
  istio-ingressgateway     LoadBalancer   10.99.19.6       <pending>          15020:31775/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:31958/TCP,15030:31214/TCP,15031:32565/TCP,15032:32240/TCP,15443:31331/TCP   119m
```

**NOTE: if external ip is "<pending>", use port as "31380", if there's an external IP assigned, use port as "80"**
    
Open your browser and enter the url: `http://<minikubeip or external ip>:<31380|80>/welcome/Chicago`
      
    
## Do a version rollout
```bash
# add subsets - available versions
kubectl apply -f welcome-svc-destination-rule.yaml 
# add the traffic routing rules
kubectl apply -f welcome-svc-virtual-service-100-0.yaml 
# deploy welcome v2
ballerina  build welcome-v2.bal 
kubectl apply -f welcome-add-v2.yaml
kubectl get pods
  NAME                          READY   STATUS    RESTARTS   AGE
  welcome-v1-bbbb87dc9-5tzb8    2/2     Running   0          20h
  welcome-v2-5cb946fdbf-9nccr   2/2     Running   0          6m59s
# route 20% of traffic to v2
kubectl apply -f welcome-svc-virtual-service-80-20.yaml
```

Open your browser and enter the url: `http://<minikubeip or external ip>:<31380|80>/welcome/Chicago`

        - you should see the v2 (*WSO2* instead of *WSO*) appearing time to time.
    
Once you are satisfied with the v2, we'll set the traffic rules to route all the traffic to v2
```bash
kubectl apply -f welcome-svc-virtual-service-0-100.yaml 
```

## Grafana dashboard

```bash
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 &
```

URL: `http://localhost:3000/dashboard/db/istio-mesh-dashboard`

