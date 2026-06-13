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
- Phase 1 / 1.5 / 2 / 3 皆已完成並經人類實機驗證。
- Phase 3 已完成 5 場敵人、完整回合制、HP UI、Boss 強攻擊、GameOver / Victory 結算。
- Phase 4 所需決策 Q-004 / Q-005 / Q-013 已定案，可直接依任務卡實作。

# Current Phase
- **Phase 4 — Roguelite Build**。

# Recommended Task
- 執行 `Codex/04_ROGUELITE_BUILD.md`。
- 新增 `UpgradeScreen.tscn` 三選一流程、升級抽取器 / 套用器、RunState 整局成長狀態，並串接「非 Boss 勝利 → 升級 → 下一場」。
- 初始球池改由 `balls.json` 的 `unlocked_by_default` 初始化；unlock 升級 append 到 round-robin 球池。

# Why
- ROADMAP 顯示 Phase 3 已完成，下一個未完成目標是 Phase 4。
- Phase 3 目前非 Boss 勝利後仍是升級占位，尚未形成 roguelite build 成長閉環。
- Phase 4 完成後，整局 5 場 + 4 次升級才會具備 Demo 的核心 replay value。

# Risks
- 抽取規則若寫在 `Battle.gd` 會破壞 Phase 1.5 / 3 的邊界，需集中在 upgrade resolver。
- 升級效果需持續整局但重開歸零，RunState 初始化與結算場景重來路徑必須同步。
- 可選升級池不足、已解鎖球排除、球數封頂、精英保底 rare+ 都需要靜態與場景載入雙重驗證。
- `upgrades.json` 既有 `add_trigger` 效果需支援，但不得新增 Peg / Ball / Enemy 種類。

# Dependencies
- 無阻斷性前置。
- Q-004：rarity 權重 common / rare / legendary = 60 / 30 / 10；三選一互不重複；排除已解鎖 / 已達上限。
- Q-005：普通怪一般加權，精英怪第 1 槽保底 rare+，Boss 無三選一。
- Q-013：球池 round-robin，初始讀 `unlocked_by_default`，unlock append。

# Estimated Scope
- 大。會新增 `UpgradeScreen.tscn` / `UpgradeScreen.gd` / `UpgradeResolver.gd`，修改 `RunState.gd`、`DataLoader.gd`、`Battle.gd`、`EffectResolver.gd`，必要時微調 `GameOver` / `Victory` build 摘要；更新 CHANGELOG / PROGRESS_REPORT。

# Validation Target
- `Codex/VALIDATION_CHECKLIST.md` **F. Roguelite Build** 全項自驗。
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
