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
- Phase 1 ~ 15 已完成，卡 15 已加入 hitstop、Peg 查表回饋與 round heat。
- 實機回饋指出回合切換橫幅太快、球撞釘仍偏重；`OPEN_QUESTIONS.md` Q-032 已採 `⚠️ 暫行假設` C：小幅物理 + 視覺 squash。
- Q-031 已決議後續移除力道控制，但卡 16 明確禁止碰控制方式；本圈不改發射輸入 / 集氣流程。

# Current Phase
- **Phase 16 — Feel Tuning（回合節奏 + 彈跳手感微調）**。

# Recommended Task
- 執行 `Codex/16_FEEL_TUNING.md`。
- 調長 `Data/feel.json` 的回合橫幅停留與必要節奏停頓。
- 新增 Ball 命中 peg 的視覺 squash-stretch，參數進 `feel.json`，只動視覺 scale。
- 依 Q-032 C 小幅調 `Data/player.json` 的 `ball_gravity_scale` / `ball_bounce` / `peg_bounce_boost`。

# Why
- `Docs/01_GAME_VISION.md` 要求節奏清楚且命中「爽、脆、亮」；目前 hitstop 已補頓挫，但橫幅與彈跳重量仍需微調。
- `turn_pacing.banner_duration` 是純表現項，調長能讓「你的回合 / 敵人回合」更有回合制呼吸感。
- 彈跳物理會牽動命中數與傷害累積，因此只做保守幅度，並用 squash 把更多爽感放在視覺層。

# Risks
- 橫幅停太久可能拖慢一局 5-10 分鐘節奏；只調到卡片建議約 2.6 秒，並驗證狀態機不卡。
- 物理微調可能提高命中數與回合傷害；調幅控制在 Q-032 建議值附近，完成後回報需人類實機難度對照。
- Squash 必須只動視覺 scale，不可改 `CollisionShape2D`、不可改 `linear_velocity`。
- 新增 `ball_squash` schema 屬表現層擴張；若需要更大物理改動，必須回 Q-032 升級提案。

# Dependencies
- Q-032 已存在並採 C 作為暫行假設，允許小幅物理 + 視覺 squash；本圈不得超出此假設。
- Q-031 控制方式已決議但留待卡 17，不納入本圈。

# Estimated Scope
- 小到中。修改 `Data/feel.json`、`Data/player.json`、`Scripts/Ball.gd`、`Scripts/DataLoader.gd`，並更新 `CHANGELOG.md`、`PROGRESS_REPORT.md`、`WORK_PLAN.md`。

# Validation Target
- 對照 `Codex/16_FEEL_TUNING.md` DoD：橫幅約三倍停留、撞釘 squash 可見、squash 不動碰撞 / 速度、物理小幅微調且可回退、JSON / Godot 載入通過。
- 同步檢查 `VALIDATION_CHECKLIST.md` 的 D/G/H：命中回饋、幀率 / 物理穩定、5-10 分鐘節奏風險、未碰控制方式 / P1 / P2 / 核心方向。

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
