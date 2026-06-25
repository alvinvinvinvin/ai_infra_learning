# AI Infra 学习快速参考 v2

## 当前阶段：K3s + vLLM 性能优化

### 核心工具链
| 工具 | 用途 |
|------|------|
| vLLM | 推理引擎 |
| K3s | 轻量级 K8s |
| Istio | 服务网格 + 流量管理 |
| Prometheus/Grafana | 可观测性 |
| Locust | 压测工具 |
| Docker | 容器化 |
| Velero | 备份与恢复 |

### 关键命令速查

#### K3s 部署 vLLM
```bash
# 构建镜像
docker build -t vllm-service:latest .

# 部署到 K3s
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f virtualservice.yaml
压测
bash
# 在集群内启动 Locust
kubectl run locust --image=locustio/locust -n k8s-learning \
    --command -- locust -f /mnt/locustfile.py --host=http://vllm-service:8000
查看性能
bash
# Prometheus 查询
rate(vllm_request_duration_seconds_sum[5m]) / rate(vllm_request_duration_seconds_count[5m])

# 查看 Pod 资源
kubectl top pod -n k8s-learning
优化参数速查
参数	影响	建议值
--max-num-seqs	并发处理能力	256-512
--max-model-len	最大输入长度	根据显存调整
--gpu-memory-utilization	显存使用率	0.85-0.95
--enable-prefix-caching	缓存前缀	开启（如适用）
--block-size	KV Cache 块大小	16 或 32
--quantization	量化类型	gptq / awq
