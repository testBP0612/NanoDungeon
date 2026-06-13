# 奈米地下城 Nano Dungeon

> Pinball × Roguelite｜彈珠台 × 肉鴿地下城
> 一個用來展示「人類決策 × AI 執行」可控遊戲開發流水線的 Godot 4 Demo。

---

## 1. 專案介紹

奈米地下城是一款**彈珠台 × 肉鴿（Roguelite）**小品遊戲。玩家是一團能量體，潛入賽博空間的奈米地下城，對抗病毒、防火牆與核心程式。

核心玩法：
- 每回合獲得數顆能量球。
- 玩家逐顆瞄準並發射。
- 球碰撞場上的發光能量節點（釘子），累積傷害與效果。
- 所有球落底後，**一次結算**總傷害給敵人。
- 敵人未死則反擊玩家；玩家 HP 歸零即遊戲結束。
- 打倒敵人後進入**三選一升級**，逐層深入，最終擊敗 Boss。

本專案**不是要展示大型遊戲製作能力**，而是展示前端工程師如何用 AI 建立**可控、可驗收、可迭代**的遊戲開發流程。

## 2. 展示目標（比賽現場）

- 在比賽現場以 **Godot 4 Desktop Export** 穩定展示。
- 一局完整 Demo 控制在 **5–10 分鐘**。
- 重點呈現：**Human-in-the-loop 的 AI 開發流水線**
  - 人類訂方向 → AI 寫文件 / 任務卡 → Codex 實作 → AI Reviewer 檢查 → AI Tester 驗收。
- 強調這是 **Self-Correcting Agent Workflow**，不是 Self-Improving 黑箱。

## 3. 技術棧

| 項目 | 選擇 |
| --- | --- |
| 引擎 | Godot 4.6（Forward Plus） |
| 語言 | GDScript（後續任務卡才實作） |
| 渲染 | 2D + Glow / 粒子（不使用複雜 3D） |
| 數值 | 外部 JSON 驅動（`Data/*.json`） |
| 交付 | Windows Desktop Export |
| AI 角色 | Claude / ChatGPT（文件）、Codex（實作）、AI Reviewer、AI Tester |

## 4. 目錄說明

```txt
NanoDungeon/
├── README.md              ← 你正在讀的檔案：總覽 + 接手指南
├── ROADMAP.md             ← Phase 0–5 開發路線與完成定義
├── OPEN_QUESTIONS.md      ← 待決策問題與不確定事項紀錄
├── CHANGELOG.md           ← 每次變更的紀錄
├── Docs/                  ← 設計文件（What & Why）
│   ├── 01_GAME_VISION.md      願景與非目標
│   ├── 02_GAME_DESIGN.md      玩法設計
│   ├── 03_SYSTEM_SPEC.md      技術 / 系統規格
│   ├── 04_BALANCE_RULES.md    數值原則
│   └── 05_ART_DIRECTION.md    美術方向
├── Codex/                 ← 給 AI 實作者的指令（How）
│   ├── 00_MASTER_PROMPT.md    Codex 每次進專案必讀總控提示
│   ├── 01_FIRST_PLAYABLE.md   任務卡 1：最小可玩
│   ├── 02_PINBALL_FEEL.md     任務卡 2：彈珠手感
│   ├── 03_ENEMY_SYSTEM.md     任務卡 3：敵人 / 回合制
│   ├── 04_ROGUELITE_BUILD.md  任務卡 4：升級三選一
│   └── VALIDATION_CHECKLIST.md 全專案驗收清單
├── Data/                  ← JSON 數值配置（資料驅動）
│   ├── pegs.json
│   ├── balls.json
│   ├── enemies.json
│   └── upgrades.json
└── project.godot          ← Godot 專案檔（已存在）
```

> **Docs vs Codex 的差別**：`Docs/` 描述「遊戲是什麼、為什麼」，是規格來源（source of truth）；`Codex/` 描述「AI 該怎麼一步步做」，是執行指令。兩者衝突時，以 `Docs/` 為準，並把衝突寫進 `OPEN_QUESTIONS.md`。

## 5. 開發原則

1. **規格先行**：先有 `Docs/`，才有實作。沒寫進文件的需求不做。
2. **資料驅動**：所有可調數值放在 `Data/*.json`，程式只讀不寫死。
3. **可運行優先**：先讓遊戲跑得起來，再做表現強化（feel / 特效）。
4. **小步前進**：一次只完成一張任務卡，不一次重寫整個專案。
5. **不確定不亂動**：遇到模糊處寫進 `OPEN_QUESTIONS.md`，等待人類決策，**不得擅自更改核心方向**。
6. **每次留痕**：每次變更更新 `CHANGELOG.md`，並依 `VALIDATION_CHECKLIST.md` 自我檢查。
7. **Demo 穩定 > 完整內容**：能穩定跑完一局比花俏功能更重要。

## 6. AI Workflow 總覽

這是一個 **可控的 Self-Correcting Agent Workflow**，不是全自動 Self-Improving Agent。

```txt
        ┌─────────────┐
        │   人類 Human │  決定方向、範圍、玩法取捨（唯一可改核心方向者）
        └──────┬──────┘
               │ 需求 / 取捨
               ▼
   ┌────────────────────────┐
   │ Claude / ChatGPT       │  產出設計文件、任務卡、驗收清單
   │ (Spec & Task Author)   │  → Docs/、Codex/、VALIDATION_CHECKLIST.md
   └───────────┬────────────┘
               │ 任務卡
               ▼
   ┌────────────────────────┐
   │ Codex (Implementer)    │  依任務卡實作 Godot 專案（GDScript / 場景）
   └───────────┬────────────┘
               │ 變更
               ▼
   ┌────────────────────────┐
   │ AI Reviewer            │  檢查是否偏離 Docs/ 規格與禁止事項
   └───────────┬────────────┘
               │ 通過 / 退回
               ▼
   ┌────────────────────────┐
   │ AI Tester              │  依 VALIDATION_CHECKLIST.md 逐項驗收
   └───────────┬────────────┘
               │ 不確定 / 缺口
               ▼
        ┌──────────────┐
        │OPEN_QUESTIONS│  回到人類決策，不得擅自改方向
        └──────────────┘
```

角色職責：

| 角色 | 負責 | 不可做 |
| --- | --- | --- |
| 人類 | 方向、範圍、玩法取捨、最終拍板 | — |
| Claude / ChatGPT | 設計文件、任務卡、驗收清單 | 替人類決定核心玩法 |
| Codex | 依任務卡實作 | 改核心方向、一次重寫全專案 |
| AI Reviewer | 對照規格檢查偏離 | 自行擴張需求 |
| AI Tester | 依清單驗收、回報結果 | 放水通過 |

## 6.1 AI Development Workflow（Loop 視角）

本專案已升級為 **AI Loop Driven Project**。除了上方的角色協作圖，開發以「迴圈」推進——每一圈從讀規格開始，到產出進度報告結束，再進入下一圈。完整定義見 [`LOOP.md`](LOOP.md)。

```txt
Human
  ↓
Design Documents      （Docs/ 規格來源，只有人類可改核心）
  ↓
Codex                 （讀規格、理解現況）
  ↓
WORK_PLAN             （動手前先產計畫，見 WORK_PLAN.md）
  ↓
Implementation        （依任務卡小步實作）
  ↓
Validation            （依 Codex/VALIDATION_CHECKLIST.md 自我驗收）
  ↓
Progress Report       （產出 PROGRESS_REPORT.md）
  ↓
Next Loop             （回到讀規格，進入下一圈）
```

相關檔案：
- [`LOOP.md`](LOOP.md) — AI 開發迴圈定義、人類 / AI 職責、升級回報規則。
- [`WORK_PLAN.md`](WORK_PLAN.md) — 每圈開始前的計畫（模板 + 當前計畫）。
- [`PROGRESS_REPORT.md`](PROGRESS_REPORT.md) — 每圈完成後的成果報告（模板 + 最新報告）。
- `Codex/00_MASTER_PROMPT.md` 的 **Autonomous Loop Rules** 與 **Agent Permission Matrix** 定義 AI 在迴圈中的紀律與權限邊界。

## 7. 如何讓 Codex 接手

1. 先讀 **[`Codex/00_MASTER_PROMPT.md`](Codex/00_MASTER_PROMPT.md)**（總控提示，每次進專案必讀）。
2. 讀 `Docs/` 全部 5 份文件，建立規格認知。
3. 確認當前 Phase（見 [`ROADMAP.md`](ROADMAP.md)）。
4. 領取對應任務卡（Phase 1 → `Codex/01_FIRST_PLAYABLE.md`）。
5. 實作時只讀 `Data/*.json`，不要把數值寫死。
6. 完成後：
   - 依 `Codex/VALIDATION_CHECKLIST.md` 自我檢查。
   - 更新 `CHANGELOG.md`。
   - 把任何不確定處寫進 `OPEN_QUESTIONS.md`。
7. **目前狀態**：Phase 0 文件與資料結構已完成，下一步交給 Codex 的是 **[`Codex/01_FIRST_PLAYABLE.md`](Codex/01_FIRST_PLAYABLE.md)**。
