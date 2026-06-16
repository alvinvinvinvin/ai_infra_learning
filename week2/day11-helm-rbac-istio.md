# Day 11: Helm, RBAC, and Service Mesh (Istio)

## Date: 2026-06-16

## Learning Objectives
- [x] Install and use Helm package manager
- [x] Understand RBAC (Role, RoleBinding, ClusterRole, ClusterRoleBinding)
- [x] Install Istio and configure traffic management

---

## 1. Helm

### What I Did
- Installed Helm v3.21.1
- Added Bitnami and Stable repositories
- Deployed Nginx using `helm install`
- Upgraded replica count from 1 to 3
- Rolled back to revision 1

### Key Commands
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-nginx bitnami/nginx -n k8s-learning
helm upgrade my-nginx bitnami/nginx -n k8s-learning --set replicaCount=3
helm history my-nginx -n k8s-learning
helm rollback my-nginx 1 -n k8s-learning
helm uninstall my-nginx -n k8s-learning
Key Takeaways
Helm charts package multiple K8s resources into a single deployable unit

--set overrides values; production uses values.yaml files

Each change creates a revision for easy rollback

2. RBAC (Role-Based Access Control)
What I Did
Created dev and prod namespaces

Created Role pod-reader with get/list/watch permissions on pods

Created ServiceAccount dev-user

Created RoleBinding linking the Role to the ServiceAccount

Tested permissions with token authentication

Key Configuration Files
Role (pod-reader):

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: dev
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

RoleBinding (read-pods-binding):

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-binding
  namespace: dev
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io

Key Commands

kubectl create namespace dev
kubectl create sa dev-user -n dev
kubectl apply -f role.yaml
kubectl apply -f rolebinding.yaml

# Test permissions
SA_TOKEN=$(kubectl get secret -n dev $(kubectl get sa dev-user -n dev -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 -d)
kubectl get pods -n dev --token=$SA_TOKEN
kubectl delete pod test-pod -n dev --token=$SA_TOKEN

Key Takeaways
Role = namespace-scoped permissions

ClusterRole = cluster-wide permissions

RoleBinding binds Role to user/SA within a namespace

ClusterRoleBinding binds ClusterRole across the cluster

K3s has default system:authenticated group permissions that may override custom RBAC

kubectl auth can-i is the reliable way to test permissions

3. Service Mesh (Istio)
What I Did
Downloaded and installed Istio 1.30.1 with demo profile

Enabled automatic sidecar injection on k8s-learning namespace

Deployed Bookinfo sample application

Configured Gateway and VirtualService for external access

Implemented weighted routing (50/50 split between reviews v1 and v3)

Key Configuration Files
Gateway (bookinfo-gateway):

apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: bookinfo-gateway
  namespace: k8s-learning
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
VirtualService (bookinfo):

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: bookinfo
  namespace: k8s-learning
spec:
  gateways:
  - bookinfo-gateway
  hosts:
  - "*"
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage.k8s-learning.svc.cluster.local
        port:
          number: 9080

DestinationRule (reviews):

apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: reviews
  namespace: k8s-learning
spec:
  host: reviews.k8s-learning.svc.cluster.local
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3

VirtualService (reviews - weighted routing):

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews
  namespace: k8s-learning
spec:
  hosts:
  - reviews.k8s-learning.svc.cluster.local
  http:
  - route:
    - destination:
        host: reviews.k8s-learning.svc.cluster.local
        subset: v1
      weight: 50
    - destination:
        host: reviews.k8s-learning.svc.cluster.local
        subset: v3
      weight: 50

Key Commands

# Install Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.30.1
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y

# Enable sidecar injection
kubectl label namespace k8s-learning istio-injection=enabled

# Deploy Bookinfo
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml -n k8s-learning

# Apply configurations
kubectl apply -f gateway.yaml
kubectl apply -f virtualservice.yaml
kubectl apply -f destinationrule.yaml
kubectl apply -f reviews-virtualservice.yaml

# Access Bookinfo
NODE_PORT=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
curl http://$NODE_IP:$NODE_PORT/productpage


Key Takeaways
Sidecar injection adds Envoy proxy to each Pod (2/2 READY)

Gateway controls inbound traffic (external → cluster)

VirtualService defines routing rules (which service receives traffic)

DestinationRule defines subsets (versions) and load balancing policies

Weighted routing enables canary releases and A/B testing

Resources must be in the same namespace as the services they reference

mTLS can cause authentication issues; use PERMISSIVE mode during debugging

Use istioctl analyze to check configuration conflicts

Issues Encountered & Solutions
Issue	Solution
Sidecar not injected	Label namespace with istio-injection=enabled, delete and recreate Pods
Gateway not found	Use gateways.networking.istio.io (not gateway.networking.k8s.io)
VirtualService referencing default namespace	Use FQDN: productpage.k8s-learning.svc.cluster.local
503 NC cluster_not_found	Restart istiod and ingressgateway; verify VirtualService in correct namespace
Gateway resource conflict	Delete test-gateway; only one gateway can bind to same selector/port/host
mTLS authentication errors	Set PeerAuthentication with mode: PERMISSIVE or DISABLE
No output from curl	Check NodePort and service configuration; use port-forward for debugging
Commands Learned Today


# Helm
helm repo add <name> <url>
helm install <release> <chart> -n <namespace>
helm upgrade <release> <chart> -n <namespace> --set key=value
helm history <release> -n <namespace>
helm rollback <release> <revision> -n <namespace>
helm uninstall <release> -n <namespace>

# RBAC
kubectl create sa <name> -n <namespace>
kubectl create role <name> --verb=get,list,watch --resource=pods -n <namespace>
kubectl create rolebinding <name> --role=<role> --serviceaccount=<namespace>:<sa> -n <namespace>
kubectl auth can-i <verb> <resource> -n <namespace> --as=system:serviceaccount:<ns>:<sa>

# Istio
istioctl install --set profile=demo -y
istioctl analyze -n <namespace>
kubectl label namespace <ns> istio-injection=enabled
kubectl get gateways.networking.istio.io -n <namespace>
kubectl get virtualservices.networking.istio.io -n <namespace>
kubectl get destinationrules.networking.istio.io -n <namespace>


References
Helm Documentation

Kubernetes RBAC

Istio Documentation

Bookinfo Application
