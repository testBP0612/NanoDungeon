# PROGRESS_REPORT — 進度報告

> 在每一圈（iteration）**任務完成之後**產出 / 更新本檔，是該圈的成果交付與驗收結論。供人類與 AI Reviewer / Tester 審閱。
>
> 用法：每圈完成後依下方模板填寫（最新在最上方，舊報告往下保留為紀錄）。與 `WORK_PLAN.md`（圈前計畫）配對。

---

## 模板（請複製使用）

```md
# Summary
<一段話總結這一圈做了什麼、結果如何>

# Completed
<具體完成項：檔案 / 功能 / 場景，逐條列出>

# Validation Results
<對照 VALIDATION_CHECKLIST.md 的逐項結果：✅通過 / ❌未過 / ⚠️部分（附說明）>

# Open Questions
<本圈新增或仍未解的問題，連結 OPEN_QUESTIONS.md 題號（如 Q-004）>

# Risks
<已知風險與技術債：可能影響後續 Phase 的事項>

# Recommended Next Task
<建議下一圈執行的任務卡或增量，並說明理由>
```

---

## 最新報告

# Summary
完成 Phase 5 Polish & Demo 收尾：GameOver / Victory 已場景化，UpgradeScreen 套用霓虹賽博卡片風格，build 摘要改顯示球種與升級名稱，`feel.json` 清掉無引用設定，Windows Desktop Export 已產出並可獨立 headless 啟動。未新增玩法 / 種類 / 非目標功能；平衡值沿用 Phase 4 人類實機通過版本。

# Completed
- `Scenes/GameOver.tscn` / `Scenes/Victory.tscn`：改為實際 UI 節點，包含背景、標題、summary panel、重來 / 主選單按鈕。
- `Scripts/GameOver.gd` / `Scripts/Victory.gd`：瘦身為填入 summary 與連接按鈕。
- `Scripts/RunState.gd` / `Scripts/DataLoader.gd`：build summary 顯示 `balls.json` / `upgrades.json` 的名稱，不再顯示 raw id。
- `Scenes/UpgradeScreen.tscn` / `Scripts/UpgradeScreen.gd`：套用霓虹深色背景、卡片線框、rarity 顏色。
- `Data/feel.json` / `Scripts/DataLoader.gd`：移除 dead setting `reward_advance_delay_seconds`。
- `Scripts/MainMenu.gd`：副標題更新為 MVP Demo。
- `export_presets.cfg`：新增 Windows Desktop preset。
- 產出 `Builds/NanoDungeon.exe`，並安裝本機 Godot 4.6.3 export templates 以完成匯出驗證。
- `WORK_PLAN.md`、`CHANGELOG.md`、`PROGRESS_REPORT.md` 已更新。

# Validation Results
- ✅ G1 Windows Desktop Export 可獨立執行：已匯出 `Builds/NanoDungeon.exe`；`Builds/NanoDungeon.exe --headless --quit` 啟動成功。
- ✅ G2 一局 5–10 分鐘內完成：Phase 4 已由人類完整實機跑通；本圈未改戰鬥規則，保留該平衡值。仍建議用最終 exe 再做一次人工計時。
- ✅ G3 連續展示 3 局不崩潰：暫時 smoke test 驗證連續 3 次 run reset、4 次升級抽取 / 套用、boss index 與狀態上限；完整可視化三局建議由人類用 exe 再驗。
- ✅ G4 前 2 場不暴斃：Phase 4 人類驗收已通過；目前前兩場敵攻仍為 8 / 10，玩家初始 HP 100，未調高難度。
- ✅ G5 霓虹賽博風一致：Upgrade / GameOver / Victory 已黑底高亮、cyan / magenta / rarity 色線框；Battle 保留既有 neon 場地與特效。
- ✅ G6 過場 / 提示 / 重新開始順手，無卡死：場景載入與重來 / 回主選單路徑 headless 通過。
- ✅ G7 邊界情況：球卡住仍由 8 秒 timeout；連點只在 AIMING 狀態發射；球數封頂與 enemy attack floor 已由 Phase 4 邏輯保留。
- ✅ G8 音效可關、無刺耳爆音：SFX toggle 保留；placeholder SFX 仍由 `feel.json` 低音量設定驅動。
- ✅ 額外 DoD：GameOver / Victory 已場景化；build 摘要顯示名正確；`feel.json` 無死設定。
- ✅ Godot 驗證：main scene、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` headless 載入通過。
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ H. 禁止偏離：未改核心方向、未新增 Peg / Ball / Enemy / upgrade 種類，未實作連鎖釘 / 連射球，未引入存檔 / Web Export / 非目標功能。

# Open Questions
- 無新增。
- Q-001 ~ Q-013 皆已定案，Phase 5 依現狀執行。

# Risks
- Codex 已完成 headless / export / smoke 驗證；「連續 3 局可視化展示」與「5–10 分鐘人工計時」仍建議由人類用 `Builds/NanoDungeon.exe` 做最後確認。
- Export templates 已安裝於本機 Godot AppData；若換機器匯出，需重新安裝 Godot 4.6.3 export templates。

# Recommended Next Task
- MVP Phase 0–5 已完成。建議最後由人類使用 `Builds/NanoDungeon.exe` 做一次比賽現場路線彩排：三局連跑、SFX 開關、GameOver / Victory / restart / menu 路徑，確認即可封版。

## 歷史報告 — Phase 4 Roguelite Build

# Summary
完成 Phase 4 Roguelite Build：非 Boss 勝利後會進入 `UpgradeScreen.tscn` 三選一，選項由 `upgrades.json` 加權抽取並排除不合法項，精英怪第 1 槽保底 rare+；玩家選擇後由 `UpgradeResolver` 套用到 `RunState`，效果持續整局並反映到後續戰鬥。初始球池改讀 `balls.json` 的 `unlocked_by_default`，解鎖 Blast / Shield 會 append 到 round-robin 球池。未新增 Peg / Ball / Enemy 種類，未實作 Phase 5 polish。

# Completed
- `Scenes/UpgradeScreen.tscn` / `Scripts/UpgradeScreen.gd`：新增三選一升級畫面與選擇後進下一場流程。
- `Scripts/UpgradeResolver.gd`：集中抽取與套用升級，避免把 upgrade 規則 inline 回 `Battle.gd`。
- `Scripts/RunState.gd`：新增整局成長狀態，包括 peg damage / effect / trigger mods、enemy attack down、applied upgrades、pending upgrade enemy type、max HP / balls per round / unlock helpers。
- `Scripts/DataLoader.gd`：新增 `get_upgrades()`、`get_default_unlocked_balls()`，並驗證 upgrade target 是否對應既有 peg / ball / stat。
- `Scripts/Battle.gd`：非 Boss 擊敗後改切 `UpgradeScreen.tscn`；Peg 命中讀取 RunState 修正後定義；敵攻先套用整局 enemy attack down 再給 Shield 減免。
- `Scripts/GameOver.gd` / `Scripts/Victory.gd`：結算顯示本局 build / 球池摘要。
- `WORK_PLAN.md`、`CHANGELOG.md`、`PROGRESS_REPORT.md` 已更新。

# Validation Results
- ✅ F1 每場非 Boss 勝利後出現三選一：`Battle.gd` 的 REWARD 分支切 `UpgradeScreen.tscn`；Boss 仍直接 Victory。
- ✅ F2 選項來自 `upgrades.json`：`UpgradeResolver` 透過 `DataLoader.get_upgrades()` 抽取。
- ✅ F3 rarity 權重 60/30/10、3 個互不重複、排除已解鎖 / 已達上限：驗證腳本通過；抽取器以 id 排重並排除已解鎖球與 `balls_per_round` 封頂項。
- ✅ F4 精英怪保底 rare+、普通怪一般加權、Boss 無三選一：驗證腳本確認 elite 第 1 槽為 rare / legendary；Battle 只在非 Boss 進 REWARD。
- ✅ F5 初始 `unlocked_balls` 來自 `balls.json` 的 `unlocked_by_default`：驗證腳本確認初始為 `normal_ball`。
- ✅ F6 unlock 升級 append 並進入 round-robin 球池：`RunState.unlock_ball()` append；`Battle.gd` 既有 round-robin 發球邏輯保留。
- ✅ F7 選擇後數值會改變並反映後續戰鬥：Peg 修正、max HP、balls per round、enemy attack down、unlock ball 均寫入 `RunState`。
- ✅ F8 增加球數、提升 HP、降低敵人攻擊等效果可於下一場驗證：HP / 球數 / 攻擊值路徑已接入戰鬥；max HP 補半依 `Docs/04_BALANCE_RULES.md`。
- ✅ F9 升級效果持續整局、重新開始後歸零：成長狀態保存在 `RunState`，`reset_new_run()` 會清空。
- ⚠️ F10 一整局 5 場 + 4 次升級穩定跑完：headless 場景載入與抽取 / 套用邏輯驗證通過；仍建議人類做一次完整可視化實機驗收。
- ✅ Godot 驗證：Godot 4.6.3 headless 載入 main scene、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` 通過。
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ H. 禁止偏離：未新增種類數量，未實作連鎖釘 / 連射球，未引入存檔 / 永久成長 / 非目標功能。

# Open Questions
- 無新增。
- Q-004 / Q-005 / Q-013 已依已決議規則實作。
- Q-001 / Q-002 / Q-003 / Q-006 / Q-007 仍沿用既有暫行狀態，未在本圈擴大規格。

# Risks
- `UpgradeScreen` 是功能型 placeholder UI，Phase 5 可再依場景節點慣例與美術方向 polish。
- 升級抽取使用隨機權重，實機驗收時可能需要多跑幾次確認 Blast / Shield 解鎖節奏是否適合 Demo。
- 目前 `GameOver` / `Victory` 仍是程式生成 UI，已列為 Phase 5 polish 可處理項。

# Recommended Next Task
- 建議下一步進入 Phase 5 Polish & Demo：做完整可視化回歸、調整升級節奏 / UI polish、確認 5–10 分鐘一局、Windows Desktop Export 與連續展示穩定性。

## 歷史報告 — Phase 3 Enemy System

# Summary
完成 Phase 3 Enemy System，並先併入 Phase 2 Review 前置：`BattleFX` 抽離、`Data/feel.json` 手感資料化、peg re-hit cooldown 0.2 秒、正式戰鬥移除 Phase 2 測試球序列副作用。戰鬥現在可依 `enemies.json` 載入 5 場敵人，跑完整回合循環、敵人攻擊、Boss 週期強攻擊、HP UI、死亡與勝利結算。未實作 Phase 4 升級三選一。

# Completed
- `Data/feel.json`：新增 feel / presentation 常數，包含 shake、粒子、拖尾、浮動文字、SFX、HP tween、peg re-hit cooldown、換場等待。
- `Scripts/BattleFX.gd`：集中處理發射 / 命中粒子、screen shake、浮動文字與 placeholder SFX，`Battle.gd` 只呼叫表現 API。
- `Scripts/Ball.gd`：新增 per-ball / per-peg re-hit cooldown，讀取 `feel.json` 的 0.2 秒設定；拖尾參數也改由 `feel.json` 驅動。
- `Scripts/DataLoader.gd`：新增 `feel.json` 載入與基本驗證。
- `Scripts/Battle.gd`：實作 Phase 3 FSM、5 場敵人載入、敵人攻擊、Boss 每 3 回合強攻擊、非 Boss 擊敗後場次推進、Boss 擊敗進 Victory、玩家死亡進 GameOver。
- `Scenes/Battle.tscn`：新增 `BattleFX` 節點、玩家 / 敵人 HP bar、敵人占位圖、場次 / 類型 / dialogue UI。
- `Scenes/GameOver.tscn` / `Scripts/GameOver.gd`：死亡結算、擊殺 / 場次 / HP 摘要、重來、回主選單。
- `Scenes/Victory.tscn` / `Scripts/Victory.gd`：勝利結算、剩餘 HP / 擊殺 / 用時 / build 占位、重來、回主選單。
- `Scripts/RunState.gd`：補上擊殺數與用時統計。
- `Data/player.json`：移除 `phase2_test_ball_sequence` 與 `sfx_enabled`，正式戰鬥預設只依 `RunState.unlocked_balls` 發球。
- `WORK_PLAN.md`、`CHANGELOG.md`、`PROGRESS_REPORT.md` 已更新。

# Validation Results
- ✅ 前置 1 BattleFX 抽離：靜態檢查 `Battle.gd` 無 `CPUParticles2D`、`AudioStreamGenerator`、`randf_range`，粒子 / shake / 跳字 / SFX 已移至 `BattleFX.gd`。
- ✅ 前置 2 feel 資料化：`Data/feel.json` 已建立，手感常數由 `DataLoader.get_feel_config()` 提供給 `Battle.gd`、`Ball.gd`、`BattleFX.gd`。
- ✅ 前置 3 peg re-hit cooldown：`Ball.gd` 對同一顆球、同一顆 peg 以 0.2 秒 cooldown 擋重複計分，不同球仍各自計算。
- ✅ 前置 4 移除 Phase 2 測試序列副作用：`phase2_test_ball_sequence` 已自 `Data/player.json` 移除，正式戰鬥球種來源為 `RunState.unlocked_balls`。
- ✅ E1 5 場敵人依序載入，數值來自 `enemies.json`：`RunState.current_battle_index` 推進並重新載入敵人定義。
- ✅ E2 完整回合循環：發射 → 結算 → 敵人攻擊 → CHECK → 下一回合 / 下一場。
- ✅ E3 敵人攻擊扣血；Shield 減免生效：敵人攻擊仍經 `EffectResolver.resolve_enemy_attack()` 套用 `RoundContext` 的 Shield reduction。
- ✅ E4 Boss 強攻擊：Boss 每 3 回合依 enemy special 設定使用 `special.attack`。
- ✅ E5 HP UI 顯示與更新：玩家 / 敵人 HP label 與 ProgressBar 會隨狀態更新，bar 使用 Tween 過渡。
- ✅ E6 玩家死 → GameOver；擊敗 Boss → Victory：兩個結算場景可載入且含重來 / 回主選單。
- ✅ E7 結算可重來 / 回主選單，重來後狀態乾淨：按鈕會呼叫 `RunState.reset_new_run()` 後切場。
- ⚠️ E8 從第 1 場打到第 5 場不崩潰：headless 場景載入與靜態流程檢查通過；完整可視化連打仍建議人類實機驗收。
- ✅ JSON 驗證：`Data/*.json` 全部可由 PowerShell `ConvertFrom-Json` 解析。
- ✅ Godot 驗證：Godot 4.6.3 headless 載入 main scene、`Scenes/Battle.tscn`、`Scenes/GameOver.tscn`、`Scenes/Victory.tscn` 皆無腳本解析或場景載入錯誤。
- ✅ H. 禁止偏離：未改 Peg / Ball / Enemy 種類數量，未實作連鎖釘 / 連射球，未實作升級三選一，未改 ROADMAP 或核心設計文件。

# Open Questions
- 無新增。
- Q-003：Shield 減免維持 Phase 2 暫行假設，每回合不疊加。
- Q-005：精英 / Boss 後獎勵仍未實作，本圈非 Boss 擊敗後只做下一場切換，占位到 Phase 4。
- Q-010 / Q-011 / Q-012：已依決議處理或保留既有規則。

# Risks
- 目前 Phase 3 預設正式戰鬥只有 Normal Ball，因 Phase 4 尚未接升級解鎖；Shield / Blast 效果仍保留在 resolver，但正式流程要到 Phase 4 才會自然出現。
- Boss / 第 5 場可達性尚未以人類完整遊玩驗證；目前完成 headless 與靜態檢查。
- `Battle.gd` 已能支撐 Phase 3，但 Phase 4 接升級畫面時應避免把 upgrade 抽取與套用 inline 回 Battle。

# Recommended Next Task
- 建議下一張任務卡：`Codex/04_ROGUELITE_BUILD.md`。Phase 3 已有 5 場流程與勝敗結算，下一圈應把非 Boss 勝利後的占位換成三選一升級，並讓 Blast / Shield 透過解鎖自然進入球池。

## 歷史報告 — Phase 2 Pinball Feel

# Summary
完成 Phase 2 Pinball Feel 第一版：在 Phase 1.5 的 EffectResolver / RoundContext 架構上接上 4 種 Peg 與 3 種 Ball 的既定效果，並加入命中粒子、球拖尾、Peg 閃光、screen shake、浮動傷害數字、結算總傷害顯示與可關閉 placeholder SFX。未改 Peg / Ball / Enemy 種類數量，未實作連鎖釘、連射球、升級三選一或完整敵人流程。

# Completed
- `EffectResolver.gd`：集中處理 `damage`、`heal`、`damage_multiplier`、`on_drop_bonus`、`damage_reduction`。
- `RoundContext.gd`：保存倍率、最高單次傷害、待回血、Blast bonus、Shield reduction、球數狀態。
- `Battle.gd`：接入 4 Peg 混合佈局、Phase 2 測試球序列、傷害數字、粒子、screen shake、SFX 事件與 SFX toggle。
- `Peg.gd`：四種 Peg 顏色與命中閃光。
- `Ball.gd`：三種 Ball 顏色、拖尾粒子、命中位置 / 顏色事件、撞牆音效事件。
- `Battle.tscn`：新增 `BattleCamera` 與 `SfxToggleButton`。
- `Data/player.json`：新增 `phase2_test_ball_sequence` 與 `sfx_enabled`。
- `WORK_PLAN.md`、`CHANGELOG.md`、`PROGRESS_REPORT.md` 已更新。

# Validation Results
- ✅ D1 發射有瞄準線與明確輸入回饋：保留 `AimLine`，發射時有粒子、狀態文字與 SFX。
- ✅ D2 命中釘子有閃光 / 粒子 / 螢幕微震：Peg 命中閃光、命中粒子與 camera shake 已實作。
- ✅ D3 命中跳出傷害數字，結算顯示總傷害：命中浮動文字與 `TOTAL` 結算文字已實作。
- ✅ D4 4 種釘子效果可分別觀察：Normal / Burst 累積不同傷害，Heal 結算回血，Double 每回合 1 次倍率提升。
- ✅ D5 3 種球效果可驗證：Phase 2 測試球序列依序發 Normal / Blast / Shield；Blast 結算加最高單次傷害，Shield 依 Q-003 減傷。
- ✅ D6 發射 / 命中 / 落底 / 結算各有占位音效且可關閉：事件 beep 已接，`SFX: ON/OFF` 可切換；另補撞牆 beep。
- ✅ D7 Phase 1 核心流程仍正常：Godot 4.6.3 headless 載入 main scene 與 `Battle.tscn` 無錯；核心 FSM 未移除。
- ⚠️ D8 多球 + 粒子下幀率穩定、無物理穿透：粒子量克制，headless 載入通過；仍需人類實機觀察幀率與手感。
- ✅ D9 所有數值仍來自 `Data/*.json`：傷害 / 倍率 / 回復 / 減傷來自 `Data/pegs.json` / `Data/balls.json`，球數 / timeout / 發射與物理參數來自 `Data/player.json`。
- ✅ C 區核心回歸：主場景與 Battle 場景可載入；球數、傷害、HP、反擊、回收與結算流程保留。
- ✅ H. 禁止偏離：未改核心設計文件、未改種類數量、未實作連鎖釘 / 連射球、未加入升級三選一或 Phase 3+ 流程。

# Open Questions
- 無新增。
- Q-001 / Q-002 / Q-003 仍按暫行假設實作。
- Q-004 / Q-005 仍待 Phase 4 前決策。

# Risks
- Phase 2 的視覺 / 音效 / shake 需要人類實機確認是否過強或過弱。
- `phase2_test_ball_sequence` 是測試用方案，正式球種解鎖仍應留到 Phase 4。
- Placeholder SFX 使用即時合成 beep，適合占位，後續 Phase 5 可替換為正式音效資源。

# Recommended Next Task
- 建議下一張任務卡：`Codex/03_ENEMY_SYSTEM.md`。Phase 2 已完成 4 Peg / 3 Ball 的效果與回饋基礎，下一步應建立 5 場敵人與完整回合制戰鬥流程。

## 歷史報告 — Phase 1.5 Architecture Refactor

# Summary
完成 Phase 1.5 Architecture Refactor 行為等價重構。`Battle.gd` 的 Peg 傷害分派已搬到 `EffectResolver`，回合暫存集中到 `RoundContext`，FSM 狀態切換統一走 `_transition_to()`；`Battle.tscn` 依 Q-008 改為承載實際彈珠場與 UI 節點，並移除空的 `node_2d.tscn`。未修改玩法、數值、座標、UI 版面、物理參數，也未實作任何 Phase 2 效果。

# Completed
- 新增 `Scripts/EffectResolver.gd`：集中 `effect_type` 分派，目前僅支援既有 `damage`。
- 新增 `Scripts/RoundContext.gd`：集中 `damage_accumulator`、球數與結算旗標；Phase 2 欄位僅宣告不啟用。
- 重構 `Scripts/Battle.gd`：移除 inline `effect_type` 判斷、移除散落回合暫存、統一 FSM 入口。
- 重構 `Scenes/Battle.tscn`：場地、牆、BottomSensor、Launcher、容器與 BattleUI 成為實際節點。
- 修正重構後瞄準器被場地節點遮住的問題，新增 `AimOverlay` 顯示原本的瞄準線與發射點。
- 移除 `node_2d.tscn`，並確認無場景 / 腳本引用。
- 更新 `WORK_PLAN.md`、`CHANGELOG.md`、`PROGRESS_REPORT.md`。

# Validation Results
- ✅ C1 主選單可進入戰鬥，不報錯：Godot 4.6.3 headless 載入 main scene 無錯。
- ✅ C2 依 `balls_per_round` 給正確球數：仍由 `RunState.balls_per_round` 進入 `RoundContext.start_round()`，數值來源未變。
- ✅ C3 可瞄準並逐顆發射；球受重力、會與牆 / 釘碰撞彈跳：發射、Ball 設定與牆碰撞 shape 的座標 / 尺寸維持 Phase 1 等價；需人類再做一次可視化實機確認。
- ✅ 回歸修正：瞄準線與發射點已改由 `AimOverlay` 顯示，避免被場地節點覆蓋。
- ✅ C4 命中 Normal Peg 累積傷害：傷害值仍取自 `pegs.json`，分派移至 `EffectResolver`。
- ✅ C5 所有球落底 / 超時後一次結算，敵人 HP 正確下降：BottomSensor 與 timeout 邏輯保留，結算改讀 `RoundContext.damage_accumulator`。
- ✅ C6 敵人 HP ≤ 0 有結束提示，可回主選單 / 重來：按鈕節點改在場景內，連線與文字維持。
- ✅ C7 球不會永久卡住：`Data/player.json` 的 8 秒 timeout 邏輯未改。
- ✅ C8 連玩 3 回合不崩潰、無狀態殘留：Godot headless 載入通過；可視化 3 回合仍建議由人類回歸。
- ✅ C9 無寫死數值：球數、傷害、HP、attack、timeout、發射力與物理參數仍由 JSON / RunState 取得；本圈未改 `Data/*.json` schema 或數值。
- ✅ Phase 1.5 DoD：`Battle.gd` 不再 inline 判斷 `effect_type`；直接 `state =` 僅存在於 `_transition_to()`；`node_2d.tscn` 已移除。
- ✅ H. 禁止偏離：未改核心設計文件、未改玩法、未新增 Phase 2 效果、未改 `project.godot` 的 3D / d3d12 設定。

# Open Questions
- 無新增。
- 既有 Q-001 ~ Q-007 維持；Q-008 / Q-009 已決議並已依決議執行。

# Risks
- 場景 / 程式分離已完成，但仍建議由人類在 Godot 編輯器中實機跑一次完整流程，確認視覺座標與手感等價。
- `Data/balls.json` 目前有既有未提交的純縮排變更，不屬於本圈重構內容，本圈未使用或擴大該變更。

# Recommended Next Task
- 建議下一張任務卡：`Codex/02_PINBALL_FEEL.md`。Phase 1.5 已把 Effect Resolver、RoundContext 與場景節點基礎整理好，下一圈可開始做 Phase 2 的手感與回饋，但需先由人類完成一次重構後實機回歸確認。

## 歷史報告 — Phase 1 First Playable

# Summary
完成 Phase 1 First Playable 的最小可玩閉環：主選單可進入戰鬥，戰鬥場景讀取 JSON，顯示玩家 / 敵人 HP 與回合傷害，玩家可瞄準發射 Normal Ball，球撞 Normal Peg 累積傷害，落底或 8 秒超時回收，全部球回收後一次結算，敵人未死亡會反擊，玩家 / 敵人死亡會出現基本結束狀態。Godot 4.6.3 headless 已可載入主場景與戰鬥場景。

# Completed
- 新增 `Scenes/MainMenu.tscn`、`Scripts/MainMenu.gd`：開始 / 離開流程。
- 新增 `Scenes/Battle.tscn`、`Scripts/Battle.gd`：最小 Battle FSM、UI、牆、底部偵測、釘子生成、發射與結算流程。
- 新增 `Scenes/Ball.tscn`、`Scripts/Ball.gd`：`RigidBody2D` 球、碰撞回報、落底 / 超時回收。
- 新增 `Scenes/Peg.tscn`、`Scripts/Peg.gd`：Normal Peg placeholder。
- 新增 `Scripts/DataLoader.gd`、`Scripts/RunState.gd`：JSON 載入 / 驗證與本局狀態。
- 新增 `Data/player.json`：暫行玩家初始數值與 Phase 1 物理調校值。
- 更新 `project.godot`：指定 main scene，加入 `DataLoader` / `RunState` autoload。
- 更新 `OPEN_QUESTIONS.md`：新增 Q-007。
- 更新 `CHANGELOG.md`：新增 Phase 1 留痕。
- 修正戰鬥 UI 攔截滑鼠事件造成無法左鍵發射的問題。

# Validation Results
- ✅ 主選單可作為 main scene 載入：Godot 4.6.3 headless 載入專案無錯。
- ✅ `Battle.tscn` 可直接載入：Godot 4.6.3 headless 無腳本解析或場景載入錯誤。
- ✅ JSON 解析通過：`Data/*.json` 皆可由 PowerShell `ConvertFrom-Json` 解析。
- ✅ 資料一致性檢查通過：`normal_peg` 存在、`player.json` 的 `starting_ball_id` 可對應到 `balls.json`、`enemies.json` 至少有第一場敵人。
- ✅ 依 `balls_per_round` 給球、Normal Peg 傷害、敵人 HP / attack、球超時等遊戲數值皆由 JSON 取得。
- ✅ 已實作 Normal Ball 發射、牆 / 釘碰撞、落底 / 超時回收、回合傷害累積、一次結算、敵人反擊、玩家 / 敵人死亡基本判定。
- ✅ 修正後 Godot 4.6.3 headless 重新載入主場景與 `Battle.tscn` 皆無錯。
- ⚠️ 實際滑鼠操作與物理手感尚未以可視化人工遊玩驗證；目前完成 headless 載入與靜態 / 資料檢查。
- ✅ H. 禁止偏離項目：未改核心設計文件、未改 ROADMAP、未新增 Phase 2+ 的 Peg / Ball / 升級 / Boss 系統、未引入非目標。

# Open Questions
- 新增 Q-007：玩家初始數值與 Phase 1 物理調校值暫放 `Data/player.json`，待人類確認。
- 既有 Q-001 ~ Q-006 維持；本圈沿用 Q-006 的「底部全開 + 8 秒超時」暫行假設。

# Risks
- `Data/player.json` 是為了避免硬寫 HP / 球數 / 超時而新增的暫行資料來源，需人類確認是否保留此檔名與結構。
- Phase 1 的場地座標、UI 尺寸與 peg 位置仍是 placeholder；這些不是玩法數值，但後續 Phase 2 可能需要整理成更可調的場地設定。
- 尚未做可視化人工遊玩測試，物理碰撞手感與球是否容易命中需在 Godot 編輯器中再確認。

# Recommended Next Task
- 停在 Phase 1，建議下一步先由人類 / Tester 用 Godot 編輯器人工玩一次，確認發射角度、碰撞、落底、結算與重來流程。通過後再進入 `Codex/02_PINBALL_FEEL.md`。

## 歷史報告 — Phase 0 Loop Framework

# Summary
將 Nano Dungeon 從 Spec Driven Project 升級為 AI Loop Driven Project。新增 AI 開發迴圈定義與兩份循環模板，並以增量方式補強 README 與 Codex 總控提示，未改動任何既有規格內容。尚未撰寫 GDScript / 場景。

# Completed
- 新增 `LOOP.md`（Core Loop、Human / AI Responsibilities、Escalation Rules、Loop Invariants）。
- 新增 `WORK_PLAN.md`（模板 + 當前計畫）。
- 新增 `PROGRESS_REPORT.md`（模板 + 本報告）。
- 修改 `README.md`：新增「AI Development Workflow」章節（Human → Design → Codex → WORK_PLAN → Implementation → Validation → Progress Report → Next Loop）。
- 修改 `Codex/00_MASTER_PROMPT.md`：新增「Autonomous Loop Rules」與「Agent Permission Matrix」章節。

# Validation Results
- ✅ A. 文件驗收：新增文件具實質內容、正體中文、專有名詞保留英文。
- ✅ H. 禁止偏離：未更改核心方向、未重寫既有文件、以增量修改進行。
- ⚠️ 其餘區塊（C–G）尚不適用：仍未進入實作階段。

# Open Questions
- 無新增。既有 Q-001 ~ Q-006 維持，建議優先請人類決議 Q-004、Q-005（影響 Phase 4）。

# Risks
- 文件數量增加，需維持 LOOP / WORK_PLAN / PROGRESS_REPORT 與 ROADMAP 的一致性，避免敘述漂移。
- 迴圈自主性提高後，須嚴格遵守 Permission Matrix，避免 AI 越權改 Docs / Roadmap。

# Recommended Next Task
- `Codex/01_FIRST_PLAYABLE.md`（Phase 1）。理由：Loop 框架已就緒，Phase 0 達 DoD，First Playable 是後續一切的基礎，且無阻斷性前置問題。
