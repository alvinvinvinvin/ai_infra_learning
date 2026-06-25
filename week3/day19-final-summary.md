# Day 19: 镜像安全扫描 + Kubernetes 安全加固 + CIS Benchmark

**日期**: 2026-06-25

## 1. 镜像安全扫描 (Trivy)

### 扫描结果
- 镜像: `docker.io/istio/examples-bookinfo-productpage-v1:1.20.2`
- 操作系统: Debian 12.4
- 总漏洞: 74 (HIGH: 59, CRITICAL: 15)
- Python 包漏洞: 7 (HIGH)

### 关键漏洞摘要
- **OpenSSL**: 多个 CRITICAL 漏洞 (CVE-2026-31789, CVE-2024-6119 等)
- **glibc**: 多个 HIGH 漏洞 (CVE-2024-2961, CVE-2024-33599)
- **libexpat**: CRITICAL 整数溢出 (CVE-2024-45491, CVE-2024-45492)
- **SQLite**: CRITICAL 漏洞 (CVE-2025-6965)
- **Perl**: CRITICAL 路径遍历 (CVE-2026-42496)
- **setuptools/urllib3**: HIGH 漏洞

### 修复建议
- 升级基础镜像到最新安全补丁版本 (Debian 12 已发布修复包)
- 对于 Python 包，使用 `pip install --upgrade` 更新受影响包
- 考虑使用更精简的镜像 (如 Alpine) 减少攻击面

## 2. 策略引擎 (OPA/Gatekeeper)

### 部署
- Gatekeeper 已成功部署并运行
- 创建了以下约束模板和约束：
  1. `K8sRequiredTags` - 禁止使用 `:latest` 标签
  2. `K8sPrivileged` - 禁止特权容器
  3. `K8sRequiredResources` - 要求资源限制

### 测试结果
- ✅ 拒绝使用 `:latest` 镜像的 Pod (`test-latest2`)
- ✅ 允许使用固定标签 (`nginx:1.21`) 的 Pod (`test-good`)
- 强制执行动作: `deny` (通过 `enforcementAction: deny`)

### 命令
```bash
# 查看约束
kubectl get constraints
# 查看日志
kubectl logs -n gatekeeper-system deployment/gatekeeper-controller-manager
3. CIS Benchmark (kube-bench)
执行
运行了 kube-bench 针对 Kubernetes 1.24 的 CIS 基准测试

输出结果保存至 security-reports/kube-bench.json

发现 (摘要)
[待从报告中提取]

建议
检查未通过的配置项

根据 CIS 建议进行加固

4. 网络安全加固
NetworkPolicy
创建了默认拒绝所有 Ingress/Egress 的 NetworkPolicy

允许 productpage 服务的入站流量

5. 综合建议
镜像安全

建立镜像扫描 CI/CD 流程

定期更新基础镜像

避免使用 :latest 标签

策略强制执行

将 Gatekeeper 策略应用到所有命名空间

使用审计模式先测试策略影响

合规检查

定期运行 kube-bench

修复 CIS 基准中的失败项

监控与审计

启用 Kubernetes 审计日志

监控安全事件

附录：使用的命令
bash
# Trivy 扫描
trivy image --severity HIGH,CRITICAL <image>

# Gatekeeper 策略
kubectl apply -f gatekeeper-*.yaml

# kube-bench
kube-bench run --targets master --benchmark cis-1.24 --json

## Trivy 扫描详情 (productpage)


Report Summary

┌──────────────────────────────────────────────────────────────────────────────────┬────────────┬─────────────────┬─────────┐
│                                      Target                                      │    Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ docker.io/istio/examples-bookinfo-productpage-v1:1.20.2 (debian 12.4)            │   debian   │       74        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/Deprecated-1.2.14.dist-info/METADATA      │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/Flask_Bootstrap-3.3.7.1.dist-info/METADA- │ python-pkg │        0        │    -    │
│ TA                                                                               │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/Flask_JSON-0.4.0.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/MarkupSafe-2.1.5.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/blinker-1.8.2.dist-info/METADATA          │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/certifi-2024.7.4.dist-info/METADATA       │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/charset_normalizer-3.3.2.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/click-8.1.3.dist-info/METADATA            │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/dominate-2.9.1.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/flask-3.0.2.dist-info/METADATA            │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/future-0.18.3.dist-info/METADATA          │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/gevent-24.2.1.dist-info/METADATA          │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/greenlet-3.0.3.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/gunicorn-22.0.0.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/idna-3.7.dist-info/METADATA               │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/importlib_metadata-6.11.0.dist-info/META- │ python-pkg │        0        │    -    │
│ DATA                                                                             │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/itsdangerous-2.2.0.dist-info/METADATA     │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/jinja2-3.1.4.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/json2html-1.3.0.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_api-1.22.0.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_instrumentation-0.43b0.dis- │ python-pkg │        0        │    -    │
│ t-info/METADATA                                                                  │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_instrumentation_flask-0.43- │ python-pkg │        0        │    -    │
│ b0.dist-info/METADATA                                                            │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_instrumentation_wsgi-0.43b- │ python-pkg │        0        │    -    │
│ 0.dist-info/METADATA                                                             │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_propagator_b3-1.22.0.dist-- │ python-pkg │        0        │    -    │
│ info/METADATA                                                                    │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_sdk-1.22.0.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_semantic_conventions-0.43b- │ python-pkg │        0        │    -    │
│ 0.dist-info/METADATA                                                             │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/opentelemetry_util_http-0.43b0.dist-info- │ python-pkg │        0        │    -    │
│ /METADATA                                                                        │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/packaging-24.0.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/pip-23.2.1.dist-info/METADATA             │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/prometheus_client-0.19.0.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/requests-2.32.2.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/requests_mock-1.5.2.dist-info/METADATA    │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/setuptools-69.0.3.dist-info/METADATA      │ python-pkg │        2        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/simplejson-3.19.2.dist-info/METADATA      │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/six-1.16.0.dist-info/METADATA             │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/typing_extensions-4.11.0.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/urllib3-2.2.2.dist-info/METADATA          │ python-pkg │        4        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/visitor-0.1.3.dist-info/METADATA          │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/werkzeug-3.0.3.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/wheel-0.42.0.dist-info/METADATA           │ python-pkg │        1        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/wrapt-1.16.0.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/zipp-3.19.1.dist-info/METADATA            │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/zope.event-5.0.dist-info/METADATA         │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ usr/local/lib/python3.12/site-packages/zope.interface-6.4.post2.dist-info/METAD- │ python-pkg │        0        │    -    │
│ ATA                                                                              │            │                 │         │
└──────────────────────────────────────────────────────────────────────────────────┴────────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)


docker.io/istio/examples-bookinfo-productpage-v1:1.20.2 (debian 12.4)
=====================================================================
Total: 74 (HIGH: 59, CRITICAL: 15)

┌────────────────────┬────────────────┬──────────┬──────────────┬───────────────────┬────────────────────┬──────────────────────────────────────────────────────────────┐
│      Library       │ Vulnerability  │ Severity │    Status    │ Installed Version │   Fixed Version    │                            Title                             │
├────────────────────┼────────────────┼──────────┼──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ gpgv               │ CVE-2025-68973 │ HIGH     │ fixed        │ 2.2.40-1.1        │ 2.2.40-1.1+deb12u2 │ GnuPG: GnuPG: Information disclosure and potential arbitrary │
│                    │                │          │              │                   │                    │ code execution via out-of-bounds write...                    │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-68973                   │
├────────────────────┼────────────────┤          │              ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libc-bin           │ CVE-2024-2961  │          │              │ 2.36-9+deb12u4    │ 2.36-9+deb12u6     │ glibc: Out of bounds write in iconv may lead to remote       │
│                    │                │          │              │                   │                    │ code...                                                      │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-2961                    │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-33599 │          │              │                   │ 2.36-9+deb12u7     │ glibc: stack-based buffer overflow in netgroup cache         │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-33599                   │
├────────────────────┼────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│ libc6              │ CVE-2024-2961  │          │              │                   │ 2.36-9+deb12u6     │ glibc: Out of bounds write in iconv may lead to remote       │
│                    │                │          │              │                   │                    │ code...                                                      │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-2961                    │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-33599 │          │              │                   │ 2.36-9+deb12u7     │ glibc: stack-based buffer overflow in netgroup cache         │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-33599                   │
├────────────────────┼────────────────┤          │              ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libcap2            │ CVE-2026-4878  │          │              │ 1:2.66-4          │ 1:2.66-4+deb12u3   │ libcap: libcap: Privilege escalation via TOCTOU race         │
│                    │                │          │              │                   │                    │ condition in cap_set_file()                                  │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-4878                    │
├────────────────────┼────────────────┼──────────┤              ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libexpat1          │ CVE-2024-45491 │ CRITICAL │              │ 2.5.0-1           │ 2.5.0-1+deb12u1    │ libexpat: Integer Overflow or Wraparound                     │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45491                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-45492 │          │              │                   │                    │ libexpat: integer overflow                                   │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45492                   │
│                    ├────────────────┼──────────┤              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2023-52425 │ HIGH     │              │                   │ 2.5.0-1+deb12u2    │ expat: parsing large tokens can trigger a denial of service  │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-52425                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-45490 │          │              │                   │ 2.5.0-1+deb12u1    │ libexpat: Negative Length Parsing Vulnerability in libexpat  │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-45490                   │
│                    ├────────────────┤          ├──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2025-59375 │          │ will_not_fix │                   │                    │ firefox: thunderbird: expat: libexpat in Expat allows        │
│                    │                │          │              │                   │                    │ attackers to trigger large dynamic...                        │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-59375                   │
│                    ├────────────────┤          ├──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-25210 │          │ affected     │                   │                    │ libexpat: libexpat: Information disclosure and data          │
│                    │                │          │              │                   │                    │ integrity issues due to integer overflow...                  │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-25210                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-45186 │          │              │                   │                    │ libexpat: denial of service via crafted XML input            │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-45186                   │
├────────────────────┼────────────────┼──────────┼──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libgnutls30        │ CVE-2026-33845 │ CRITICAL │ fixed        │ 3.7.9-2+deb12u1   │ 3.7.9-2+deb12u7    │ gnutls: GnuTLS: Denial of Service via DTLS zero-length       │
│                    │                │          │              │                   │                    │ fragment                                                     │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-33845                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-42010 │          │              │                   │                    │ gnutls: gnutls: Authentication Bypass via NUL Character in   │
│                    │                │          │              │                   │                    │ Username                                                     │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-42010                   │
│                    ├────────────────┼──────────┤              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-0553  │ HIGH     │              │                   │ 3.7.9-2+deb12u2    │ gnutls: incomplete fix for CVE-2023-5981                     │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-0553                    │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-0567  │          │              │                   │                    │ gnutls: rejects certificate chain with distributed trust     │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-0567                    │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2025-32988 │          │              │                   │ 3.7.9-2+deb12u5    │ gnutls: Vulnerability in GnuTLS otherName SAN export         │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-32988                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2025-32990 │          │              │                   │                    │ gnutls: Vulnerability in GnuTLS certtool template parsing    │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-32990                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-33846 │          │              │                   │ 3.7.9-2+deb12u7    │ gnutls: GnuTLS: Denial of Service via heap buffer overflow   │
│                    │                │          │              │                   │                    │ in DTLS handshake...                                         │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-33846                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-3833  │          │              │                   │                    │ gnutls: GnuTLS: Policy bypass due to case-sensitive          │
│                    │                │          │              │                   │                    │ nameConstraints comparison                                   │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-3833                    │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-42009 │          │              │                   │                    │ gnutls: gnutls: Denial of Service via DTLS packet reordering │
│                    │                │          │              │                   │                    │ vulnerability                                                │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-42009                   │
├────────────────────┼────────────────┼──────────┤              ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libgssapi-krb5-2   │ CVE-2024-37371 │ CRITICAL │              │ 1.20.1-2+deb12u1  │ 1.20.1-2+deb12u2   │ krb5: GSS message token handling                             │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37371                   │
│                    ├────────────────┼──────────┤              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-37370 │ HIGH     │              │                   │                    │ krb5: GSS message token handling                             │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37370                   │
├────────────────────┼────────────────┼──────────┤              │                   │                    ├──────────────────────────────────────────────────────────────┤
│ libk5crypto3       │ CVE-2024-37371 │ CRITICAL │              │                   │                    │ krb5: GSS message token handling                             │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37371                   │
│                    ├────────────────┼──────────┤              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-37370 │ HIGH     │              │                   │                    │ krb5: GSS message token handling                             │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37370                   │
├────────────────────┼────────────────┼──────────┤              │                   │                    ├──────────────────────────────────────────────────────────────┤
│ libkrb5-3          │ CVE-2024-37371 │ CRITICAL │              │                   │                    │ krb5: GSS message token handling                             │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37371                   │
│                    ├────────────────┼──────────┤              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-37370 │ HIGH     │              │                   │                    │ krb5: GSS message token handling                             │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37370                   │
├────────────────────┼────────────────┼──────────┤              │                   │                    ├──────────────────────────────────────────────────────────────┤
│ libkrb5support0    │ CVE-2024-37371 │ CRITICAL │              │                   │                    │ krb5: GSS message token handling                             │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37371                   │
│                    ├────────────────┼──────────┤              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-37370 │ HIGH     │              │                   │                    │ krb5: GSS message token handling                             │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-37370                   │
├────────────────────┼────────────────┤          │              ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ liblzma5           │ CVE-2025-31115 │          │              │ 5.4.1-0.2         │ 5.4.1-1            │ xz: XZ has a heap-use-after-free bug in threaded .xz decoder │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-31115                   │
├────────────────────┼────────────────┤          ├──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libncursesw6       │ CVE-2025-69720 │          │ affected     │ 6.4-4             │                    │ ncurses: ncurses: Buffer overflow vulnerability may lead to  │
│                    │                │          │              │                   │                    │ arbitrary code execution.                                    │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-69720                   │
├────────────────────┼────────────────┤          ├──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libpam-modules     │ CVE-2025-6020  │          │ fixed        │ 1.5.2-6+deb12u1   │ 1.5.2-6+deb12u2    │ linux-pam: Linux-pam directory Traversal                     │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-6020                    │
├────────────────────┤                │          │              │                   │                    │                                                              │
│ libpam-modules-bin │                │          │              │                   │                    │                                                              │
│                    │                │          │              │                   │                    │                                                              │
├────────────────────┤                │          │              │                   │                    │                                                              │
│ libpam-runtime     │                │          │              │                   │                    │                                                              │
│                    │                │          │              │                   │                    │                                                              │
├────────────────────┤                │          │              │                   │                    │                                                              │
│ libpam0g           │                │          │              │                   │                    │                                                              │
│                    │                │          │              │                   │                    │                                                              │
├────────────────────┼────────────────┼──────────┤              ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libsqlite3-0       │ CVE-2025-6965  │ CRITICAL │              │ 3.40.1-2          │ 3.40.1-2+deb12u2   │ sqlite: Integer Truncation in SQLite                         │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-6965                    │
│                    ├────────────────┤          ├──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2025-7458  │          │ affected     │                   │                    │ sqlite: SQLite integer overflow                              │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-7458                    │
│                    ├────────────────┼──────────┼──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2023-7104  │ HIGH     │ fixed        │                   │ 3.40.1-2+deb12u1   │ sqlite: heap-buffer-overflow at sessionfuzz                  │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-7104                    │
│                    ├────────────────┤          ├──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-11822 │          │ fix_deferred │                   │                    │ SQLite before 3.53.2 contains memory corruption              │
│                    │                │          │              │                   │                    │ vulnerabilities in the ...                                   │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-11822                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-11824 │          │              │                   │                    │ SQLite before 3.53.2 contains a heap-based buffer overflow   │
│                    │                │          │              │                   │                    │ vulnerabili ...                                              │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-11824                   │
├────────────────────┼────────────────┼──────────┼──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libssl3            │ CVE-2026-31789 │ CRITICAL │ fixed        │ 3.0.11-1~deb12u2  │ 3.0.19-1~deb12u2   │ openssl: OpenSSL: Heap buffer overflow on 32-bit systems     │
│                    │                │          │              │                   │                    │ from large X.509 certificate...                              │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-31789                   │
│                    ├────────────────┼──────────┤              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-6119  │ HIGH     │              │                   │ 3.0.14-1~deb12u2   │ openssl: Possible denial of service in X.509 name checks     │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-6119                    │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2025-15467 │          │              │                   │ 3.0.18-1~deb12u2   │ openssl: OpenSSL: Remote code execution or Denial of Service │
│                    │                │          │              │                   │                    │ via oversized Initialization...                              │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-15467                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2025-69421 │          │              │                   │                    │ openssl: OpenSSL: Denial of Service via malformed PKCS#12    │
│                    │                │          │              │                   │                    │ file processing                                              │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-69421                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-28387 │          │              │                   │ 3.0.19-1~deb12u2   │ openssl: OpenSSL: Arbitrary code execution due to            │
│                    │                │          │              │                   │                    │ use-after-free in DANE TLSA authentication...                │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-28387                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-28388 │          │              │                   │                    │ openssl: OpenSSL: Denial of Service due to NULL pointer      │
│                    │                │          │              │                   │                    │ dereference in delta...                                      │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-28388                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-28389 │          │              │                   │                    │ openssl: OpenSSL: Denial of Service vulnerability in CMS     │
│                    │                │          │              │                   │                    │ processing                                                   │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-28389                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-28390 │          │              │                   │                    │ openssl: OpenSSL: Denial of Service due to NULL pointer      │
│                    │                │          │              │                   │                    │ dereference in CMS...                                        │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-28390                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-45447 │          │              │                   │ 3.0.20-1~deb12u2   │ openssl: Heap Use-After-Free in OpenSSL PKCS7_verify()       │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-45447                   │
├────────────────────┼────────────────┤          │              ├───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libsystemd0        │ CVE-2023-50387 │          │              │ 252.19-1~deb12u1  │ 252.23-1~deb12u1   │ bind9: KeyTrap - Extreme CPU consumption in DNSSEC validator │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-50387                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2023-50868 │          │              │                   │                    │ bind9: Preparing an NSEC3 closest encloser proof can exhaust │
│                    │                │          │              │                   │                    │ CPU resources                                                │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-50868                   │
├────────────────────┼────────────────┤          ├──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libtinfo6          │ CVE-2025-69720 │          │ affected     │ 6.4-4             │                    │ ncurses: ncurses: Buffer overflow vulnerability may lead to  │
│                    │                │          │              │                   │                    │ arbitrary code execution.                                    │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-69720                   │
├────────────────────┼────────────────┤          ├──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ libudev1           │ CVE-2023-50387 │          │ fixed        │ 252.19-1~deb12u1  │ 252.23-1~deb12u1   │ bind9: KeyTrap - Extreme CPU consumption in DNSSEC validator │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-50387                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2023-50868 │          │              │                   │                    │ bind9: Preparing an NSEC3 closest encloser proof can exhaust │
│                    │                │          │              │                   │                    │ CPU resources                                                │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-50868                   │
├────────────────────┼────────────────┤          ├──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ ncurses-base       │ CVE-2025-69720 │          │ affected     │ 6.4-4             │                    │ ncurses: ncurses: Buffer overflow vulnerability may lead to  │
│                    │                │          │              │                   │                    │ arbitrary code execution.                                    │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-69720                   │
├────────────────────┤                │          │              │                   ├────────────────────┤                                                              │
│ ncurses-bin        │                │          │              │                   │                    │                                                              │
│                    │                │          │              │                   │                    │                                                              │
│                    │                │          │              │                   │                    │                                                              │
├────────────────────┼────────────────┼──────────┼──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ openssl            │ CVE-2026-31789 │ CRITICAL │ fixed        │ 3.0.11-1~deb12u2  │ 3.0.19-1~deb12u2   │ openssl: OpenSSL: Heap buffer overflow on 32-bit systems     │
│                    │                │          │              │                   │                    │ from large X.509 certificate...                              │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-31789                   │
│                    ├────────────────┼──────────┤              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-6119  │ HIGH     │              │                   │ 3.0.14-1~deb12u2   │ openssl: Possible denial of service in X.509 name checks     │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-6119                    │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2025-15467 │          │              │                   │ 3.0.18-1~deb12u2   │ openssl: OpenSSL: Remote code execution or Denial of Service │
│                    │                │          │              │                   │                    │ via oversized Initialization...                              │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-15467                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2025-69421 │          │              │                   │                    │ openssl: OpenSSL: Denial of Service via malformed PKCS#12    │
│                    │                │          │              │                   │                    │ file processing                                              │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2025-69421                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-28387 │          │              │                   │ 3.0.19-1~deb12u2   │ openssl: OpenSSL: Arbitrary code execution due to            │
│                    │                │          │              │                   │                    │ use-after-free in DANE TLSA authentication...                │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-28387                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-28388 │          │              │                   │                    │ openssl: OpenSSL: Denial of Service due to NULL pointer      │
│                    │                │          │              │                   │                    │ dereference in delta...                                      │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-28388                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-28389 │          │              │                   │                    │ openssl: OpenSSL: Denial of Service vulnerability in CMS     │
│                    │                │          │              │                   │                    │ processing                                                   │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-28389                   │
│                    ├────────────────┤          │              │                   │                    ├──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-28390 │          │              │                   │                    │ openssl: OpenSSL: Denial of Service due to NULL pointer      │
│                    │                │          │              │                   │                    │ dereference in CMS...                                        │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-28390                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-45447 │          │              │                   │ 3.0.20-1~deb12u2   │ openssl: Heap Use-After-Free in OpenSSL PKCS7_verify()       │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-45447                   │
├────────────────────┼────────────────┼──────────┼──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ perl-base          │ CVE-2026-42496 │ CRITICAL │ fix_deferred │ 5.36.0-7+deb12u1  │                    │ perl-archive-tar: perl-archive-tar: Path traversal via       │
│                    │                │          │              │                   │                    │ crafted symlinks allows arbitrary file access                │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-42496                   │
│                    ├────────────────┤          ├──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-8376  │          │ affected     │                   │                    │ Perl versions through 5.43.10 have a heap buffer overflow    │
│                    │                │          │              │                   │                    │ when compili ......                                          │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-8376                    │
│                    ├────────────────┼──────────┼──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2023-31484 │ HIGH     │ fixed        │                   │ 5.36.0-7+deb12u3   │ perl: CPAN.pm does not verify TLS certificates when          │
│                    │                │          │              │                   │                    │ downloading distributions over HTTPS...                      │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-31484                   │
│                    ├────────────────┤          │              │                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2024-56406 │          │              │                   │ 5.36.0-7+deb12u2   │ perl: Perl 5.34, 5.36, 5.38 and 5.40 are vulnerable to a     │
│                    │                │          │              │                   │                    │ heap...                                                      │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2024-56406                   │
│                    ├────────────────┤          ├──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-42497 │          │ fix_deferred │                   │                    │ perl-Archive-Tar: perl-Archive-Tar: Arbitrary file           │
│                    │                │          │              │                   │                    │ modification via crafted hardlinks during archive extraction │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-42497                   │
│                    ├────────────────┤          ├──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-48962 │          │ affected     │                   │                    │ perl-IO-Compress: perl-IO-Compress: Arbitrary code execution │
│                    │                │          │              │                   │                    │ via attacker-controlled output glob                          │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-48962                   │
│                    ├────────────────┤          ├──────────────┤                   ├────────────────────┼──────────────────────────────────────────────────────────────┤
│                    │ CVE-2026-9538  │          │ fix_deferred │                   │                    │ Archive::Tar versions before 3.10 for Perl allow memory      │
│                    │                │          │              │                   │                    │ exhaustion via ...                                           │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2026-9538                    │
├────────────────────┼────────────────┼──────────┼──────────────┼───────────────────┼────────────────────┼──────────────────────────────────────────────────────────────┤
│ zlib1g             │ CVE-2023-45853 │ CRITICAL │ will_not_fix │ 1:1.2.13.dfsg-1   │                    │ zlib: integer overflow and resultant heap-based buffer       │
│                    │                │          │              │                   │                    │ overflow in zipOpenNewFileInZip4_6                           │
│                    │                │          │              │                   │                    │ https://avd.aquasec.com/nvd/cve-2023-45853                   │
└────────────────────┴────────────────┴──────────┴──────────────┴───────────────────┴────────────────────┴──────────────────────────────────────────────────────────────┘

Python (python-pkg)
===================
Total: 7 (HIGH: 7, CRITICAL: 0)

┌───────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────────────┐
│        Library        │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                            │
├───────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ setuptools (METADATA) │ CVE-2024-6345  │ HIGH     │ fixed  │ 69.0.3            │ 70.0.0        │ pypa/setuptools: Remote code execution via download         │
│                       │                │          │        │                   │               │ functions in the package_index module in...                 │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6345                   │
│                       ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                       │ CVE-2025-47273 │          │        │                   │ 78.1.1        │ setuptools: Path Traversal Vulnerability in setuptools      │
│                       │                │          │        │                   │               │ PackageIndex                                                │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2025-47273                  │
├───────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ urllib3 (METADATA)    │ CVE-2025-66418 │          │        │ 2.2.2             │ 2.6.0         │ urllib3: urllib3: Unbounded decompression chain leads to    │
│                       │                │          │        │                   │               │ resource exhaustion                                         │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2025-66418                  │
│                       ├────────────────┤          │        │                   │               ├─────────────────────────────────────────────────────────────┤
│                       │ CVE-2025-66471 │          │        │                   │               │ urllib3: urllib3 Streaming API improperly handles highly    │
│                       │                │          │        │                   │               │ compressed data                                             │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2025-66471                  │
│                       ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                       │ CVE-2026-21441 │          │        │                   │ 2.6.3         │ urllib3: urllib3 vulnerable to decompression-bomb safeguard │
│                       │                │          │        │                   │               │ bypass when following HTTP redirects (streaming...          │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2026-21441                  │
│                       ├────────────────┤          │        │                   ├───────────────┼─────────────────────────────────────────────────────────────┤
│                       │ CVE-2026-44431 │          │        │                   │ 2.7.0         │ urllib3: urllib3: Information disclosure via cross-origin   │
│                       │                │          │        │                   │               │ redirects forwarding sensitive headers                      │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2026-44431                  │
├───────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼─────────────────────────────────────────────────────────────┤
│ wheel (METADATA)      │ CVE-2026-24049 │          │        │ 0.42.0            │ 0.46.2        │ wheel: wheel: Privilege Escalation or Arbitrary Code        │
│                       │                │          │        │                   │               │ Execution via malicious wheel file...                       │
│                       │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2026-24049                  │
└───────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────────────┘

## kube-bench 失败项

[INFO] 1 Control Plane Security Configuration
[INFO] 1.1 Control Plane Node Configuration Files
[FAIL] 1.1.1 Ensure that the API server pod specification file permissions are set to 600 or more restrictive (Automated)
[FAIL] 1.1.2 Ensure that the API server pod specification file ownership is set to root:root (Automated)
[FAIL] 1.1.3 Ensure that the controller manager pod specification file permissions are set to 600 or more restrictive (Automated)
[FAIL] 1.1.4 Ensure that the controller manager pod specification file ownership is set to root:root (Automated)
[FAIL] 1.1.5 Ensure that the scheduler pod specification file permissions are set to 600 or more restrictive (Automated)
[FAIL] 1.1.6 Ensure that the scheduler pod specification file ownership is set to root:root (Automated)
[FAIL] 1.1.7 Ensure that the etcd pod specification file permissions are set to 600 or more restrictive (Automated)
[FAIL] 1.1.8 Ensure that the etcd pod specification file ownership is set to root:root (Automated)
[WARN] 1.1.9 Ensure that the Container Network Interface file permissions are set to 600 or more restrictive (Manual)
[WARN] 1.1.10 Ensure that the Container Network Interface file ownership is set to root:root (Manual)
[FAIL] 1.1.11 Ensure that the etcd data directory permissions are set to 700 or more restrictive (Automated)
[FAIL] 1.1.12 Ensure that the etcd data directory ownership is set to etcd:etcd (Automated)
[FAIL] 1.1.13 Ensure that the admin.conf file permissions are set to 600 or more restrictive (Automated)
[FAIL] 1.1.14 Ensure that the admin.conf file ownership is set to root:root (Automated)
[FAIL] 1.1.15 Ensure that the scheduler.conf file permissions are set to 600 or more restrictive (Automated)
[FAIL] 1.1.16 Ensure that the scheduler.conf file ownership is set to root:root (Automated)
[FAIL] 1.1.17 Ensure that the controller-manager.conf file permissions are set to 600 or more restrictive (Automated)
[FAIL] 1.1.18 Ensure that the controller-manager.conf file ownership is set to root:root (Automated)
[FAIL] 1.1.19 Ensure that the Kubernetes PKI directory and file ownership is set to root:root (Automated)
[WARN] 1.1.20 Ensure that the Kubernetes PKI certificate file permissions are set to 600 or more restrictive (Manual)
[WARN] 1.1.21 Ensure that the Kubernetes PKI key file permissions are set to 600 (Manual)
[INFO] 1.2 API Server
[WARN] 1.2.1 Ensure that the --anonymous-auth argument is set to false (Manual)
[FAIL] 1.2.2 Ensure that the --token-auth-file parameter is not set (Automated)
[FAIL] 1.2.3 Ensure that the --DenyServiceExternalIPs is not set (Automated)
[FAIL] 1.2.4 Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate (Automated)
[FAIL] 1.2.5 Ensure that the --kubelet-certificate-authority argument is set as appropriate (Automated)
[FAIL] 1.2.6 Ensure that the --authorization-mode argument is not set to AlwaysAllow (Automated)
[FAIL] 1.2.7 Ensure that the --authorization-mode argument includes Node (Automated)
[FAIL] 1.2.8 Ensure that the --authorization-mode argument includes RBAC (Automated)
[WARN] 1.2.9 Ensure that the admission control plugin EventRateLimit is set (Manual)
[FAIL] 1.2.10 Ensure that the admission control plugin AlwaysAdmit is not set (Automated)
[WARN] 1.2.11 Ensure that the admission control plugin AlwaysPullImages is set (Manual)
[WARN] 1.2.12 Ensure that the admission control plugin SecurityContextDeny is set if PodSecurityPolicy is not used (Manual)
[FAIL] 1.2.13 Ensure that the admission control plugin ServiceAccount is set (Automated)
[FAIL] 1.2.14 Ensure that the admission control plugin NamespaceLifecycle is set (Automated)
[FAIL] 1.2.15 Ensure that the admission control plugin NodeRestriction is set (Automated)
[FAIL] 1.2.16 Ensure that the --secure-port argument is not set to 0 (Automated)
[FAIL] 1.2.17 Ensure that the --profiling argument is set to false (Automated)
[FAIL] 1.2.18 Ensure that the --audit-log-path argument is set (Automated)
[FAIL] 1.2.19 Ensure that the --audit-log-maxage argument is set to 30 or as appropriate (Automated)
[FAIL] 1.2.20 Ensure that the --audit-log-maxbackup argument is set to 10 or as appropriate (Automated)
[FAIL] 1.2.21 Ensure that the --audit-log-maxsize argument is set to 100 or as appropriate (Automated)
[WARN] 1.2.22 Ensure that the --request-timeout argument is set as appropriate (Manual)
[FAIL] 1.2.23 Ensure that the --service-account-lookup argument is set to true (Automated)
[FAIL] 1.2.24 Ensure that the --service-account-key-file argument is set as appropriate (Automated)
[FAIL] 1.2.25 Ensure that the --etcd-certfile and --etcd-keyfile arguments are set as appropriate (Automated)
[FAIL] 1.2.26 Ensure that the --tls-cert-file and --tls-private-key-file arguments are set as appropriate (Automated)
[FAIL] 1.2.27 Ensure that the --client-ca-file argument is set as appropriate (Automated)
[FAIL] 1.2.28 Ensure that the --etcd-cafile argument is set as appropriate (Automated)
[WARN] 1.2.29 Ensure that the --encryption-provider-config argument is set as appropriate (Manual)
[WARN] 1.2.30 Ensure that encryption providers are appropriately configured (Manual)
--
[INFO] 1.3 Controller Manager
[WARN] 1.3.1 Ensure that the --terminated-pod-gc-threshold argument is set as appropriate (Manual)
[FAIL] 1.3.2 Ensure that the --profiling argument is set to false (Automated)
[FAIL] 1.3.3 Ensure that the --use-service-account-credentials argument is set to true (Automated)
[FAIL] 1.3.4 Ensure that the --service-account-private-key-file argument is set as appropriate (Automated)
[FAIL] 1.3.5 Ensure that the --root-ca-file argument is set as appropriate (Automated)
[FAIL] 1.3.6 Ensure that the RotateKubeletServerCertificate argument is set to true (Automated)
[FAIL] 1.3.7 Ensure that the --bind-address argument is set to 127.0.0.1 (Automated)
[INFO] 1.4 Scheduler
[FAIL] 1.4.1 Ensure that the --profiling argument is set to false (Automated)
[FAIL] 1.4.2 Ensure that the --bind-address argument is set to 127.0.0.1 (Automated)

== Remediations master ==
--
== Summary master ==
0 checks PASS
48 checks FAIL
13 checks WARN
0 checks INFO
--
== Summary total ==
0 checks PASS
48 checks FAIL
13 checks WARN
0 checks INFO
