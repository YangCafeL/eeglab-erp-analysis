# 📦 data 目录说明

> ⚠️ **本目录下的 EEG 数据不进 Git 仓库**（已在 `.gitignore` 中排除）。

## 为什么不上传

| 文件 | 大小 | 原因 |
|---|---|---|
| `S1.fdt` | 72.0 MB | 单个超过 GitHub 建议体积 |
| `S2.fdt` | 71.0 MB | 同上 |
| `data.zip` | 106.7 MB | **超过 GitHub 单文件 100 MB 硬上限**，会被直接拒绝推送 |

GitHub 对超过 100 MB 的文件会拒绝推送；即使能推，仓库体积过大也会拖慢克隆。
如需在仓库中托管数据，建议使用 [Git LFS](https://git-lfs.com/) 或网盘链接。

## 目录结构

```text
data/
├── README.md      # 本文件（会提交到仓库）
├── raw/           # 原始数据（不提交）
│   ├── S1.set     # 被试 1 数据集描述 + 头信息（MATLAB .mat 格式）
│   ├── S1.fdt     # 被试 1 数据矩阵（float32 二进制）
│   ├── S2.set
│   ├── S2.fdt
│   └── data.zip   # 课程分发的原始压缩包
└── processed/     # 处理结果（不提交，由 pipeline_final.m 自动生成）
    ├── S1_ica.set / .fdt      # 含 ICA 权重，用于查看成分
    ├── S1_clean.set / .fdt    # 去伪迹后的最终数据
    ├── S2_ica.set / .fdt
    └── S2_clean.set / .fdt
```

## 数据规格

| 项目 | 被试 1 | 被试 2 |
|---|---|---|
| 通道数 | 32 | 32 |
| 采样率 | 500 Hz | 500 Hz |
| 每段点数 | 1500（−1 ~ 2 s） | 1500（−1 ~ 2 s） |
| 试次数 | 393 | 388 |
| 事件类型 | `S 31` `S 32` `S 33` `S 34` `S120` | 同左 |

事件与刺激的对应关系：

```text
1-parts → S 31    2-parts → S 32    3-parts → S 33    4-parts → S 34
```

## 如何获取

1. 从课程平台下载 `data.zip`，解压到 `data/raw/`；
2. 确认解压后目录形如 `data/raw/S1.set`、`data/raw/S1.fdt`（**不要多套一层文件夹**）；
3. 在 MATLAB 里运行 `code/matlab/run_all.m` 即可复现全部结果。
