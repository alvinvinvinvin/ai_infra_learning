# Day 18: Istio Advanced - Verification and Validation

## Date: 2026-06-24

## Learning Objectives
- [x] Verify fault injection (HTTP 500) with direct pod testing
- [x] Verify traffic mirroring with Envoy access logs
- [x] Enable and inspect Istio access logs
- [x] Understand practical use cases for fault injection and traffic mirroring

## Summary

Today we focused on **validating** Istio features:

1. **Fault Injection Verification**
   - Applied fault injection with `gateways: - mesh` (key!)
   - Tested directly with `curl http://reviews:9080/reviews/0`
   - Confirmed HTTP 500 response

2. **Traffic Mirroring Verification**
   - Enabled Envoy access logs via ConfigMap
   - Observed mirror traffic in v2 sidecar logs
   - Confirmed: v3 handles 100% of real traffic, v2 receives mirrored copy

## Key Takeaway

`gateways: - mesh` is required for sidecar-to-sidecar traffic rules.

Without it, rules only apply to Ingress Gateway.

## Notes

- See `notes/istio-fault-injection-mirroring.md` for production use cases
- Practical verification is essential for understanding Istio behavior
