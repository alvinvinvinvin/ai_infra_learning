
vLLM 核心概念
PagedAttention
KV cache 分页管理，类似虚拟内存

减少内存碎片，提升吞吐量

关键参数
--gpu-memory-utilization: GPU 显存使用比例

--enable-prefix-caching: 启用前缀缓存

--max-num-seqs: 最大并发序列数
