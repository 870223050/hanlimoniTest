# hanliMoni（寒璃模拟）

> 觅长生 + LLM 多事件分支小说生成游戏 | Godot 4.4

基于 LLM（大语言模型）驱动的深度修仙模拟游戏。玩家在开放世界中选择灵根、修炼功法、探索秘境、参与宗门事务，所有事件均由 LLM 动态生成，提供无尽的分支叙事体验。

---

## 技术栈

| 类别 | 技术 |
|------|------|
| 引擎 | Godot 4.4（GL Compatibility） |
| 语言 | GDScript（中文注释） |
| LLM 后端 | Mock / Ollama / OpenAI / DeepSeek |
| 数据格式 | JSON（`to_dict`/`from_dict` 统一序列化） |
| 编码 | UTF-8 / LF |

---

## 目录结构

```
hanlimoni/
├── core/
│   ├── global/              # AutoLoad 全局单例（5 个）
│   │   ├── game_state.gd    # 玩家状态、时间、地点管理
│   │   ├── event_manager.gd # 事件编排与 LLM 调用
│   │   ├── llm_service.gd   # LLM 后端抽象层
│   │   ├── battle_manager.gd# 回合制战斗引擎
│   │   └── ui_manager.gd    # UI 面板栈管理
│   └── script/
│       ├── models/          # 数据模型（6 个）
│       │   ├── player.gd
│       │   ├── attributes.gd
│       │   ├── combat_unit.gd
│       │   ├── cultivation.gd
│       │   ├── item.gd
│       │   └── technique.gd
│       └── systems/         # 系统存根（9 个）
│           ├── battle_system.gd
│           ├── cultivation_system.gd
│           ├── time_system.gd
│           ├── save_system.gd
│           ├── data_manager.gd
│           ├── faction_system.gd
│           ├── recipe_system.gd
│           ├── auction_system.gd
│           └── glossary_system.gd
├── ui/                      # UI 脚本（20 个）
├── test/                    # 测试场景
│   ├── test.gd              # 探索→事件流集成测试
│   └── test.tscn            # 测试 UI（ExploreButton + EventListContainer）
├── scenes/                  # TSCN 场景（20 个）
│   ├── 01main_menu.tscn     # 主菜单
│   ├── 02char_create.tscn   # 角色创建（4 步向导）
│   ├── 03game_screen.tscn   # 主游戏 HUD
│   ├── 17game_over.tscn     # 结局画面
│   ├── battle/
│   │   └── 16battle_screen.tscn  # 战斗界面
│   └── panels/              # 弹窗面板（15 个）
├── data/                    # 配置数据（6 个 JSON）
└── project.godot
```

---

## 架构概览

### AutoLoad 全局单例

| 名称 | 功能 |
|------|------|
| `GameState` | 玩家属性、时间历法、地点、关系、事件标记 |
| `EventManager` | 事件触发、LLM 上下文构建、选择处理 |
| `LLMService` | 三后端（Mock/Ollama/OpenAI）统一接口 |
| `BattleManager` | 回合制战斗、五行伤害计算、AI 决策 |
| `UIManager` | 模态弹窗栈，Esc 关闭顶层面板 |

### 场景列表（20 个 TSCN）

**全屏场景：**
- `01main_menu` — 开始/读档/设置/图鉴/退出
- `02char_create` — 四步角色创建（道号→灵根→属性→确认）
- `03game_screen` — 主 HUD（状态栏 + 事件区 + 快捷栏）
- `16battle_screen` — 回合制战斗（行动条 + 战斗日志）
- `17game_over` — 结局总结

**弹窗面板：**
- `04character_panel` — 人物（基础/境界/装备/功法四标签）
- `05skill_panel` — 功法列表与修炼/遗忘
- `06inventory_panel` — 背包与分类过滤
- `07map_panel` — 世界/区域地图
- `08faction_panel` — 宗门（任务/商店/藏经阁/设施）
- `09social_panel` — NPC 社交（交谈/论道/切磋/赠礼/交易）
- `10quest_panel` — 任务跟踪
- `11alchemy_panel` — 炼丹
- `12crafting_panel` — 炼器
- `13breakthrough_panel` — 突破与心魔考验
- `14cave_panel` — 洞府设施
- `15auction_panel` — 拍卖行
- `18setting` — 设置（音量/文本速度/全屏/LLM）
- `19glossary` — 图鉴百科
- `20save_load` — 存档管理

### UI 设计规范

- 所有 TSCN 使用**显式定位**（`layout_mode = 0`），不使用 Container 节点
- 按钮使用 `TextureButton`，图片使用 `TextureRect`
- 每个 `TextureButton` 下均有 `Label` 子节点显示按钮文字
- 弹窗使用 `CanvasLayer` + `ColorRect` 遮罩
- 脚本使用中文注释，不使用 `:=` 语法

---

## 数据配置

| 文件 | 内容 |
|------|------|
| `game_config.json` | 游戏基础参数（初始属性/寿命/境界阈值） |
| `events.json` | 事件模板 |
| `items.json` | 物品数据 |
| `techniques.json` | 功法数据 |
| `locations.json` | 地点数据 |
| `llm_config.json` | LLM 后端配置（API Key/模型/温度） |

---

## 运行方式

1. 安装 [Godot 4.4](https://godotengine.org/)
2. 克隆仓库：`git clone https://github.com/870223050/hanlimoniTest.git`
3. 用 Godot 打开 `project.godot`
4. 按 F5 运行（默认 Mock 后端，无需配置 LLM）

### LlmService 事件流

```
ExploreButton (点击)
  → EventManager.trigger_exploration()
    → LLMService.request_event(context, callback)
      → [Mock/Ollama/OpenAI/DeepSeek] 返回 JSON
    → event_display 信号 (narration + choices)
  → UI 解析生成选择按钮
    → 玩家选择
  → EventManager.execute_choice(choice_id)
    → 数据驱动 effects 链执行
  → event_result 信号 (结果叙事)
```

### LLM 后端配置

编辑 `core/global/llm_service.gd` 修改 `provider` 和对应配置：

```gdscript
# Mock 模式（默认，无需网络）
provider = Provider.MOCK

# Ollama 本地模式
provider = Provider.OLLAMA
ollama_url = "http://localhost:11434"
ollama_model = "qwen2.5:7b"

# OpenAI 兼容模式（DeepSeek 等）
provider = Provider.OPENAI
openai_url = "https://api.deepseek.com"  # 仅 base URL
openai_key = "sk-your-key"
openai_model = "deepseek-chat"
timeout = 120.0  # LLM 请求超时（秒）
```

> **注意**: `openai_url` 只需填写 base URL，代码会自动追加 `/chat/completions`。HTTP 请求超时默认 120 秒，可在 `llm_service.gd` 中调整。
