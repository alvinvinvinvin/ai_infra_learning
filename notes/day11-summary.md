# Day 11: Helm, RBAC, and Service Mesh (Istio)

## 1. Helm — Kubernetes Package Manager

### What is it?
Helm is the package manager for Kubernetes. Think of it as `apt` for Ubuntu, `pip` for Python, or `npm` for Node.js.

### What does it do?
- **Packaging**: Groups multiple K8s YAML files (Deployment, Service, ConfigMap, etc.) into a single **Chart**
- **Install**: Deploys complex applications with one command (`helm install nginx bitnami/nginx`)
- **Upgrade**: Modifies configuration and applies changes (`helm upgrade`)
- **Rollback**: Reverts to a previous version if something breaks (`helm rollback`)
- **Versioning**: Tracks every change with revision history (`helm history`)

### Production Use Cases

| Scenario | Description |
|----------|-------------|
| **Microservices Deployment** | A microservice may have 10+ K8s resource files. Helm packages them into one Chart for easy sharing across teams. |
| **Multi-environment Config** | The same Chart uses `values-dev.yaml` and `values-prod.yaml` to separate development and production settings. |
| **Third-party Software** | Tools like Prometheus, Grafana, MySQL, and Redis have official Helm Charts — deploy with a single command. |
| **Rollback on Failure** | If an upgrade introduces bugs, `helm rollback` quickly restores the stable version. |

**Today's Practice**: Deployed Nginx, scaled replicas from 1 to 3, then rolled back to 1.

---

## 2. RBAC — Kubernetes Access Control

### What is it?
**RBAC (Role-Based Access Control)** defines who (User/ServiceAccount) can perform what actions (get/create/delete) on which resources (Pods/Services/ConfigMaps).

### What does it do?
- **Principle of Least Privilege**: Grants only necessary permissions
- **Multi-tenant Isolation**: Different teams access only their own namespaces
- **Security & Compliance**: Audits who performed which operations

### Core Concepts

| K8s Concept | Plain English |
|-------------|---------------|
| **Role** | "Job Description": Defines what actions are allowed (e.g., "can only view Pods") |
| **RoleBinding** | "Assignment Letter": Assigns the role to a specific user/SA |
| **ClusterRole** | "Company-wide Role": Permissions apply across the entire cluster |
| **ClusterRoleBinding** | "Company-wide Assignment" |
| **ServiceAccount** | "Program's ID Card": Used by Pods to authenticate with the API server |

### Production Use Cases

| Scenario | Configuration |
|----------|---------------|
| **CI/CD Pipeline** | Jenkins/GitLab Runner's ServiceAccount is only granted `create/update` permissions in the `deploy` namespace. |
| **Monitoring** | Prometheus ServiceAccount is only granted `get/list` permissions for scraping metrics. |
| **Dev/Ops Separation** | Developers operate only in `dev` namespaces; Ops manages `prod` namespaces. |
| **Audit Requirements** | A finance system Pod can only read Secrets in the `finance` namespace, not access others. |

**Today's Practice**: Created a `pod-reader` Role, bound it to the `dev-user` ServiceAccount, and verified it only had `get/list/watch` permissions (no `delete`).

---

## 3. Service Mesh (Istio) — Smart Networking Layer for Microservices

### What is it?
Service Mesh is an **infrastructure layer** that injects a **Sidecar proxy (Envoy)** next to each application Pod. This proxy intercepts all network traffic, enabling **traffic management, security, and observability** without modifying application code.

### What does it do?
- **Traffic Control**: Canary releases, A/B testing, weighted routing
- **Security**: Automatic mTLS encryption between services
- **Observability**: Auto-generates traffic topology, latency, error rate metrics
- **Fault Injection**: Simulates service delays or failures to test resilience
- **Timeouts/Retries**: Centralized configuration for call timeouts and retry policies

### Production Use Cases

| Scenario | Description |
|----------|-------------|
| **Canary Release** | New version receives only 10% of traffic; gradually increase after validation. |
| **A/B Testing** | Routes traffic based on HTTP headers (e.g., `user-group=vip`) to different versions. |
| **Blue/Green Deployment** | Two environments (blue/green); switch all traffic with one action. |
| **Fault Injection** | Simulates a 5-second delay on a service to test system resilience. |
| **mTLS Encryption** | All service-to-service communication is automatically encrypted without code changes. |
| **Visual Topology** | Kiali shows all service call relationships for quick bottleneck identification. |

**Today's Practice**: Deployed the Bookinfo application, configured weighted routing for the `reviews` service (50% to v1, 50% to v3), and demonstrated traffic splitting.

---

## How They Work Together
Application Developer → Writes Code → Builds Container Image
DevOps → Packages K8s Resources with Helm → Deploys to K8s
├── RBAC controls who has deployment permissions
└── Service Mesh controls traffic, security, and observability

### A Complete Production Example

Imagine you're running an **online store** with multiple microservices:

1. **Helm**: Uses a Helm Chart to uniformly deploy the `Order Service`, `Payment Service`, and `Inventory Service`
2. **RBAC**: Only the CI/CD system has permission to deploy to the `prod` namespace; developers can only view logs
3. **Service Mesh**:
   - The new version of Payment Service receives only 5% of traffic (canary release)
   - All service-to-service communication is automatically encrypted
   - Kiali provides visual call-chain diagrams to quickly identify performance bottlenecks

