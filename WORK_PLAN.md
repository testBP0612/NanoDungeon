# WORK_PLAN — 工作計畫

> 在每一圈（iteration）**開始實作之前**先產生 / 更新本檔。它是 AI 在動手前的「思考留痕」，讓人類能在實作前看見並攔截方向錯誤。
>
> 用法：每圈開始時依下方模板填寫；完成後對應產出 `PROGRESS_REPORT.md`。歷史計畫可往下保留為紀錄（最新在最上方）。

---

## 模板（請複製使用）

```md
# Current State
<目前完成了什麼：已完成的 Phase / 任務卡 / 檔案，簡述現況>

# Current Phase
<目前所處 Phase，對照 ROADMAP.md>

# Recommended Task
<這一圈建議執行的任務卡或增量，例如 Codex/01_FIRST_PLAYABLE.md>

# Why
<為什麼是這一步：對照 ROADMAP 與 DoD 的差距、依賴關係>

# Risks
<可能的風險：物理穩定性、範圍蔓延、規格模糊等>

# Dependencies
<前置條件：需先完成的任務、需先決議的 OPEN_QUESTIONS 題號>

# Estimated Scope
<預估範圍大小：小 / 中 / 大；會動到哪些模組或場景>

# Validation Target
<本圈完成後要對照 VALIDATION_CHECKLIST.md 的哪個區塊 / 哪些項目>
```

---

## 當前工作計畫

# Current State
- Phase 1 / 1.5 / 2 皆已完成並經人類實機驗證。
- Phase 2 已完成 Pinball Feel、4 種 Peg、3 種 Ball、傷害數字、粒子、screen shake 與 placeholder SFX。
- Phase 2 Review 已產出並決議 Q-010 / Q-011 / Q-012，並已併入 `Codex/03_ENEMY_SYSTEM.md` 前置。

# Current Phase
- **Phase 3 — Enemy System**（含 Phase 2 Review 前置）。

# Recommended Task
- 執行 `Codex/03_ENEMY_SYSTEM.md`。
- 先完成前置：抽出 `BattleFX`、新增 `Data/feel.json`、實作 peg re-hit cooldown 0.2s、移除 `phase2_test_ball_sequence` 對正式戰鬥的影響。
- 再完成 5 場敵人流程、完整回合制、Boss 強攻擊、HP UI、GameOver / Victory 結算畫面。

# Why
- ROADMAP 顯示 Phase 2 已完成，下一個未完成目標是 Phase 3。
- Phase 2 Review 的前置若不先做，Battle.gd 會繼續累積 presentation 職責，且 feel 常數仍不符合資料驅動原則。
- 完整 5 場敵人流程是 Phase 4 升級三選一之前的必要戰鬥骨架。

# Risks
- 前置重構需保持 Phase 2 行為等價，不能改特效結果、數值或手感。
- 移除測試球序列後預設正式戰鬥只會發 Normal Ball；Shield / Blast 效果保留但本圈預設不靠測試序列影響節奏。
- 5 場流程可能拉長測試時間，需保證重新開始 / 回主選單狀態乾淨。
- 升級三選一不可在本圈實作，只能用「下一場」或 reward placeholder 推進。

# Dependencies
- 無阻斷性前置。
- Q-003：Shield Ball 減傷百分比 -30%、多顆不疊加，敵人攻擊不得繞過。
- Q-005：精英怪獎勵規則仍待決策；本圈不實作升級，敵人死後先推進下一場。
- Q-010：Peg per-peg re-hit cooldown 採 0.2 秒並資料化。
- Q-011：新增 `Data/feel.json` 資料化 feel 常數。
- Q-012：多顆 Blast Ball 可疊加，保留既有 resolver 行為。

# Estimated Scope
- 大。會新增 / 修改 `BattleFX.gd`、`Data/feel.json`、`DataLoader.gd`、`Battle.gd`、`Ball.gd`、`RunState.gd`、`Battle.tscn`、`GameOver.tscn`、`Victory.tscn` 與對應腳本；更新 CHANGELOG / PROGRESS_REPORT。

# Validation Target
- `Codex/VALIDATION_CHECKLIST.md` **E. Enemy System** 全項自驗。
- 同步回歸 Phase 2 Review 前置：BattleFX 抽出、feel.json、Peg cooldown、正式戰鬥不受測試球序列影響。
- 同步檢查 **H. 禁止偏離**。

---

## 歷史計畫 — Phase 1（已完成）

# Current State
- Phase 0（文件與資料結構）已完成：README / ROADMAP / OPEN_QUESTIONS / CHANGELOG、`Docs/01–05`、`Codex/00–04` + VALIDATION_CHECKLIST、`Data/` 四份 JSON 皆已建立。
- 已升級為 AI Loop Development Framework：`LOOP.md`、`WORK_PLAN.md`、`PROGRESS_REPORT.md` 皆存在。
- Godot 專案目前仍是空殼：尚未建立 `Scenes/`、`Scripts/`，`project.godot` 尚未指定主場景。

# Current Phase
- **Phase 1 — First Playable**。

# Recommended Task
- 執行 `Codex/01_FIRST_PLAYABLE.md`，建立最小可玩閉環：MainMenu → Battle → 讀取 JSON → 顯示玩家 HP / 敵人 HP / 回合傷害 → 瞄準發射 Normal Ball → 撞 Normal Peg 累積傷害 → 落底或 8 秒超時回收 → 全部球回收後一次結算 → 敵人未死亡則以 `enemies.json` 攻擊值反擊 → 玩家 / 敵人死亡基本判定。

# Why
- ROADMAP 顯示 Phase 1 是下一個未完成目標，DoD 要求主選單進戰鬥、發射、碰撞、落底、結算與可重複遊玩。
- 使用者本圈明確要求補足最小戰鬥閉環中的敵人反擊與玩家死亡判定；以基本扣血處理，不延伸到 Phase 3 的 5 場流程、Boss 行為或完整結算畫面。

# Risks
- 2D 物理穩定性（球穿透、卡住）需用落底 Area2D 與 8 秒超時保險處理（沿用 Q-006 暫行假設）。
- `project.godot` 目前未指定主場景；本圈需設定 `Scenes/MainMenu.tscn` 為 main scene，並在 `CHANGELOG.md` 留痕。
- 敵人反擊是最小閉環需求，但需避免擴張成 Phase 3 的完整敵人系統。
- 不做 Phase 2 的特效、音效、其他 Peg / Ball 效果，避免範圍蔓延。

# Dependencies
- 無阻斷性前置。
- 相關未決：Q-006 已允許以「底部全開 + 8 秒超時回收」暫行推進。

# Estimated Scope
- 中。新增 `Scenes/` 與 `Scripts/`：MainMenu、Battle、Peg、Ball、DataLoader、RunState；更新 `project.godot` main scene；更新 CHANGELOG / PROGRESS_REPORT。

# Validation Target
- `Codex/VALIDATION_CHECKLIST.md` 的 **C. First Playable 驗收** 全部項目。
- 同步檢查 **H. 禁止偏離項目**：不改核心設計文件、不改 ROADMAP、不新增 Phase 2+ 玩法、不寫死可調數值。
