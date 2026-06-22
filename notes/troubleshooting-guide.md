# Kubernetes 故障排查实战指南

## 核心命令速查

| 命令 | 一句话记住 | 何时使用 |
|------|-----------|----------|
| `kubectl describe` | 看事件，找原因 | Pod 状态异常（CrashLoopBackOff、Pending、ImagePullBackOff） |
| `kubectl logs` | 看程序自己说了啥 | 需要查看应用日志、启动报错时 |
| `kubectl exec` | 进容器内部看 | 需要从容器内部测试网络、查看文件系统时 |
| `kubectl debug` | 容器没工具时，外挂工具箱 | 容器内缺少 curl、ps、netstat 等排查工具时 |
| `kubectl get events` | 看集群最近发生了什么 | 集群出现大规模异常，不知道从哪查起时 |

---

## 排查流程（一条龙思路）
kubectl get pods → 看看谁状态不正常

kubectl describe pod <name> → 看 Events 找原因

kubectl logs <name> → 看容器日志

kubectl exec -it <name> -- /bin/sh → 进入容器内部排查

kubectl debug <name> → 容器没 bash/curl 时使用

kubectl get events --sort-by → 看集群级事件

text

---

## 场景 1：Pod 疯狂重启（CrashLoopBackOff）

### 真实案例
某 Java 应用启动需要 45 秒，但 livenessProbe 的 `initialDelaySeconds` 设置为 10 秒，导致 Pod 还没启动完成就被 kubelet 判定为不健康并重启。

### 排查步骤

```bash
# 1. 看状态
kubectl get pods
# 输出：my-java-app-xxx  0/1   CrashLoopBackOff   5 (2m ago)

# 2. 看事件 — 这里会直接告诉你原因
kubectl describe pod my-java-app-xxx
# 输出：Liveness probe failed: Get "http://10.42.2.15:8080/health": dial tcp 10.42.2.15:8080: connection refused
解决方案
yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 60  # 等待足够长的时间让应用启动
  periodSeconds: 10
  failureThreshold: 3      # 允许 3 次失败再重启
场景 2：容器内没有排查工具（kubectl debug）
真实案例
生产镜像为了安全做了极致精简，里面没有 bash、curl、ps、netstat 等任何工具。出了故障完全无法排查。

解决方案
bash
# 不需要改代码、不需要重新构建镜像
# 直接在 Pod 旁边挂载一个"工具箱容器"
kubectl debug -it payment-service-xxx --image=busybox --target=payment-service
调试命令示例
bash
# 在临时容器内执行
ps aux              # 查看进程是否启动成功
netstat -tlnp       # 查看端口是否正常监听
cat /proc/1/environ # 查看环境变量
curl localhost:8080/health  # 测试健康检查端点
什么时候用 kubectl debug？
容器启动即崩溃（CrashLoopBackOff）

容器内缺少排查工具（没有 curl、nslookup、ps）

需要查看进程、网络、文件系统状态

场景 3：Pod 之间网络不通
真实案例
frontend 调用 backend 时报错 connection refused，两个 Pod 在同一个集群，网络却不通。

排查步骤
bash
# 1. 确认 backend 的 Service 是否存在
kubectl get svc backend

# 2. 进入 frontend 容器，手动测试网络
kubectl exec -it frontend-xxx -- /bin/sh

# 在容器内执行
nslookup backend.default.svc.cluster.local  # DNS 能解析吗？
curl http://backend:8080/health              # 端口通吗？
常见问题
现象	可能原因
DNS 解析失败	CoreDNS 异常
端口不通	Service 的 targetPort 不匹配 Pod 的 containerPort
连接超时	NetworkPolicy 拦截了流量
场景 4：集群异常但不知道从哪查起（kubectl get events）
真实案例
早上发现好几个 Pod 处于 Pending 状态，节点资源充足，没有明显的错误日志。

解决方案
bash
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -30
输出示例
text
84s   Warning   FailedScheduling   pod/order-service-xxx   0/2 nodes are available: 1 node(s) had taint {dedicated: ai}
什么时候用 kubectl get events？
集群出现大规模异常，不知道从哪查起时

想知道最近集群里发生了什么变化时

排查调度、网络、存储相关问题时

常用调试命令速查
场景	命令
查看 Pod 实时日志	kubectl logs -f <pod-name>
查看最后 20 行日志	kubectl logs --tail=20 <pod-name>
查看 Pod 完整 YAML	kubectl get pod <name> -o yaml
查看 Pod 资源使用	kubectl top pod <name>
进入容器	kubectl exec -it <pod> -- /bin/sh
端口转发调试	kubectl port-forward pod/<name> 8080:80
查看所有事件	kubectl get events --all-namespaces --sort-by='.lastTimestamp'
查看 Pod 事件	kubectl describe pod <name> | grep -A 10 Events
临时容器调试	kubectl debug -it <pod> --image=busybox --target=<container>
生产环境镜像无调试工具时的应对方案
生产镜像为了安全和体积，通常不包含调试工具。以下 3 种方案可以解决这个问题：

方案	说明
kubectl debug 临时容器	K8s 原生方案，启动一个包含工具的临时容器，共享进程命名空间
Ephemeral Container	类似临时容器，更轻量
单独构建调试镜像	生产用精简镜像，调试用含工具的镜像，通过 Deployment 替换临时调试
