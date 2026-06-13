# CHANGELOG — 奈米地下城 Nano Dungeon

本檔案記錄每一次對專案的有意義變更。格式參考 [Keep a Changelog](https://keepachangelog.com/)，採語意化版本（SemVer）精神。

**所有 AI（Claude / Codex / Reviewer / Tester）每完成一次任務，都必須在此留痕。**

---

## 後續 AI 記錄規則

1. **每完成一張任務卡或一次有意義變更，就新增一筆**，置於最上方（最新在上）。
2. 每筆需包含：
   - 版本號或標籤（如 `Phase 1` / `0.1.0`）。
   - 日期（YYYY-MM-DD）。
   - 執行者（Claude / Codex / 人類）。
   - 對應任務卡（如 `Codex/01_FIRST_PLAYABLE.md`）。
   - 變更分類：`Added` / `Changed` / `Fixed` / `Removed` / `Docs` / `Data`。
3. **若變更涉及規格調整**，必須同步更新對應 `Docs/`，並在此註明。
4. **若有未解問題**，在此註明並連結到 `OPEN_QUESTIONS.md` 的題號（如 `見 Q-004`）。
5. **不得用本檔記錄「打算做什麼」**，只記錄「已經做了什麼」。計畫請寫 `ROADMAP.md`。

記錄模板：

```markdown
## [標籤 / 版本] - YYYY-MM-DD — <一句話摘要>
- 執行者：<Claude / Codex / 人類>
- 任務卡：<路徑或 N/A>
### Added
- ...
### Changed
- ...
### Fixed
- ...
### Data / Docs
- ...
### 未解問題
- 見 Q-XXX
```

---

## [Post-MVP / 1.1.0] - 2026-06-13 — 釘子佈局與半徑資料化

- 執行者：Codex
- 任務卡：`Codex/06_FIELD_LAYOUT.md`

### Added
- 新增 `Data/field.json`，保存彈珠場 bounds、預設 peg radius 與 8 顆 peg 的 `id / x / y / radius` 佈局資料。
- `DataLoader.gd` 新增 `field.json` 載入與驗證：peg id 必須存在、座標需在 bounds 內、radius 必須 > 0。

### Changed
- `Battle.gd._spawn_pegs()` 改為讀取 `Data/field.json` 生成 peg，移除寫死 peg 座標與類型陣列。
- `Peg.gd.configure()` 改為接收 per-peg radius，並為每顆 peg 建立獨立 `CircleShape2D`，確保碰撞半徑與繪製半徑一致且不共用 sub-resource。

### 驗收
- Godot 4.6.3 headless 載入 main scene 與 `Scenes/Battle.tscn` 通過。
- `Data/*.json` 解析通過。
- 靜態檢查確認 `Battle.gd` 不再保留 peg 位置 / 類型硬寫，`Peg.gd` 不再保留 `radius := 18.0`，且 `configure()` 內使用 `CircleShape2D.new()`。

### 未解問題
- 無新增。Q-014 採本卡指定預設：單一基礎佈局套用全部場次；本卡不實作每層變化。

## [Phase 5 / 1.0.1] - 2026-06-13 — Phase 5 通過人類實機 + export 驗收

- 執行者：人類（驗收）+ Claude（留痕）
- 任務卡：`Codex/05_POLISH_DEMO.md`

### Changed
- 人類完成最終驗收：實機跑 export 版本與完整局數，確認 Demo 達「比賽現場可穩定展示」標準。
- `ROADMAP.md`：Phase 5 標記完成；新增 Phase 6（Field Layout，可玩性調整）列，指向 `Codex/06_FIELD_LAYOUT.md`。

### 備註
- MVP（Phase 1–5）全部完成並驗收。Phase 6 為 MVP 後的可玩性增量，採單一基礎佈局（Q-014 每層變化暫不做）。

## [Phase 5 / 1.0.0] - 2026-06-13 — 完成 Polish & Demo 收尾

- 執行者：Codex
- 任務卡：`Codex/05_POLISH_DEMO.md`

### Added
- 新增 `export_presets.cfg`，設定 Windows Desktop export，輸出 `Builds/NanoDungeon.exe`。
- `UpgradeScreen` 新增霓虹卡片樣式與 rarity 顏色回饋。

### Changed
- `GameOver.tscn` / `Victory.tscn` 改為場景節點 UI，腳本只負責填 summary 與按鈕連線。
- `RunState.build_summary()` 改顯示球種 / 升級名稱，不再顯示原始 id。
- 主選單副標題更新為 MVP Demo。

### Data
- `Data/feel.json` 移除已無引用的 `reward_advance_delay_seconds`。
- 保留 Phase 4 已通過的人類驗收平衡值，未改戰鬥 / 升級規則。

### 驗收
- Godot 4.6.3 headless 載入 main scene、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` 皆通過。
- `Data/*.json` 解析通過。
- Windows Desktop Export 成功產出 `Builds/NanoDungeon.exe`，匯出 log 確認 `Data/*.json` 打包；匯出 exe 可用 `--headless --quit` 獨立啟動。
- 暫時 smoke test 已驗證連續 3 局 RunState reset + 4 次升級抽取 / 套用無狀態殘留；測試檔已刪除，未納入產品。

### 未解問題
- 無新增。Q-001 ~ Q-013 皆依已決議現狀執行。

## [Phase 4 / 0.6.1] - 2026-06-13 — Phase 4 通過人類驗收 + 全數暫行假設定案 + Phase 5 任務卡

- 執行者：Claude（Technical Reviewer 角色）+ 人類（驗收與決策）
- 任務卡：`Codex/04_ROGUELITE_BUILD.md`（已完成驗收）

### Changed
- 人類於 Godot 實機驗證 Phase 4（完整 5 場 + 4 次三選一 + Victory），確認通過。MVP 10 項功能全部到齊。
- `ROADMAP.md`：Phase 4 標記完成；Phase 5 改為指向新任務卡 `Codex/05_POLISH_DEMO.md`。
- `Data/player.json`：`_meta` 描述更新，反映 Q-007 已定案為專案標準檔。

### Added
- `Codex/05_POLISH_DEMO.md`：Phase 5 收尾任務卡（實機回歸、平衡只調 JSON、UI 一致性、Windows Export、死設定清理、穩定性），含 G/H 區驗收與禁止事項。

### 決策（暫行假設一次定案）
- **Q-001**：倍傷釘每回合 1 次、×2（升級可加）。
- **Q-002**：Blast 取含倍傷後最高單次、可隨球數疊加。
- **Q-003**：Shield -30%、取最高不疊加。
- **Q-006**：底部全開 + 8 秒超時回收，不做 flippers。
- **Q-007**：保留 `Data/player.json` 為專案標準檔。
- 以上經 Phase 1–4 實機驗證穩定，由「暫行假設」正式移入「已決議」。`OPEN_QUESTIONS.md` 待決區現已清空（Q-001~Q-013 全數定案）。

### 備註
- 本圈為審查 + 決策落地 + 任務卡建立，未撰寫 / 修改任何 GDScript 或場景。

## [Phase 4 / 0.6.0] - 2026-06-13 — 完成 Roguelite Build 三選一升級

- 執行者：Codex
- 任務卡：`Codex/04_ROGUELITE_BUILD.md`

### Added
- 新增 `Scenes/UpgradeScreen.tscn` / `Scripts/UpgradeScreen.gd`：非 Boss 勝利後顯示三選一升級卡片，選擇後進入下一場。
- 新增 `Scripts/UpgradeResolver.gd`：集中處理升級抽取與套用，包含 rarity 權重 60 / 30 / 10、同次排重、已解鎖 / 已達上限排除、精英怪第 1 槽 rare+ 保底。
- `RunState.gd` 新增整局成長狀態：peg damage / effect / trigger mods、enemy attack down、applied upgrades、pending upgrade enemy type。
- `RunState.gd` 新增 `balls.json` 的 `unlocked_by_default` 初始化與 unlock append，維持 round-robin 球池。

### Changed
- `Battle.gd` 非 Boss 敵人死亡後改切 `UpgradeScreen.tscn`，不再使用升級占位直接進下一場。
- `Battle.gd` 命中 Peg 時套用 `RunState` 的 peg 修正；敵人攻擊套用整局 `enemy_attack_down` 後再交給 Shield 減免。
- `DataLoader.gd` 新增 upgrades target 驗證與預設解鎖球查詢。
- `GameOver.gd` / `Victory.gd` 結算摘要顯示本局 build / 球池摘要。

### 驗收
- Godot 4.6.3 headless 載入 main scene、`Scenes/Battle.tscn`、`Scenes/UpgradeScreen.tscn`、`Scenes/GameOver.tscn`、`Scenes/Victory.tscn` 皆通過。
- `Data/*.json` 解析通過。
- 暫時驗證場景確認：初始球池讀 `unlocked_by_default`、精英首槽 rare+、同次選項不重複、已解鎖球與球數封頂升級會排除、unlock append、max HP 升級補半。

### 未解問題
- 無新增。Q-004 / Q-005 / Q-013 已按定案實作。

## [Phase 3 / 0.5.0] - 2026-06-13 — 完成敵人系統與 5 場戰鬥流程

- 執行者：Codex
- 任務卡：`Codex/03_ENEMY_SYSTEM.md`

### Added
- 新增 `Data/feel.json`，集中管理 Phase 2 手感與表現常數：shake、粒子、拖尾、浮動文字、SFX、HP tween、peg re-hit cooldown、換場等待。
- 新增 `Scripts/BattleFX.gd`，承接命中 / 發射粒子、screen shake、浮動文字與 placeholder SFX。
- `Ball.gd` 新增 per-ball / per-peg re-hit cooldown，預設 0.2 秒，讀自 `Data/feel.json`。
- `Battle.gd` 實作 5 場敵人依序載入、完整回合 FSM、敵人攻擊、Boss 週期強攻擊、場次推進、HP bar 更新與勝敗切場。
- 新增 `Scenes/GameOver.tscn` / `Scripts/GameOver.gd` 與 `Scenes/Victory.tscn` / `Scripts/Victory.gd`，提供死亡 / 勝利結算、重來與回主選單。

### Changed
- `DataLoader.gd` 新增 `feel.json` 載入與基本驗證。
- `RunState.gd` 新增擊殺數與用時統計所需狀態。
- `Battle.tscn` 新增 `BattleFX` 節點、玩家 / 敵人 HP bar、敵人占位顯示、場次 / 類型 / dialogue UI。
- 正式戰鬥球種來源改回 `RunState.unlocked_balls`，預設只發 Normal Ball。

### Removed
- 移除 `Data/player.json` 的 `phase2_test_ball_sequence` 與 `sfx_enabled`，避免 Phase 2 測試序列影響正式戰鬥節奏。
- `Battle.gd` 不再 inline 粒子、screen shake、浮動文字或 SFX 產生邏輯。

### 驗收
- Godot 4.6.3 headless 載入主場景、`Scenes/Battle.tscn`、`Scenes/GameOver.tscn`、`Scenes/Victory.tscn` 皆通過。
- `Data/*.json` 解析通過。
- 靜態檢查確認 `Battle.gd` 無 `CPUParticles2D` / `AudioStreamGenerator` / `randf_range` / `phase2_test_ball_sequence`，正式戰鬥不再讀取測試球序列。

### 未解問題
- 無新增。遵守 Q-003 / Q-005 暫行假設；Q-010 / Q-011 / Q-012 已依決議實作或保留既有規則。

## [Phase 2 / 0.4.0] - 2026-06-13 — 實作 Pinball Feel 與 4 釘 3 球效果

- 執行者：Codex
- 任務卡：`Codex/02_PINBALL_FEEL.md`

### Added
- `EffectResolver` 新增 Peg 效果分派：`damage`、`heal`、`damage_multiplier`，遵守 Q-001 暫行假設（Double Peg 每回合 1 次、倍率 ×2）。
- `EffectResolver` 新增 Ball 效果分派：`none`、`on_drop_bonus`、`damage_reduction`，遵守 Q-002 / Q-003 暫行假設。
- `RoundContext` 新增回合倍率、最高單次傷害、待結算回血、Blast 結算加成、Shield 減傷等回合暫存。
- `Battle.gd` 新增命中粒子、發射粒子、傷害 / 回復 / 倍率浮動文字、screen shake、結算總傷害顯示。
- 新增 placeholder SFX：發射、命中、撞牆、落底、結算事件皆有簡單合成 beep，並提供 `SFX: ON/OFF` 按鈕。
- `Ball.gd` 新增球拖尾粒子與三球顏色辨識。
- `Peg.gd` 新增四種 Peg 顏色與命中閃光。

### Changed
- `Battle.gd` 的 Peg 佈局在既有 8 個座標中改為 Normal / Burst / Heal / Double 循環，以驗證 4 種 Peg 效果。
- `Data/player.json` 新增 `phase2_test_ball_sequence`，讓每回合 3 顆球依序為 Normal / Blast / Shield，僅供 Phase 2 效果驗證，不做正式解鎖流程。
- `Data/player.json` 新增 `sfx_enabled` 作為音效預設開關。
- `WORK_PLAN.md` 更新為 Phase 2 實作計畫。

### 驗收
- Godot 4.6.3 headless 載入主場景與 `Scenes/Battle.tscn` 無腳本解析 / 場景錯誤。
- `Data/*.json` 解析通過。
- 靜態檢查確認 `Battle.gd` 未 inline `effect_type` / `base_damage` / `effect_value` 效果邏輯。

### 未解問題
- 無新增。沿用 Q-001 / Q-002 / Q-003 暫行假設；Q-004 / Q-005 仍待 Phase 4 前決策。

## [Phase 3 / 0.5.1] - 2026-06-13 — Phase 3 通過人類驗收 + Phase 4 決策定案

- 執行者：Claude（Technical Reviewer 角色）+ 人類（驗收與決策）
- 任務卡：`Codex/03_ENEMY_SYSTEM.md`（已完成驗收）

### Changed
- 人類於 Godot 實機驗證 Phase 3（5 場流程、Boss 強攻擊、結算場景），確認通過。
- `ROADMAP.md`：Phase 3 標記完成；Phase 4 註明 Q-004/005/013 已定案。
- `Codex/04_ROGUELITE_BUILD.md`：將抽取 / 保底 / 球池規則由「待決議」收斂為定案，並補上對應驗收項與禁止事項。

### Docs / 決策
- Phase 3 Review 確認前置（BattleFX 抽離、feel.json、peg cooldown、移除測試球序列）全數達成。
- 新增並由人類決議（已收斂為可直接實作的規則）：
  - **Q-004**：rarity 加權 60/30/10、抽 3 個互不重複、排除已解鎖 / 已達上限、池不足給幾算幾、不做固定劇本。
  - **Q-005**：精英怪三選一第 1 槽保底 rare+；普通怪一般加權；精英不另解鎖球種；Boss 無三選一。
  - **Q-013**：球池 round-robin，初始 `unlocked_balls` 改讀 `unlocked_by_default`，`unlock` 升級 append 末端。

### 未解問題
- Q-004 / Q-005 由「待決策」移入「已決議」；新增 Q-013（已決議）。
- 仍為暫行假設待人類最終確認者：Q-001/002/003/006/007（沿用中，不阻擋）。

### 備註
- 本圈為審查 + 決策落地，未撰寫 / 修改任何 GDScript 或場景。

## [Phase 3 / 0.5.0] - 2026-06-13 — 完成 Enemy System 與 Phase 2 Review 前置

- 執行者：Codex
- 任務卡：`Codex/03_ENEMY_SYSTEM.md`
- Commit：`4a0f273 Implement Phase 3 enemy system`（已 push 至 origin/main）

### Added
- `Scripts/BattleFX.gd`：表現層（粒子 / shake / 浮動文字 / placeholder SFX）自 `Battle.gd` 抽離。
- `Data/feel.json`：手感常數資料化（含 peg re-hit cooldown 0.2s）；`DataLoader` 載入與驗證。
- 5 場敵人依序載入、完整回合制 FSM（REWARD/GAME_OVER/VICTORY）、敵人攻擊、Boss 每 3 回合強攻擊。
- 玩家 / 敵人 HP bar 與敵人資訊 UI（場次 / 類型 / dialogue / portrait 占位）。
- `Scenes/GameOver.tscn` + `Scripts/GameOver.gd`、`Scenes/Victory.tscn` + `Scripts/Victory.gd`。
- `RunState`：擊殺數與用時統計。

### Changed
- `Scripts/Ball.gd`：per-ball / per-peg re-hit cooldown、拖尾參數改讀 `feel.json`。
- `Data/player.json`：移除 `phase2_test_ball_sequence` 與 `sfx_enabled`，正式戰鬥依 `RunState.unlocked_balls` 發球。

### 備註
- 未改 Peg / Ball / Enemy 種類數量，未實作連鎖釘 / 連射球 / 升級三選一。

## [Phase 2 / 0.4.1] - 2026-06-13 — Phase 2 通過人類驗收 + Review 決策落地

- 執行者：Claude（Technical Reviewer 角色）+ 人類（驗收與決策）
- 任務卡：`Codex/02_PINBALL_FEEL.md`（已完成驗收）

### Changed
- 人類於 Godot 實機驗證 Phase 2 Pinball Feel，確認手感 / 回饋良好，通過。
- `ROADMAP.md`：Phase 2 標記完成；Phase 3 補上「Phase 2 Review 併入前置」說明。
- `Codex/03_ENEMY_SYSTEM.md`：新增「Phase 2 Review 併入前置（必做）」段與對應驗收項（BattleFX 抽離、feel 資料化、peg cooldown、移除測試球序列副作用）。

### Docs
- `Docs/02_GAME_DESIGN.md`：Peg 規則新增「再命中冷卻」與「不實作釘子耗損」；Ball 規則補充 Blast 可疊加、Shield 不疊加。
- `Docs/03_SYSTEM_SPEC.md`：模組邊界新增 Presentation / BattleFX；注意事項新增 feel 數值資料化與表現層分離。
- `Docs/04_BALANCE_RULES.md`：新增「釘子再命中冷卻 / feel 設定」小節（cooldown 預設 0.2s、feel 數值放 `Data/feel.json`）。

### 未解問題
- 新增並已由人類決議：Q-010（釘子重複命中 → re-hit cooldown 0.2s）、Q-011（feel 數值資料化 → 新增 `Data/feel.json`）、Q-012（多顆 Blast 可疊加）。
- 既有 Q-001~Q-007 維持；Q-008/Q-009 已決議。

### 備註
- 本圈為審查 + 文件落地，未撰寫 / 修改任何 GDScript 或場景。Q-010/Q-011 的實作併入 Phase 3。

## [Phase 2 / 0.4.0] - 2026-06-13 — 完成 Phase 2 Pinball Feel 第一版

- 執行者：Codex
- 任務卡：`Codex/02_PINBALL_FEEL.md`

### Added
- 4 種 Peg 與 3 種 Ball 效果經 `EffectResolver` 全數生效；命中粒子、球拖尾、Peg 閃光、screen shake、浮動傷害數字、結算總傷顯示、可關閉 placeholder SFX。
- `Battle.tscn` 新增 `BattleCamera`、`SfxToggleButton`。

### Data
- `Data/player.json` 新增 `phase2_test_ball_sequence` 與 `sfx_enabled`（測試用，Phase 3 將移除其對正式戰鬥的影響）。

### 備註
- 未改 Peg / Ball / Enemy 種類數量，未實作連鎖釘 / 連射球 / 升級 / Phase 3+ 流程。

## [Phase 1.5 / 0.3.2] - 2026-06-13 — Phase 1.5 通過人類實機驗收

- 執行者：人類（驗收）
- 任務卡：`Codex/01b_REFACTOR.md`

### Changed
- 人類於 Godot 編輯器實機驗證 01b 重構為行為等價（含瞄準線 / 發射點回歸點），確認通過。
- `ROADMAP.md`：Phase 1.5 標記為完成（人類實機驗證行為等價）。放行進入 Phase 2。

## [Phase 1.5 / 0.3.1] - 2026-06-13 — 完成 Architecture Refactor 行為等價重構

- 執行者：Codex
- 任務卡：`Codex/01b_REFACTOR.md`

### Added
- 新增 `Scripts/EffectResolver.gd`：集中 Peg `effect_type` 分派，目前僅搬移 Phase 1 的 `damage` 分支，未實作其他效果。
- 新增 `Scripts/RoundContext.gd`：集中回合暫存，包含目前使用的傷害累積與球數狀態，並宣告 Phase 2 預留欄位但不啟用。

### Changed
- `Scripts/Battle.gd`：改為呼叫 `EffectResolver` 處理 Peg 命中，改用 `RoundContext` 持有回合狀態，並統一所有狀態切換走 `_transition_to()`。
- `Scenes/Battle.tscn`：依 Q-008 決議，將彈珠場節點、牆、BottomSensor、容器與 BattleUI 改為場景內實際節點；座標、尺寸、顏色與 UI 版面維持 Phase 1 等價。
- `WORK_PLAN.md`：更新 Phase 1.5 Dependencies，標記 Q-008 / Q-009 已決議且無阻斷。

### Fixed
- 修正場景分離後 FieldFill 覆蓋 `Battle.gd` `_draw()`，導致瞄準線與發射點不可見的回歸；改以 `AimOverlay` 的 `Line2D` / `Polygon2D` 顯示，保留原座標與瞄準邏輯。

### Removed
- 移除根目錄空場景 `node_2d.tscn`；確認沒有 `.tscn` 或腳本引用。

### 驗收
- Godot 4.6.3 headless 載入主場景與 `Scenes/Battle.tscn` 無腳本解析 / 場景錯誤。
- `Data/*.json` 解析通過。
- 靜態檢查確認 `Battle.gd` 不再 inline 判斷 `effect_type`，直接狀態賦值僅保留於 `_transition_to()` 內。

### 未解問題
- 無新增。既有 Q-001 ~ Q-007 維持；Q-008 / Q-009 已決議。

## [Phase 1 / 0.3.0] - 2026-06-13 — 完成 First Playable 最小戰鬥閉環

- 執行者：Codex
- 任務卡：`Codex/01_FIRST_PLAYABLE.md`

### Added
- 新增 `Scenes/MainMenu.tscn` 與 `Scripts/MainMenu.gd`：提供標題、開始、離開，開始後進入戰鬥。
- 新增 `Scenes/Battle.tscn` 與 `Scripts/Battle.gd`：建立最小戰鬥 FSM（回合開始、瞄準、發射、回收、結算、敵人反擊、勝敗判定）。
- 新增 `Scenes/Ball.tscn` / `Scripts/Ball.gd`：Normal Ball 使用 `RigidBody2D`，可發射、受重力、撞釘、落底或超時回收。
- 新增 `Scenes/Peg.tscn` / `Scripts/Peg.gd`：Normal Peg placeholder，可被球碰撞並回報 peg id。
- 新增 `Scripts/DataLoader.gd`：讀取並驗證 `Data/pegs.json`、`balls.json`、`enemies.json`、`upgrades.json`、`player.json`。
- 新增 `Scripts/RunState.gd`：保存本局玩家 HP、每回合球數、解鎖球與戰鬥索引。

### Changed
- `project.godot` 設定 `Scenes/MainMenu.tscn` 為 main scene。
- `project.godot` 新增 `DataLoader` 與 `RunState` autoload。
- `WORK_PLAN.md` 更新為本圈 Phase 1 實作計畫。

### Data / Docs
- 新增 `Data/player.json`：暫存玩家初始 HP、每回合球數、起始球種、球超時、發射力度與基本物理調校值。
- `OPEN_QUESTIONS.md` 新增 Q-007，記錄玩家初始數值與 Phase 1 物理調校值資料位置的暫行假設。

### Fixed
- 修正 Godot 4.6 嚴格模式下 `DataLoader.gd` 的 Variant 型別推斷警告。
- 修正 Battle UI full-rect Control 吃掉滑鼠事件，導致 AIMING 狀態無法左鍵發射的問題；非互動 UI 改為忽略滑鼠，發射輸入改由 `_input()` 接收。

### 驗收
- 已用 Godot 4.6.3 headless 載入主場景與 `Battle.tscn`，無腳本解析錯誤或場景載入錯誤。

### 未解問題
- 見 Q-007。既有 Q-001 ~ Q-006 維持。

## [Phase 1.5 / 0.3.0] - 2026-06-13 — Architecture Review 與重構任務卡

- 執行者：Claude（Game Director + Technical Reviewer 角色）
- 任務卡：N/A（審查 + 規劃，非實作）

### Added
- `Codex/01b_REFACTOR.md`：Phase 1.5 行為等價重構任務卡（Effect Resolver、RoundContext、統一 FSM 入口、場景分離、清殘渣）。

### Changed
- `ROADMAP.md`：標記 Phase 1 完成（人類實機驗證），插入 Phase 1.5 列與章節（含 DoD）。
- `WORK_PLAN.md`：當前計畫切到 Phase 1.5，Phase 1 計畫移為歷史。

### Docs
- 產出 Architecture Review Report（完成度、架構風險評等、技術債、AI Workflow 評估、下一步建議、人類待決事項）。

### 未解問題
- 沿用 Q-001~Q-007。
- 新增並已由人類決議：Q-008（場景策略 → 改為 Battle.tscn 實際節點）、Q-009（project.godot 3D 設定 → Phase 1.5 暫不動）。`01b_REFACTOR.md` 已收斂為定案。

### 備註
- 本圈未撰寫 / 修改任何 GDScript 或場景，僅文件層異動。

## [Phase 0 / 0.2.0] - 2026-06-13 — 升級為 AI Loop Driven Project

- 執行者：Claude
- 任務卡：N/A（框架升級，非玩法任務）

### Added
- `LOOP.md`：AI 開發迴圈定義（Core Loop、Human / AI Responsibilities、Escalation Rules、Loop Invariants）。
- `WORK_PLAN.md`：每圈圈前計畫（模板 + 當前計畫）。
- `PROGRESS_REPORT.md`：每圈圈後成果報告（模板 + 最新報告）。

### Changed
- `README.md`：新增「6.1 AI Development Workflow（Loop 視角）」章節（Human → Design → Codex → WORK_PLAN → Implementation → Validation → Progress Report → Next Loop）。
- `Codex/00_MASTER_PROMPT.md`：新增「Autonomous Loop Rules」與「Agent Permission Matrix」兩章節。

### Docs
- 將專案定位由 Spec Driven 升級為 AI Loop Driven，明確區分人類職責（Vision / Design / Roadmap / 核心玩法 / 比賽目標）與 AI 可自主範圍。

### 未解問題
- 無新增。沿用 Q-001 ~ Q-006；建議優先決議 Q-004、Q-005。

### 備註
- 以增量修改進行，未重寫既有文件、未更動任何核心規格、未撰寫 GDScript 或場景。

## [Phase 0 / 0.1.0] - 2026-06-13 — 初始化 AI 可控開發流水線文件與資料

- 執行者：Claude
- 任務卡：N/A（Phase 0 文件建置）

### Added
- 根目錄：`README.md`、`ROADMAP.md`、`OPEN_QUESTIONS.md`、`CHANGELOG.md`。
- `Docs/`：`01_GAME_VISION.md`、`02_GAME_DESIGN.md`、`03_SYSTEM_SPEC.md`、`04_BALANCE_RULES.md`、`05_ART_DIRECTION.md`。
- `Codex/`：`00_MASTER_PROMPT.md`、`01_FIRST_PLAYABLE.md`、`02_PINBALL_FEEL.md`、`03_ENEMY_SYSTEM.md`、`04_ROGUELITE_BUILD.md`、`VALIDATION_CHECKLIST.md`。

### Data
- `Data/pegs.json`：4 種 Peg 初版數值。
- `Data/balls.json`：3 種 Ball 初版數值。
- `Data/enemies.json`：5 場敵人初版數值（普通 / 普通 / 精英 / 普通 / Boss）。
- `Data/upgrades.json`：12 個升級選項初版。

### Docs
- 確立「人類決策 × AI 執行」的 Self-Correcting Agent Workflow。
- 確立資料驅動、可運行優先、小步前進的開發原則。

### 未解問題
- 見 Q-001（倍傷釘觸發次數）、Q-002（爆破球計算基準）、Q-003（護盾球減傷規則）、Q-004（升級抽取權重）、Q-005（精英怪解鎖）、Q-006（落底判定）。

### 備註
- 未撰寫任何 GDScript、未建立任何遊戲場景（依任務指示，Phase 0 僅文件與資料）。
- `project.godot` 沿用既有設定，未更動。
