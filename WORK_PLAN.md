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
- Phase 1 / 1.5 / 2 / 3 / 4 皆已完成並經人類實機驗證，MVP 功能到齊。
- Phase 4 已完成三選一升級、整局成長、round-robin 球池與勝利 / 失敗結算。
- Q-001 ~ Q-013 皆已決議；Phase 5 不再改規則，只做 demo polish、穩定性、JSON 平衡與 Windows export。

# Current Phase
- **Phase 5 — Polish & Demo**。

# Recommended Task
- 執行 `Codex/05_POLISH_DEMO.md`。
- 場景化 `GameOver.tscn` / `Victory.tscn` 的 UI，讓腳本只負責填資料與按鈕。
- 改善 `UpgradeScreen` 霓虹賽博風與 rarity 顏色；build 摘要改顯示球種 / 升級名稱。
- 僅透過 JSON 做 demo 平衡微調，移除 `feel.json` 的死設定，新增 Windows Desktop export preset 並嘗試匯出驗證。

# Why
- ROADMAP 顯示 Phase 5 是最後一個未完成 Phase。
- MVP 功能已齊，剩餘差距集中在比賽展示穩定度、流程順手度、場景 / UI 一致性與 export 可用性。
- 任務卡明確要求 demo 是否達「比賽現場可穩定展示」標準。

# Risks
- Export 可能受本機 Godot export templates 是否已安裝影響；若模板缺失，需回報為環境限制。
- 連續 3 局「實機」驗收需要人類可視化確認；Codex 可做 headless / export / 靜態穩定檢查與必要的自動化 smoke test。
- UI polish 需克制，避免新增重特效造成幀率或穩定性風險。
- 平衡只能調 JSON，不得修改戰鬥 / 升級規則來達成數值目標。

# Dependencies
- 無阻斷性規格前置。
- Q-001 ~ Q-013 全數定案，照現狀執行；若需要改規則，停止並寫 `OPEN_QUESTIONS.md`。
- Windows Desktop Export 依賴本機 Godot export templates。

# Estimated Scope
- 中到大。會修改 `Scenes/GameOver.tscn`、`Scenes/Victory.tscn`、`Scripts/GameOver.gd`、`Scripts/Victory.gd`、`Scenes/UpgradeScreen.tscn`、`Scripts/UpgradeScreen.gd`、`RunState.gd`、`Data/feel.json`、必要的 JSON 平衡與 `export_presets.cfg`；更新 CHANGELOG / PROGRESS_REPORT。

# Validation Target
- `Codex/VALIDATION_CHECKLIST.md` **G. Demo 展示驗收** 全項自驗。
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
