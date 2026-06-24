# Istio 故障注入与流量镜像：生产场景详解

## 1. 故障注入（Fault Injection）：主动制造故障，验证系统韧性

### 真实场景
电商平台的支付服务依赖外部第三方支付网关。SRE 需要知道：**如果第三方支付网关变慢或宕机，系统会怎样？**

### 故障注入的用途
通过故意注入延迟或错误，在安全环境下验证系统的容错能力。

### 实战示例

```yaml
# 注入 3 秒延迟（模拟支付网关响应慢）
fault:
  delay:
    percentage:
      value: 100
    fixedDelay: 3s

# 注入 HTTP 500 错误（30% 概率）
fault:
  abort:
    percentage:
      value: 30
    httpStatus: 500
故障注入帮我们回答的问题
问题	如何验证
超时时间设置得够不够？	注入 2s/3s/5s 延迟，观察系统在哪个阈值开始报错
用户体验会怎样？	用户是否会看到"系统繁忙"页面？
下游服务会不会崩溃？	连接池是否会被耗尽？队列是否积压？
熔断器会不会触发？	注入错误，观察熔断器是否生效
类比
火灾演习——你不会等真正火灾来了才知道消防通道好不好用。故障注入就是提前验证系统的容错能力。

2. 流量镜像（Traffic Mirroring）：用真实流量测试新版本
真实场景
开发了新版本的"推荐算法服务"（v2），使用全新的 AI 模型。但不敢直接让真实用户使用，因为：

新算法可能产生错误推荐

新算法可能计算很慢，拖垮整个系统

不知道它会不会崩溃

流量镜像的用途
把生产流量复制一份发给新版本，但不使用它的响应，只观察它的表现。

流量镜像示意
text
生产流量 ──────────────────→ v1 → 返回给用户（真实）
                    ├─────→ v2 → 结果被丢弃（影子）
实战示例
yaml
route:
- destination:
    host: recommendation
    subset: v1
  weight: 100
mirror:
  host: recommendation
  subset: v2
mirrorPercentage:
  value: 100
流量镜像帮我们回答的问题
问题	如何验证
新版本会不会崩溃？	跑几个小时，观察 Pod 是否重启
新版本性能如何？	查看 CPU/内存使用率、响应时间
新版本返回结果对不对？	在后台对比 v1 和 v2 的返回结果
会不会影响数据库？	观察数据库连接数、查询是否超时
类比
飞行员"影子飞行"——一架载客飞机（v1），一架跟班影子飞机（v2），做同样的飞行操作，但不起落、不载客。安全确认后再正式起飞。

3. 两者组合：混沌工程的最佳实践
典型工作流
text
1. 开启流量镜像：把生产流量复制到新版本 v2
2. 对新版本 v2 注入故障：让 v2 变慢/出错
3. 观察 v2 的监控指标（CPU、内存、错误率），看它是否扛得住
4. 安全验证后，把真实流量逐步切换到 v2（金丝雀发布）
这样就在不影响真实用户的情况下，验证了系统在真实流量下的容错能力。

4. 如何验证流量镜像？
开启 Envoy 访问日志
yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: istio
  namespace: istio-system
data:
  mesh: |-
    accessLogFile: /dev/stdout
查看访问日志
bash
# 查看 v2 sidecar 的访问日志
kubectl logs -n <namespace> <pod-name> -c istio-proxy --tail=20
日志解读
text
[2026-06-24T20:32:20.727Z] "GET /reviews/0 HTTP/1.1" 200 - via_upstream - "-" 0 442 414 414 "10.42.2.86" "curl/8.18.0" ... "inbound|9080||" ...
字段	含义
"GET /reviews/0"	收到的是 reviews 服务的请求
"200"	请求处理成功
"10.42.2.86"	来源 IP（productpage Pod）
"inbound|9080||"	入站流量方向
如果 v2 的日志中看到 inbound 请求记录，说明镜像流量确实到达了 v2。

5. 一句话总结
功能	一句话
故障注入	主动制造故障，验证系统在"最坏情况"下是否撑得住
流量镜像	在"真实用户不知道"的情况下，用真实流量测试新版本是否可靠
两者组合	先在影子流量里制造故障，看新版本能不能扛住，再安全上线
6. 生产场景完整示例
yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: recommendation
  namespace: prod
spec:
  hosts:
  - recommendation
  http:
  - route:
    - destination:
        host: recommendation
        subset: v1
      weight: 100
    mirror:
      host: recommendation
      subset: v2
    mirrorPercentage:
      value: 100
    fault:
      abort:
        percentage:
          value: 10
        httpStatus: 500
这个配置的含义：

100% 真实流量 → v1（生产）

100% 镜像流量 → v2（测试新版本）

新版本 v2 收到的是：真实流量的副本 + 10% 的 500 错误

观察 v2 能否承受 10% 的错误率，验证系统的容错能力

