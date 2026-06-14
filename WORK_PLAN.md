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
- Phase 1 ~ 12 已完成，核心美術資產、背景、logo 圖徽、敵人立繪、釘 / 球中性底圖與 fallback 接線已落地。
- 人類已確認主選單 GUI crash 根因是 Godot 4.6.3 `d3d12` 後端 bug，專案改用 `vulkan`；本圈不再改渲染相關設定。
- Q-027 已決議：Phase 14 只做純程序化場景 polish，字體使用 `assets/fonts/JiangChengJianRenHei.ttf`，表現參數集中於 `Data/feel.json`，不改玩法數值。

# Current Phase
- **Phase 14 — Scene Polish（場景視覺打磨）**。

# Recommended Task
- 執行 `Codex/14_SCENE_POLISH.md`。
- 以 shader / draw / Line2D / Tween / 粒子等純程序化方式完成：釘球發光、底排 bumper 霓虹環、HUD 資料面板 + 字體、敵人區整合。
- 全 UI 套用 `assets/fonts/JiangChengJianRenHei.ttf`，缺字體時回到 Godot 預設字體。

# Why
- Phase 12 圖像已接線，但場景仍需要更完整的發光、資料化 HUD 與敵人區視覺整合，才能符合 `Docs/05_ART_DIRECTION.md` 的低對比資料層與霓虹核心感。
- Q-027 已收斂工具與護欄：不用外部新圖、不做逐釘 Light2D、不碰 gameplay / physics / render settings。
- 這一圈是純表現層，可在不破壞 Phase 12 fallback 的前提下提升可視讀性。

# Risks
- 發光若使用大量 Light2D 會有性能風險；本圈改用 `_draw()` / Line2D / ColorRect，不逐釘加燈。
- HUD runtime 重排需避免遮擋彈珠場與互動輸入；UI 背景節點必須 `MOUSE_FILTER_IGNORE`。
- 字體缺失時不能 crash；字體套用需保守，以節點 override 為主。
- MainMenu 背景 / logo 載入需維持正常，不因 polish 重做而短路。

# Dependencies
- Q-027 已決議，無阻斷性未決問題。
- `assets/fonts/JiangChengJianRenHei.ttf` 已存在；Phase 12 圖像資產與 fallback 接線已存在。

# Estimated Scope
- 中。修改 `Data/feel.json`、`Scripts/Peg.gd`、`Scripts/Ball.gd`、`Scripts/Battle.gd`、全 UI 入口腳本，新增 `Scripts/UITheme.gd`，並更新 CHANGELOG / PROGRESS_REPORT / WORK_PLAN。

# Validation Target
- 對照 `Codex/14_SCENE_POLISH.md` DoD：釘 / 球發光與 idle pulse、底排 bumper 霓虹環與 hit pulse、HUD 字體 / 面板 / 刻度、敵人 portrait 放大與 HP/name 下移、fallback、無逐釘 Light2D。
- 同步檢查 `VALIDATION_CHECKLIST.md` 的 G/H：視覺一致、未改玩法 / 數值 / 種類、Godot 載入、JSON 解析、export smoke。

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
