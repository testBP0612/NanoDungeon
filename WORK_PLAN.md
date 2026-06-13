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
- Phase 0（文件與資料結構）已完成：README / ROADMAP / OPEN_QUESTIONS / CHANGELOG、`Docs/01–05`、`Codex/00–04` + VALIDATION_CHECKLIST、`Data/` 四份 JSON 皆已建立並通過解析。
- 已升級為 AI Loop Development Framework：新增 `LOOP.md`、`WORK_PLAN.md`、`PROGRESS_REPORT.md`；README 與 MASTER_PROMPT 已補上 Loop 與 Permission Matrix。
- 尚未撰寫任何 GDScript、尚未建立任何遊戲場景。

# Current Phase
- 即將進入 **Phase 1 — First Playable**（目前停在 Phase 0 / Loop 框架完成）。

# Recommended Task
- `Codex/01_FIRST_PLAYABLE.md`（最小可玩：主選單 → 戰鬥 → 發射球 → 撞 Normal Peg → 一次結算給第 1 場敵人）。

# Why
- ROADMAP 顯示 Phase 0 已達 DoD，下一個未完成且無前置阻斷的是 Phase 1。
- First Playable 是後續所有 Phase 的物理 / 流程基礎，必須先打通。

# Risks
- 2D 物理穩定性（球穿透、卡住）→ 需超時回收保險（Q-006 暫定 8 秒）。
- `project.godot` 目前為 3D 物理設定，本遊戲為 2D，調整前須先記錄於 OPEN_QUESTIONS。
- 範圍蔓延：可能不小心提前實作 Phase 2 的特效 / 其他釘子。

# Dependencies
- 無阻斷性前置。Q-006（落底判定）採暫行假設即可推進。

# Estimated Scope
- 中。新增 MainMenu / Battle / Peg / Ball 場景、Data Loader、RunState。

# Validation Target
- `Codex/VALIDATION_CHECKLIST.md` 的 **C. First Playable 驗收** 全部項目；並確認 **H. 禁止偏離項目** 未被違反。
