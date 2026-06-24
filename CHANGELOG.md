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

## [Phase 14 / 1.9.2] - 2026-06-14 — 修正發射球顯示、敵人框層級、寬版 UI 與光束層級

- 執行者：Codex
- 任務卡：`Codex/14_SCENE_POLISH.md` follow-up

### Fixed
- `Battle.gd` 新增 `LauncherBallArt`，用 `assets/balls/ball_base.png` 取代舊紫色 `LauncherVisual` Polygon；集氣亮度與發射後座力改作用在新球圖上。
- `Battle.gd` 將 HUD / 敵人資料框 panel 與 border 改為負 z-index，並提高敵人 name / HP / HP bar / type / dialogue 的 z-index，避免文字與血條被框底覆蓋。
- `BattleFX.gd` 的玩家攻擊光束 / core / projectile 改掛到 UI root 並使用高 z-index，確保光線顯示在敵人框上方。
- `BattleFX.gd` 的 Turn banner、Overclock cut-in、Overkill cut-in、低血邊框與 scanline overlay 改依目前 viewport 尺寸建立，不再寫死 1024。
- `UpgradeScreen.gd` 新增 viewport-based layout，標題、三張升級卡與下一場按鈕會依 1680×1050 寬版置中放大。

### 驗收
- `Data/*.json` 解析通過。
- Godot 4.6.3 headless 載入專案、`Scenes/Battle.tscn`、`Scenes/UpgradeScreen.tscn` 通過。
- Vulkan GUI 直接載入 `Scenes/Battle.tscn` 與 `Scenes/UpgradeScreen.tscn` 通過，輸出確認 RTX 4080 SUPER / Vulkan Forward+。
- Windows Desktop Export 成功；`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。

## [Phase 14 / 1.9.1] - 2026-06-14 — 寬版 Battle 版面、敵人框修正與新球圖

- 執行者：Codex
- 任務卡：`Codex/14_SCENE_POLISH.md` follow-up

### Changed
- 視窗尺寸改為 1680×1050；Battle 彈珠場整體平移到寬版畫面中央區，HUD 留左側、敵人資料框留右側，降低 1024 方形畫面的擁擠感。
- `Data/field.json` 同步平移 field bounds / center_x；釘盤寬度、row/col spacing、釘數、半徑、bottom bumper 數值與 gameplay 規則不變。
- `Data/feel.json` 更新 HUD、SFX 按鈕、status、enemy_display 位置；敵人名字 / HP / HP bar / 類型 / 台詞都排入右側框內，避免被 portrait 或框線遮住。
- `Scenes/Battle.tscn` 同步更新牆、底部偵測、launcher、camera、初始 UI 座標，讓場景預覽與 runtime layout 一致。
- `MainMenu.gd` 改用 viewport 寬度置中 logo、標題與按鈕，適配 1680 寬版。

### Added
- 使用 `generate2dsprite` / built-in image generation 重新產出 `assets/balls/ball_base.png`：透明 PNG 能量玻璃球，與 peg 機械圓盤視覺分離；保留 runtime tint。

### 驗收
- `Data/*.json` 解析通過。
- Godot 4.6.3 headless 載入專案與 `Scenes/Battle.tscn` 通過。
- Vulkan GUI 直接載入 `Scenes/Battle.tscn` 通過，輸出確認 RTX 4080 SUPER / Vulkan Forward+。
- Windows Desktop Export 成功；export log 確認重新匯入 `ball_base.png`。
- `Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。

## [Phase 14 / 1.9.0] - 2026-06-14 — 純程序化場景 Polish 與全 UI 字體

- 執行者：Codex
- 任務卡：`Codex/14_SCENE_POLISH.md`

### Added
- 新增 `Scripts/UITheme.gd`，將 `assets/fonts/JiangChengJianRenHei.ttf` 套用到 Label / Button / ProgressBar / RichTextLabel；字體缺失時保留 Godot 預設 fallback。
- `Data/feel.json` 新增 `scene_fx`、`hud`、`enemy_display` 表現參數，集中控制釘 / 球 halo、bumper ring、HUD 面板與敵人區位置 / 浮動。

### Changed
- `Peg.gd` 在貼圖存在時仍繪製發光 halo / core 與 idle pulse；底排 `bounce_peg` 改以純程序化霓虹環、tick 與 hit pulse 顯示，未新增 Light2D。
- `Ball.gd` 在貼圖存在時補上球體 halo / core / idle pulse，拖尾強度只讀 `feel.scene_fx` 表現倍率，不改物理或速度。
- `Battle.gd` 套用 UI 字體、加入 HUD 資料面板 / 邊框 / 刻度 / 色彩分區，並將敵人 portrait 放大、HP/name 移到 portrait 下方，加入敵人區底板與 portrait idle float。
- `MainMenu.gd`、`UpgradeScreen.gd`、`GameOver.gd`、`Victory.gd` 接入共用字體 helper；主選單背景與 logo 仍正常載入並保留缺圖 fallback。

### 驗收
- `Data/*.json` 解析通過。
- Godot 4.6.3 headless 載入專案、`Scenes/Battle.tscn`、`Scenes/UpgradeScreen.tscn`、`Scenes/GameOver.tscn`、`Scenes/Victory.tscn` 通過。
- 靜態掃描 `Scripts/Scenes/Data` 無 `Light2D` / `PointLight2D` / `DirectionalLight2D`，確認未逐釘加燈。
- Windows Desktop Export 成功；`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。
- Vulkan GUI 初始化通過，並可直接載入 `Scenes/MainMenu.tscn` 後退出；輸出確認使用 NVIDIA RTX 4080 SUPER / Vulkan Forward+。
- 備註：`Scenes/MainMenu.tscn --headless --quit` 仍觸發 Godot 原生 signal 11 backtrace，未回報 GDScript 解析錯誤；Vulkan GUI 路徑已通過。

### 未解問題
- 無新增。Q-027 已依決議實作。

## [Phase 12 / 1.8.1] - 2026-06-14 — 修復釘子底圖被場地遮住

- 執行者：Codex
- 任務卡：`Codex/12_ART_CORE.md` follow-up

### Fixed
- `Peg.gd` 的 `ArtSprite` 改回前景 z 層，修正貼圖載入後 `_draw()` fallback 停用、但 Sprite 被場地底色蓋住，導致釘子在實機中消失的問題。
- `Ball.gd` 同步調整球底圖 z 層，避免球貼圖也被場地底色遮住。

### 驗收
- `Data/*.json` 解析通過。
- Godot 4.6.3 headless 載入專案與 `Scenes/Battle.tscn` 通過。
- Windows Desktop Export 已重新產出；`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。

## [環境修正提交 + 驗收] - 2026-06-14 — vulkan 修正提交、Phase 12/14 人類驗收

- 執行者：人類（驗收）+ Claude（提交 / 留痕）

### Fixed
- 提交 `project.godot` 的 `rendering_device/driver.windows="vulkan"`（先前僅在工作區未 commit）；git 版本不再是會崩潰的 d3d12。

### Changed
- 人類實機驗證 Phase 12 核心美術與 Phase 14 場景打磨，確認通過；`ROADMAP.md` 將 Phase 12 / 14 由「待開始」更新為「完成（人類實機驗證）」。

### 備註
- 美術軌道尚餘 Phase 13（升級 icon ×13）未做。重新 export 後執行檔即帶 vulkan。

## [環境修正 + Phase 14 規劃] - 2026-06-14 — vulkan 修 d3d12 崩潰 + 場景打磨任務卡

- 執行者：Claude（診斷 / 規格）+ 人類（決策）

### Fixed
- `project.godot`：`rendering_device/driver.windows` 由 `d3d12` 改為 `vulkan`，修正 GUI 啟動原生記憶體存取違規崩潰（headless 正常、d3d12 GUI 崩、vulkan GUI 正常；經 RTX 4080 SUPER 實測）。確認為 Godot 4.6.3 d3d12 後端問題，非美術 / GDScript 問題。**重新 export 後執行檔才會帶 vulkan。**

### Added
- `Codex/14_SCENE_POLISH.md`：場景視覺打磨任務卡（釘 / 球發光、底排 bumper 霓虹環、HUD 資料面板 + 字體、敵人區整合；選配場地深度 / 瞄準線）。

### Docs / 決策
- 新增並由人類決議 **Q-027**：字體採 `assets/fonts/JiangChengJianRenHei.ttf`、底排 bumper 走純程序化發光環、其餘純程序化、數值進 feel.json、不改玩法、效能優先（避免逐釘 Light2D）。
- `ROADMAP.md`：新增 Phase 14 列。

### 備註
- vulkan 修正尚未 commit；建議與 Phase 12 美術一起 review 後提交。

## [Phase 12 / 1.8.0] - 2026-06-14 — 核心美術資產與 fallback 接線

- 執行者：Codex
- 任務卡：`Codex/12_ART_CORE.md`

### Added
- 新增核心美術資產：`assets/enemies/*.png` 5 張敵人立繪、`assets/pegs/peg_base.png`、`assets/balls/ball_base.png`、`assets/bg/menu_bg.png`、`assets/bg/battle_bg.png`、`assets/ui/bar_frame.png`、`assets/ui/logo.png`。
- 新增 `assets/art_core_prompts.md`，記錄 Phase 12 風格錨點、各資產 prompt 與透明 PNG 後處理方式。
- `Battle.tscn` 的 `EnemyPortrait` 增加子 `TextureRect` 顯示敵人立繪，父 `ColorRect` 保留作為缺圖 fallback。

### Changed
- `Peg.gd` / `Ball.gd` 改為優先載入中性底圖並用既有類型色 `modulate` 上色；缺圖時仍回到原本 `_draw()` 畫圓。
- `Battle.gd` 依 `enemy_def.id` 載入 `assets/enemies/<id>.png`，戰鬥背景以低 alpha 置於最底層，HP / Enemy HP / Power / Overclock bar 增加 HUD frame。
- `MainMenu.gd` 接入低亮度背景與 logo 圖徽，標題文字仍由引擎 Label 繪製；缺圖時維持原本純色主選單 fallback。
- `WORK_PLAN.md` 更新為 Phase 12 本圈計畫。

### 驗收
- `Data/*.json` 解析通過。
- Godot 4.6.3 headless 載入專案與 `Scenes/Battle.tscn` 通過。
- Windows Desktop Export 成功；export log 確認所有 `assets/` PNG、`MainMenu` / `Battle` 場景與腳本皆已打包。
- `Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。
- 圖片 import 檢查：新 PNG import 皆為 texture，`mipmaps/generate=false`。
- 備註：人類已確認先前主選單 crash 根因為 `d3d12` 後端，並將專案改為 `vulkan`；本圈未再修改渲染設定。GUI 可視化啟動請求被取消，仍建議用可視化執行檔確認主選單背景 / logo。

### 未解問題
- 無新增。Q-026 已依決議實作；升級 icon 留待 `Codex/13_ART_UPGRADE_ICONS.md`。

## [Phase 11 / 1.7.0] - 2026-06-13 — 斬殺強制清除、玩家攻擊演繹與一般釘彈跳 boost

- 執行者：Codex
- 任務卡：`Codex/11_PLAYER_ATTACK_AND_BOUNCE.md`

### Added
- `Battle.gd` 新增達標斬殺流程：命中後若本回合累積傷害達敵人目前 HP 加 `execute.margin`，立即停止發射、回收場上球、強制敵 HP 歸零並進既有 CHECK → REWARD / VICTORY。
- `BattleFX.gd` 新增純程序化 OVERKILL cut-in：全螢幕 flash、大字 Tween、Camera punch、shake 與粒子。
- `BattleFX.gd` 新增玩家攻擊演繹：匯聚粒子、Line2D 光束、程序化能量核心、命中粒子與 SFX，強度依本次傷害放大，Overclock 中改用金色調。

### Changed
- `Battle.gd` 在正常 SETTLE 與斬殺提前結算時都先播放玩家攻擊演繹，再接 settlement count-up、敵人受擊 flash / shake 與浮動文字。
- `Ball.gd` 對一般動態釘命中套用 `peg_bounce_boost`，並以 `max_ball_speed` 夾住；底排 `bounce_peg` 仍只走自己的 bumper 倍率，不疊加一般 boost。
- `DataLoader.gd` 驗證 Phase 11 新增的 player / feel 參數與基本範圍。
- `WORK_PLAN.md` 更新為 Phase 11 本圈計畫。

### Data
- `Data/player.json` 新增 `execute.enabled` / `execute.margin`、`peg_bounce_boost = 1.15`、`max_ball_speed = 1600.0`。
- `Data/feel.json` 新增 `overkill_cutin` 與 `player_attack` 區段，集中 cut-in、光束、能量核心、粒子、shake 與 SFX pitch 參數。

### 驗收
- `Data/*.json` 解析通過。
- `Scripts/Scenes/Data` 禁用字詞掃描通過。
- Godot 4.6.3 headless 載入專案與 `Scenes/Battle.tscn` 通過。
- Windows Desktop Export 成功；`Data/player.json` / `Data/feel.json` / 新腳本已打包，`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。

### 未解問題
- 無新增。Q-023 / Q-024 / Q-025 已依決議實作。

## [Phase 10 / 1.6.0] - 2026-06-13 — 過載模式 Overclock：張力槽、天井觸發與爆發回合

- 執行者：Codex
- 任務卡：`Codex/10_OVERLOAD_MODE.md`

### Added
- 新增 `Data/overload.json`，集中控制過載開關、命中充能、`trigger_threshold = 100`、`pity_rounds = 3`、持續回合、重抽權重倍率、傷害倍率與程序化演出參數。
- `RunState.gd` 新增整局過載槽、未觸發回合計數、剩餘過載回合；重新開始會歸零。
- `Scenes/Battle.tscn` 新增 Overclock gauge UI，顯示充能百分比、升壓 / 臨界 / 啟動狀態。
- `BattleFX.gd` 新增純程序化過載演出：gauge 脈動、場地邊框升壓、臨界抖動、全螢幕 flash、OVERCLOCK cut-in、Camera zoom punch、金色 overlay、scanline、命中粒子 / 浮動文字強化與退場淡出。

### Changed
- `Battle.gd` 在命中 peg 時依 `overload.json.charge_per_hit` 累積能量；`double_peg` 預設加最多，達 100 立即啟動。
- `Battle.gd` 於 ROUND_START 檢查 3 回合未觸發天井，強制啟動後再重抽，讓該回合直接套用高價值權重。
- `FieldGenerator.gd` 支援重抽權重覆寫；過載中 `burst_peg` / `double_peg` 權重依 JSON 倍率提高，既有保底 `double_peg` 機制保留。
- `EffectResolver.gd` 支援傳入全域傷害倍率；過載中只在既有傷害公式外乘 `overload_damage_multiplier`，未改 base 傷害資料。
- 將內部格位命名由 `slot` 改為 `cell`，避開本卡禁用語境歧義。

### Data
- `Data/pegs.json` 清掉既有非賽博化描述文字，改為中性的節點陣列描述；未改 peg 數值或效果。

### 驗收
- `Data/*.json` 解析通過。
- `Scripts/Scenes/Data` 禁用字詞掃描通過。
- Godot 4.6.3 headless 載入專案與 `Scenes/Battle.tscn` 通過。
- Windows Desktop Export 成功；`Data/overload.json` 已打包，`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。

### 未解問題
- 無新增。Q-022 已依決議實作。

## [Phase 9 / 1.5.0] - 2026-06-13 — Game Feel 轉場、回合節奏與反饋打磨

- 執行者：Codex
- 任務卡：`Codex/09_GAME_FEEL.md`

### Added
- 新增 `Scripts/SceneTransition.gd` autoload，MainMenu / Battle / UpgradeScreen / GameOver / Victory 切場改走共用淡入淡出。
- `BattleFX.gd` 新增回合提示橫幅、Boss 必殺 telegraph、低血紅色邊緣脈動、玩家受擊 flash、敵人受擊閃白 / 抖動、結算 count-up / HP drain、combo 文字與升階粒子、漏球提示、發射後座力與重組快閃。
- `Ball.gd` 追蹤單顆球命中次數並傳給 BattleFX 作 combo 表現；回收時用命中數判斷 miss 提示。
- `Peg.gd` 新增每回合重組用的輕量快閃 / 縮放回饋。
- `UpgradeScreen.gd` 新增升級卡 hover 放大與選定 pulse。

### Changed
- `Battle.gd` 在 SETTLE → ENEMY_TURN → CHECK → ROUND_START 之間加入資料化 beat，敵人攻擊改成預兆 / 衝擊 / 收手三拍。
- 發射集氣期間 power bar / launcher 視覺漸強，發射瞬間有 launcher recoil；SFX 關閉時所有流程仍正常。
- 所有場景切換按鈕與流程切場改用 `SceneTransition.change_scene()`。

### Data
- `Data/feel.json` 新增 `transitions`、`turn_pacing`、`enemy_attack`、`combo`、`telegraph`、`low_hp`、`charge`、`drain`、`reroll_flash`、`upgrade_card`、`settlement` 區段；未改傷害 / HP / 敵人 / 抽取等平衡資料。
- `DataLoader.gd` 驗證新增 feel 區段。

### 驗收
- `Data/*.json` 解析通過。
- Godot 4.6.3 headless 載入專案、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` 通過。
- Windows Desktop Export 成功；`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。

### 未解問題
- 無新增。Q-021 已依決議實作。

## [Phase 8 / 1.4.1] - 2026-06-13 — 鎖定集氣角度並縮短拋物線提示

- 執行者：Codex
- 任務卡：`Codex/08_LAUNCH_AND_TUNING.md` 後續手感修正

### Changed
- 集氣開始時鎖定發射方向；集氣中滑鼠移動不再改變拋物線弧度或實際發射方向。
- power 只影響球的發射初速，不再影響拋物線提示線形狀。
- `Data/feel.json` 將 `aim_preview` 採樣縮短到約原本五分之一，只保留短提示線，讓玩家靠練習掌握落點。

### 驗收
- `Data/*.json` 解析通過。
- Godot 4.6.3 headless 載入 `Battle.tscn` 通過。

## [Phase 8 / 1.4.0] - 2026-06-13 — 集氣發射、底排 bumper 與保底倍傷釘

- 執行者：Codex
- 任務卡：`Codex/08_LAUNCH_AND_TUNING.md`

### Added
- `Battle.gd` 新增兩段式集氣發射：AIMING 狀態下左鍵 / 空白鍵第一下開始集氣、第二下依當前 power 發射；球飛行中輸入無效。
- `Battle.tscn` 新增 `PowerLabel` / `PowerBar`，power 在 0→100→0 之間來回擺動。
- `AimLine` 改為依目前 power、發射方向、重力與 `feel.json` 採樣設定繪製拋物線預覽。
- `upgrades.json` 新增 `up_guaranteed_double`，讓每回合保底 `double_peg` 數量 +1。

### Changed
- `Ball.gd` 對底排 `bounce_peg` 命中套用主動 bumper：速度依 `field.json` 的 `bottom_row.bounce_multiplier` 放大，並以 `max_ball_speed` 夾住；CCD 保留。
- `FieldGenerator.gd` 在每回合重抽類型時先保留 `RunState.guaranteed_double_peg_count` 個槽位為 `double_peg`，其餘槽位仍照 `type_weights` 抽取。
- `RunState.gd` 新增整局 `guaranteed_double_peg_count` / 上限，重新開始時回到 `field.json` 預設。
- `UpgradeResolver.gd` 支援 `guaranteed_double_peg` stat 升級，並在達上限時排除。
- `DataLoader.gd` 驗證新的 player / feel / field / upgrade stat 欄位。

### Data
- `Data/player.json` 新增 `launch_speed_min`、`launch_speed_max`、`charge_cycle_seconds`。
- `Data/feel.json` 新增 `aim_preview.point_count` / `time_step`。
- `Data/field.json` 新增 `bottom_row.bounce_multiplier`、`bottom_row.max_ball_speed`、`generator.guaranteed_double_peg_count`、`generator.max_guaranteed_double_peg_count`。
- `Data/upgrades.json` 的 `_meta.stat_targets` 新增 `guaranteed_double_peg`。

### 驗收
- `Data/*.json` 解析通過。
- Godot 4.6.3 headless 載入 main scene、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` 通過。
- Windows Desktop Export 成功，匯出 exe 可 `--headless --quit` 獨立啟動。

### 未解問題
- 無新增。Q-018 / Q-019 / Q-020 皆依已決議內容實作。

## [Phase 7 / 1.3.0] - 2026-06-13 — 程序生成釘盤與每回合類型重抽

- 執行者：Codex
- 任務卡：`Codex/07_PROCEDURAL_PEGBOARD.md`

### Added
- 新增 `Scripts/FieldGenerator.gd`，由 `Data/field.json` 的 generator 參數計算交錯梅花樁骨架、底排座標，並依權重抽動態 peg 類型。
- `Data/pegs.json` 新增 `bounce_peg`（`effect_type: none`），僅用於底部固定反彈排。

### Changed
- `Data/field.json` 改為參數化 `generator + bottom_row`，取代手列座標。
- `Battle.gd` 於 ROUND_START 重抽動態 peg 類型；位置骨架整局固定，底排 `bounce_peg` 不參與重抽。
- `DataLoader.gd` 改驗證 generator / bottom_row schema、權重 id、bounds、radius 與 bounce 底排規則。
- `EffectResolver.gd` 明確支援 `effect_type: none`，回傳無傷害 / 無回血 / 無倍率結果。
- `project.godot` 與 `Scenes/Battle.tscn` 調整為 1024×1024 場地高度；牆、field border、BottomSensor、BattleCamera、底部狀態 UI 已同步。

### 驗收
- Godot 4.6.3 headless 載入 main scene、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` 通過。
- `Data/*.json` 解析通過。
- Windows Desktop Export 成功，匯出 log 確認 `Data/field.json` 與 `Scripts/FieldGenerator.gd` 打包；匯出 exe 可 `--headless --quit` 獨立啟動。

### 未解問題
- 無新增。Q-015 / Q-016 / Q-017 皆依已決議內容實作；不做漸變特效、不擾動位置骨架、不新增其他種類。

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

## [Phase 12-13 規劃 / spec] - 2026-06-13 — 美術 Pass 決策 + 任務卡（核心美術 + 升級 icon）

- 執行者：Claude（規格 / 任務卡作者）+ 人類（決策）
- 任務卡：`Codex/12_ART_CORE.md`、`Codex/13_ART_UPGRADE_ICONS.md`（待 Codex 實作）

### Changed
- 人類實機驗證 Phase 11 通過；`ROADMAP.md` 標記 Phase 11 完成、新增 Phase 12 / 13 列。

### Added
- `Codex/12_ART_CORE.md`：核心美術（5 敵人立繪、釘/球單張中性底圖 + 程式上色、主選單 / 戰鬥背景、logo 圖徽、HP/過載/power 外框）+ 接線 + fallback，含現成 prompts 與風格錨點。
- `Codex/13_ART_UPGRADE_ICONS.md`：13 個升級 icon（依 id）+ 卡片接線 + fallback，含 prompt 清單。

### Docs / 決策
- 新增並由人類決議 **Q-026**：採 `agent-sprite-forge`（Codex 內建生圖 GPT IMAGE-2，僅靜態立繪 / icon、不用動畫 / 地圖）；釘 / 球採「單張中性底圖 + 程式 modulate 上色」保留所有特效；全範圍 UI 補圖；**程序化 / 空白 fallback 全保留、背景需低對比不蓋過釘海**；核心與升級 icon 拆兩卡分 session 跑。

### 備註
- 本筆為規格 / 任務卡層異動，未撰寫實作。美術為視覺項，實作後須人類實機驗收（風格一致性、背景對比、fallback）。

## [Phase 11 規劃 / spec] - 2026-06-13 — 斬殺 / 玩家攻擊演繹 / 彈跳手感 決策 + 任務卡

- 執行者：Claude（規格 / 任務卡作者）+ 人類（決策）
- 任務卡：`Codex/11_PLAYER_ATTACK_AND_BOUNCE.md`（待 Codex 實作）

### Changed
- 人類實機驗證 Phase 10 過載模式通過；`ROADMAP.md` 標記 Phase 10 完成、新增 Phase 11 列。

### Added
- `Codex/11_PLAYER_ATTACK_AND_BOUNCE.md`：三項任務卡——回合內達標即斬殺（OVERKILL）、玩家造成傷害的攻擊演繹（純程序化光束/能量彈）、釘子彈跳手感參數化（`peg_bounce_boost`）。

### Docs / 決策
- 新增並由人類決議 **Q-023**（斬殺，累積傷害≥敵HP即強制清除、可開關、賽博 cut-in）、**Q-024**（玩家攻擊演繹，匯聚→射出→命中，強度隨傷害、純程序化）、**Q-025**（peg_bounce_boost 一般釘反彈加乘、含上限、底排 bumper 不變）。

### 備註
- 本筆為規格 / 任務卡層異動，未撰寫實作。三項皆體感項，實作後須人類實機驗收。

## [Phase 10 規劃 / spec] - 2026-06-13 — 過載模式 Overclock 決策 + 任務卡

- 執行者：Claude（規格 / 任務卡作者）+ 人類（決策）
- 任務卡：`Codex/10_OVERLOAD_MODE.md`（待 Codex 實作）

### Changed
- 人類實機驗證 Phase 9 通過；`ROADMAP.md` 標記 Phase 9 完成、新增 Phase 10 列。

### Added
- `Codex/10_OVERLOAD_MODE.md`：過載模式任務卡（過載槽 UI、命中累積、3 回合天井保底、升壓/臨界/觸發三階段演出、過載期間高價值權重 + 傷害倍率、純程序化爆發效果、全參數放 `Data/overload.json`）。

### Docs / 決策
- 新增並由人類決議 **Q-022**：借柏青哥「張力→爆發」情緒結構，但**賽博化用詞、純程序化效果（不依賴外部美術）、限定回合 + 天井保底、全參數化**；明確不做拉霸、不用柏青術語。

### 備註
- 本筆為規格 / 任務卡層異動，未撰寫實作。爽度為體感項，實作後須人類實機驗收。

## [Phase 9 規劃 / spec] - 2026-06-13 — Game Feel 打磨決策 + 任務卡

- 執行者：Claude（規格 / 任務卡作者）+ 人類（決策）
- 任務卡：`Codex/09_GAME_FEEL.md`（待 Codex 實作）

### Changed
- 人類實機驗證 Phase 8 通過；`ROADMAP.md` 標記 Phase 8 完成、新增 Phase 9 列（美術 Pass 排於其後）。

### Added
- `Codex/09_GAME_FEEL.md`：純表現層打磨任務卡（轉場柔化、回合 beats、敵人攻擊三拍、受擊/結算反饋、回合橫幅 + A 連擊升階、B Boss 必殺預兆、C 低血警示、D 漏球反饋、E 集氣手感、F 升級卡 juice、G 釘盤重組輕量閃光）。

### Docs / 決策
- 新增並由人類決議 **Q-021**（Game Feel 打磨範圍，全部純表現、參數進 feel.json、不改玩法）。G 項即 Phase 7 緩做的漸變特效，現以「輕量閃光版」納入。

### 備註
- 本筆為規格 / 任務卡層異動，未撰寫實作。Phase 9 為體感項，實作後須人類實機驗收。

## [Phase 8 規劃 / spec] - 2026-06-13 — 集氣發射 / 底排 bumper / 保底倍傷釘 決策 + 任務卡

- 執行者：Claude（規格 / 任務卡作者）+ 人類（決策）
- 任務卡：`Codex/08_LAUNCH_AND_TUNING.md`（待 Codex 實作）

### Changed
- 人類實機驗證 Phase 7 程序生成釘盤通過；`ROADMAP.md` 標記 Phase 7 完成、新增 Phase 8 列。

### Added
- `Codex/08_LAUNCH_AND_TUNING.md`：三項可玩性強化任務卡。

### Docs / 決策
- 新增並由人類決議：**Q-018**（底排 bounce_peg 改主動 bumper，反彈速度×可調倍率預設 2.0、含速度上限）、**Q-019**（集氣發射 0→100→0 + 拋物線瞄準預覽、左鍵或空白鍵兩段式、power→初速）、**Q-020**（double_peg 每回合保底 2 顆 + 新增升級保底數 +1）。

### 備註
- 本筆為規格 / 任務卡層異動，未撰寫實作。Phase 8 屬手感 / 平衡敏感改動，實作後須人類實機驗收。

## [Phase 7 規劃 / spec] - 2026-06-13 — 程序生成釘盤決策定案 + 任務卡

- 執行者：Claude（規格 / 任務卡作者）+ 人類（決策）
- 任務卡：`Codex/07_PROCEDURAL_PEGBOARD.md`（待 Codex 實作）

### Added
- `Codex/07_PROCEDURAL_PEGBOARD.md`：程序生成釘盤任務卡（參數化 field.json、FieldGenerator、每回合重抽類型、bounce_peg 底排、場地 1024×1024）。

### Docs / 決策
- 新增並由人類決議：**Q-015**（程序生成 + 每回合只重抽類型、位置骨架固定）、**Q-016**（新增第 5 種 `bounce_peg`，僅底排）、**Q-017**（場地拉高 1024×1024）。
- `Docs/02_GAME_DESIGN.md`：Peg 系統由 4 → 5 種（新增 Bounce Peg），補記 Phase 7 程序生成 / 每回合重組規則。
- `Codex/VALIDATION_CHECKLIST.md`：H 區「維持 4 種 Peg」更新為「MVP 4 種；Phase 7 起含 bounce_peg 共 5 種」。
- `ROADMAP.md`：新增 Phase 7 列與 MVP 後增量軌道說明。

### 備註
- 本筆為規格 / 任務卡層異動，未撰寫實作；不做漸變特效（人類本輪未選）。Phase 7 為手感/平衡敏感改動，實作後須人類實機驗收。

## [Phase 6 / 1.2.0] - 2026-06-13 — 柏青哥釘盤佈局（密集釘海）

- 執行者：Claude（依人類請求改造關卡）
- 任務卡：`Codex/06_FIELD_LAYOUT.md`（佈局資料調整）

### Data
- `Data/field.json`：改為柏青哥釘盤風格的交錯梅花樁，位置以格點公式算出（寬排 5 顆 / 窄排 4 顆交錯，6 排共 27 顆）。
  - 組成：Normal ×20、Heal ×5、Burst ×1、Double ×1（高價值釘大幅減少）。
  - 全部釘子縮小碰撞半徑：default 9；Burst 8、Double 7（最小最難打）。
  - 兩側留空檔，增加漏球風險與亂彈刺激感。
- `Data/pegs.json`：配合密集釘海下調單顆數值——Normal `base_damage` 3→1、Heal `effect_value` 3→2。

### 備註
- 僅調 `field.json` / `pegs.json` 數值，未改程式 / 規則。
- 此為較大幅的手感與平衡改動，**務必人類實機驗收**：確認整局輸出、Boss 可達性、是否漏球過多。可再微調這兩個檔。

## [Phase 6 / 1.1.0] - 2026-06-13 — 策略性關卡重做（field.json 調整）

- 執行者：Claude（依人類請求改造關卡）
- 任務卡：`Codex/06_FIELD_LAYOUT.md`（佈局資料化完成後的數值調整）

### Data
- `Data/field.json`：重做 8 顆釘子佈局，建立「左安全 / 右高風險高回報」策略軸。
  - 維持原 2/2/2/2 類型組成（保留 Phase 4 已驗收的平衡預算）。
  - 左側 Heal/Normal 放大顆（r19–22，保底易打）；右側 Burst/Double 放小顆（r10–13，需精準角度）；中央頂部 Normal 大顆當分流器。
  - 用半徑編碼風險：高價值釘最小、最難打。

### 備註
- 僅調 `field.json` 數值，未改任何程式 / 規則。為純資料佈局調整。
- 因可達性改變（高價值釘變小變難），整體難度可能略升，建議人類實機比較後，必要時微調 `field.json` 或 `enemies.json`。

## [Phase 6 / 1.0.2] - 2026-06-13 — 完成 Field Layout 佈局資料化

- 執行者：Codex
- 任務卡：`Codex/06_FIELD_LAYOUT.md`
- Commit：`a0702f1 Data-drive field layout`

### Added
- `Data/field.json`：釘子 `id / x / y / radius` 資料化（初版沿用原 8 顆座標，半徑 18，行為等價）。

### Changed
- `DataLoader.gd`：載入並驗證 `field.json`（id 存在、座標在 bounds 內、radius>0），提供 `get_field_config()`。
- `Battle.gd`：`_spawn_pegs()` 改讀 `field.json`，移除寫死 `peg_slots`。
- `Peg.gd`：`configure()` 接收 per-peg radius，並各自 `CircleShape2D.new()`，解除共用 sub-resource 連動。

### 已知事項
- 暫時 smoke test（直接建兩顆 Peg 驗證不同半徑）曾觸發 Godot headless engine crash；產品 `Battle.tscn` 載入正常，測試檔已刪除未納入 commit。

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
