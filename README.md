# 车辆信号规范 / Vehicle Signal Specification（标准主干 + 扩展层）

🔥 面向智能汽车软件定义场景的统一信号语义目录。
🚀 以 `VSS` 标准主干为基础，通过扩展层承载企业自定义信号与映射规则。
⭐ 覆盖信号建模、版本治理、工件生成、兼容校验与发布流程，支持从车端协议到云端遥测的数据语义对齐。

[![License](https://img.shields.io/badge/License-MPL%202.0-blue.svg)](https://opensource.org/license/MPL-2.0)
[![Build](https://github.com/however-yir/vehicle_signal_specification/actions/workflows/buildcheck.yml/badge.svg)](https://github.com/however-yir/vehicle_signal_specification/actions/workflows/buildcheck.yml?query=branch%3Amaster)
[![Docs](https://img.shields.io/badge/docs-GitHub%20Pages-0A7EFA)](https://however-yir.github.io/vehicle_signal_specification/latest/)
[![Status](https://img.shields.io/badge/status-active-2563EB)](https://github.com/however-yir/vehicle_signal_specification)

> Status: `active`
>
> Upstream: `COVESA/vehicle_signal_specification`

> **非官方声明（Non-Affiliation）**  
> 本仓库为社区维护的衍生/二次开发版本，与上游项目及其权利主体不存在官方关联、授权背书或从属关系。  
> **商标声明（Trademark Notice）**  
> 相关项目名称、Logo 与商标归其各自权利人所有。本仓库仅用于说明兼容/来源，不主张任何商标权利。
>
> Docs: `https://however-yir.github.io/vehicle_signal_specification/latest/`
>
> Attribution: upstream MPL-2.0 remains in `LICENSE`; fork boundary and redistribution notes are maintained in `LICENSE.HOWEVER` and `NOTICE.md`.
>
> Role: standards and signal-governance layer for the autonomous-driving portfolio

> **非官方声明（Non-Affiliation）**<br>
> 本仓库是基于 `COVESA/vehicle_signal_specification` 的社区维护衍生版，与上游项目、COVESA 及相关权利主体不存在官方关联、授权背书或从属关系。<br>
> **商标声明（Trademark Notice）**<br>
> `Vehicle Signal Specification`、`VSS` 及相关项目名称、Logo 与商标归其各自权利人所有；本仓库仅用于说明上游来源、兼容关系与扩展治理边界。

---

## 目录

- [1. 项目定位](#1-项目定位)
- [2. 标准主干与扩展层策略](#2-标准主干与扩展层策略)
- [3. 信号建模与命名规范](#3-信号建模与命名规范)
- [4. 版本策略与发布节奏](#4-版本策略与发布节奏)
- [5. 工件生成与工具链](#5-工件生成与工具链)
- [6. 校验与兼容测试](#6-校验与兼容测试)
- [7. 变更治理流程](#7-变更治理流程)
- [8. 映射层设计](#8-映射层设计)
- [9. 仓库结构](#9-仓库结构)
- [10. 快速开始](#10-快速开始)
- [11. 文档与站点发布](#11-文档与站点发布)
- [12. 合规与开源要求](#12-合规与开源要求)
- [13. 社区协作与上游同步](#13-社区协作与上游同步)
- [14. 信号评审模板（建议）](#14-信号评审模板建议)
- [15. 发布门禁清单（建议）](#15-发布门禁清单建议)
- [16. 常见问题](#16-常见问题)

---

## 1. 项目定位

`Vehicle Signal Specification (VSS)` 的核心目标，是为车辆数据建立跨协议、跨平台、跨域的一致语义。无论底层来自 CAN、UDS、SOME/IP，还是上云后的遥测字段，只要映射到统一信号目录，就能显著降低系统集成复杂度。

本仓库在保留标准主干结构的同时，强调“标准治理 + 企业扩展”并行：

1. 标准主干稳定：不轻易调整核心信号命名与层级，保持生态兼容。
2. 扩展层可控：企业新增信号放在扩展目录，避免对主干造成漂移。
3. 发布可追溯：每次变更都可生成差异报告并绑定版本语义。
4. 集成可落地：自动生成 JSON/CSV/IDL 等工件给平台、云端和应用侧使用。

适用对象：

- 车端基础软件团队（信号定义与网关适配）
- 云端数据平台团队（遥测、告警、分析）
- 座舱与应用团队（SDK 常量、权限控制、读写策略）
- 质量与架构团队（版本冻结、兼容回归、发布治理）

---

## 2. 标准主干与扩展层策略

### 2.1 双层结构

推荐将信号资产分为两层：

- 标准主干：`spec/` 下的标准目录（如 `Vehicle/`、`Powertrain/`、`Chassis/`）。
- 扩展层：`spec/extensions/` 下的企业或场景定制信号。

该策略的目标是把“行业共识”与“业务差异”解耦，既方便升级上游标准，也方便企业内部迭代。

### 2.2 主干保持稳定

- 不轻易修改标准核心信号名；
- 如确需变更，必须提供向后兼容策略与迁移说明；
- 通过差异清单长期跟踪与上游目录的偏离情况。

### 2.3 扩展层命名边界

- 新增企业信号统一使用前缀（例如 `MyCo.*`）；
- 禁止与标准主干信号重名；
- 扩展层应有明确 owner 与评审责任归属。

---

## 3. 信号建模与命名规范

为保证信号可用性与可治理性，建议在建模阶段同步维护以下元数据字段：

- `owner`：信号责任人或责任团队；
- `deprecated` 与 `replacement`：废弃标记与替代字段；
- `safety_level`：安全等级（例如 ASIL 相关）；
- `privacy_class`：隐私分类（PII/非 PII）；
- `access`：读写权限（RO/RW/受限写入）。

命名层面建议执行 lint 规则：

1. 名称具备领域语义且层级一致；
2. 单位与量纲可解释，范围校验可落地；
3. 扩展信号必须带企业前缀，避免后续回收成本。

---

## 4. 版本策略与发布节奏

建议采用 `主版本.次版本.补丁版本`（`MAJOR.MINOR.PATCH`）策略：

- 主版本：不兼容变更或大范围结构调整；
- 次版本：新增信号或向后兼容增强；
- 补丁版本：文档、注释、非语义修复。

发布治理建议：

- 发布前执行 schema 冻结窗口；
- 生成变更 diff 报告并同步 `SIGNAL_CHANGELOG.md`；
- 对外发布时附带版本化工件与兼容性说明。

---

## 5. 工件生成与工具链

仓库支持通过 `vss-tools` 将 `*.vspec` 转换为多种交付格式。典型输出包括：

- `JSON`：服务端与网关常用结构化输入；
- `CSV`：信号审阅、对照与导入导出；
- `IDL`（Franca / DDS 等）：中间件和接口契约场景。

常用入口：

- `Makefile`（如 `make csv`、`make all`）；
- `scripts/install_vss_tools.sh`（安装 vss-tools 依赖）。

在持续集成中建议将“规范校验 + 工件生成”作为统一流水线，确保提交后产物一致可复现。

### 5.1 工件建议矩阵

| 工件 | 典型使用方 | 典型用途 |
|---|---|---|
| `JSON` | 服务端/网关 | 运行时加载信号目录、校验路径合法性 |
| `CSV` | 架构/测试/运营 | 评审、差异比对、离线分析 |
| `Franca IDL` | 中间件团队 | 接口契约与跨组件联调 |
| `DDS IDL` | 实时通信团队 | 数据发布订阅模型对齐 |
| `YAML` | 工具链/脚本 | 配置驱动式处理与自动化生成 |

### 5.2 工件发布建议

为避免“规范版本”和“产物版本”错位，建议在每次发布中同时附带：

1. 规范版本号（例如 `vX.Y.Z`）；
2. 对应时间戳与 commit SHA；
3. 同版本导出的 JSON/CSV/IDL 工件；
4. 变更差异摘要和兼容性说明。

### 5.3 工件落点与消费方建议

| 资产 | 主要入口 | 建议发布落点 | 主要消费者 |
|---|---|---|---|
| 标准规范源文件 | `spec/` | Git tag 对应源码树 | 标准维护者 |
| 扩展层 overlay | `overlays/extensions/` | `build/extensions/<version>/` | 企业平台团队 |
| SDK 常量生成 | `scripts/generate_sdk_constants.py` | `generated/sdk/` | App / Backend / Tooling |
| 差异报告 | `scripts/generate_diff_report.sh` | `reports/diff/` | 架构评审、发布说明 |
| 站点文档 | `docs-gen/` | 静态站点或 Pages 工件 | 跨团队读者 |

---

## 6. 校验与兼容测试

### 6.1 基础校验

- `buildcheck.yml`：构建与导出链路校验；
- `pre-commit.yml`：格式与静态规则检查；
- `check-header.yml`：许可证头注释一致性检查。

### 6.2 兼容性校验建议

除基础 CI 外，建议补充以下回归检查：

1. 与 Kuksa 的兼容测试；
2. schema 版本兼容测试（新旧模型对比）；
3. 命名/单位/范围/权限 lint 检查；
4. 扩展层与主干冲突扫描。

兼容回归通过后再进入发布步骤，可显著降低字段变更对上下游系统的冲击。

### 6.3 本地校验建议命令

```bash
pre-commit install
make travis-targets
make all
```

当变更涉及扩展层信号时，建议额外执行一次主干/扩展冲突扫描，并把结果附在 PR 描述中。

---

## 7. 变更治理流程

推荐变更流程：

1. 提交信号变更提案（包含业务背景、影响范围、owner）；
2. 通过信号评审模板进行跨团队评审；
3. 生成自动化 diff 报告并更新变更日志；
4. 运行 CI 与兼容测试；
5. 进入 schema 冻结并发布版本工件。

该流程重点解决两个问题：

- 防止信号定义随意膨胀；
- 保证车端、云端、应用侧在同一版本语义下协作。

---

## 8. 映射层设计

### 8.1 车端协议映射

建议维护 CAN/UDS 到 VSS 的标准映射表，至少包含：

- 原始信号 ID/地址；
- 缩放规则、单位和有效范围；
- 映射后的 VSS 路径；
- 权限与更新周期信息。

### 8.2 云端遥测映射

为避免“车端字段名”和“云端指标名”长期分叉，建议建立云端遥测映射表，将数据仓库字段与 VSS 路径绑定。

### 8.3 应用侧 SDK 常量

建议从规范自动生成应用 SDK 常量定义，减少硬编码路径字符串，提升调用一致性与重构可维护性。

### 8.4 映射资产建议目录

可在项目中维护如下映射资产（命名仅示例）：

- `mapping/can_to_vss.csv`
- `mapping/uds_to_vss.csv`
- `mapping/can_uds_to_vss.csv`
- `mapping/cloud_telemetry_to_vss.csv`
- `artifacts/extensions/<version>/sdk/`（自动生成常量定义）

映射资产建议与版本号绑定，避免部署时“信号定义已升级但映射未同步”。

---

## 9. 仓库结构

```text
.
├── spec/                         # VSS 标准主干目录
│   └── extensions/               # 企业扩展层（MyCo 前缀）
├── overlays/                     # 上游 overlay 示例
├── docs-gen/                     # 文档站点生成内容
├── mapping/                      # CAN/UDS 与云端字段映射
├── governance/                   # 版本、冻结、上游同步等治理资产
├── scripts/                      # 校验、导出、报告、同步脚本
├── .github/workflows/            # CI 与发布流程
├── SIGNAL_CHANGELOG.md
├── UPSTREAM_DIFF.md
├── BUILD.md
├── RELEASE_PROCESS.md
└── README.md
```

---

## 10. 快速开始

### 10.1 获取源码

```bash
git clone https://github.com/however-yir/vehicle_signal_specification.git
cd vehicle_signal_specification
git submodule update --init
```

### 10.2 安装工具并验证

```bash
./scripts/bootstrap_vspec_toolchain.sh
make
```

如需避免本机直接安装工具链，可使用容器化导出：

```bash
./scripts/export_with_container.sh all
```

### 10.3 生成工件示例

```bash
make csv
./scripts/export_extension_artifacts.sh
```

扩展治理检查示例：

```bash
python3 scripts/lint_extension_metadata.py
python3 scripts/check_schema_compat.py --base origin/master --head HEAD
./scripts/check_core_signal_rename_guard.sh origin/master HEAD
./scripts/generate_diff_report.sh origin/master HEAD reports/schema-diff.md
```

更多构建说明请参考 `BUILD.md`，发布流程请参考 `RELEASE_PROCESS.md`，变更记录请参考 `SIGNAL_CHANGELOG.md`。

---

## 11. 文档与站点发布

- 最新文档站点：`https://however-yir.github.io/vehicle_signal_specification/latest/`；
- `docs-gen/` 目录用于维护文档源与主题；
- 版本化发布由 `.github/workflows/docs-versioned.yml` 执行：
  - `master` -> `gh-pages/latest/`
  - `v*` tag -> `gh-pages/versions/<tag>/`
- 建议在发布说明中同步维护“与上游差异清单”。

### 11.1 站点与文档入口建议

| 入口 | 仓库位置 | 用途 |
|---|---|---|
| 仓库入口说明 | `README.md` | 对外说明项目定位与治理边界 |
| 站点生成配置 | `docs-gen/config.toml` | 统一静态站点配置 |
| 站点内容源 | `docs-gen/content/` | 按主题拆分规范页面 |
| overlay 说明 | `overlays/README.md` | 解释扩展层如何组织 |
| 示例图片 | `pics/` | 展示规范重用与文档配图 |

---

## 12. 合规与开源要求

- 保留 `MPL-2.0` 协议文件与原有许可证头注释；
- fork 归属与分发边界说明见 `LICENSE.HOWEVER` 与 `NOTICE.md`；
- 对 MPL 覆盖文件的修改，在分发时需提供对应源码；
- 源码提供说明见 `MPL_SOURCE_OFFER.md`；
- 贡献时请遵循仓库的签名与提交规范（参见 `CONTRIBUTING.md`）。

---

## 13. 社区协作与上游同步

- 建议建立季度上游同步机制，控制分叉成本；
- 自动化入口：`.github/workflows/quarterly-upstream-sync.yml`；
- GitHub Topics 维护入口：`.github/workflows/update-github-topics.yml`；
- 建议维护公开的差异看板，持续跟踪标准演进；
- 社区讨论与例会信息可参考仓库 wiki。

通过持续的主干同步和扩展治理，可以在保持生态兼容的同时，稳定支撑企业自定义场景演进。

---

## 14. 信号评审模板（建议）

为提高跨团队评审效率，建议每个信号变更提案至少包含以下字段：

1. 变更类型：新增 / 修改 / 废弃；
2. 业务背景：为什么要变更，解决什么问题；
3. 影响范围：车端模块、云端任务、应用侧功能；
4. 数据规范：单位、量纲、范围、采样频率；
5. 权限与合规：读写权限、PII 分类、安全等级；
6. 兼容策略：旧字段迁移路径与替代字段；
7. owner 与验收人：责任清晰可追踪。

这套模板的目标是把“信号讨论”从命名争论前置到“业务价值 + 兼容风险 + 运维成本”。

---

## 15. 发布门禁清单（建议）

建议将以下项设为发布前必须通过的 Gate：

1. 结构化校验全部通过（build/pre-commit/header）；
2. schema 兼容测试通过（至少覆盖上一个稳定版本）；
3. Kuksa 兼容验证通过；
4. 变更 diff 报告与 `SIGNAL_CHANGELOG.md` 完整更新；
5. 文档站点版本页更新；
6. 与上游差异清单更新；
7. MPL 文件与头注释合规检查通过。

---

## 16. 常见问题

### Q1：为什么要坚持“主干 + 扩展层”？
因为这样可以同时获得生态兼容性和企业可定制性，避免把标准主干改成私有分支后难以回收。

### Q2：扩展信号是否可以不加前缀？
不建议。统一前缀（如 `MyCo.*`）可以显著降低命名冲突与后续治理成本。

### Q3：什么时候需要升主版本？
当出现不兼容变更，或需要大范围迁移字段路径时，应升主版本并提供迁移说明。

### Q4：如何避免信号“只改规范、不改映射”？
把映射资产纳入同一发布门禁，要求规范、映射、工件和变更日志同步提交。
