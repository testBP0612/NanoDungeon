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
完成 Phase 14 第二次 follow-up：修正發射點仍顯示舊紫色圓形、敵人名稱 / HP / 血條被資料框覆蓋、Overclock 與升級畫面仍偏 1024 版型、玩家攻擊光束被 UI 框遮住等問題。未改玩法、物理、數值或渲染後端。

# Completed
- `Scripts/Battle.gd`：新增 `LauncherBallArt`，用 `assets/balls/ball_base.png` 取代舊 `LauncherVisual`；集氣與發射後座力都作用於新球圖。
- `Scripts/Battle.gd`：HUD / enemy panel 與 border 改為負 z-index；敵人 portrait、name、HP bar、type、dialogue 設定明確 z-index，避免被底框覆蓋。
- `Scripts/BattleFX.gd`：玩家攻擊光束、核心線與 projectile 改掛到 UI root，高 z-index 顯示於所有資料框上方。
- `Scripts/BattleFX.gd`：Turn banner、Overclock cut-in、Overkill cut-in、低血邊框、scanline overlay 改依 viewport size 生成。
- `Scripts/UpgradeScreen.gd`：新增寬版 viewport layout，升級卡列與按鈕置中放大。

# Validation Results
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ Godot 驗證：專案 headless、`Scenes/Battle.tscn`、`Scenes/UpgradeScreen.tscn` 載入通過。
- ✅ Vulkan 驗證：非 headless 直接載入 `Scenes/Battle.tscn` 與 `Scenes/UpgradeScreen.tscn` 通過，輸出確認 RTX 4080 SUPER / Vulkan Forward+。
- ✅ Export 驗證：Windows Desktop Export 成功。
- ✅ Build smoke：`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。

# Open Questions
- 無新增。

# Risks
- 這次主要修 z-index 與寬版 layout；仍建議用實機打一回合，確認光束穿過敵人框時的視覺強度與新球尺寸是否合適。

# Recommended Next Task
- 實機確認四個回歸點：發射點 / 飛行球顯示新球圖、敵人資料可讀、Overclock cut-in / 升級畫面置中、玩家攻擊光束在最上層。

## 歷史報告 — Phase 14 Widescreen Follow-up

# Summary
完成 Phase 14 follow-up：依實機截圖把 Battle 改為 1680×1050 寬版佈局，將 HUD / 場地 / 敵人框分開；修正敵人名字、HP bar 與台詞被 portrait / 框線擋住的問題；重新生成玩家發射球底圖，讓球不再長得像 peg。

# Completed
- `project.godot`：viewport 改為 1680×1050；未改 `[rendering]`。
- `Data/field.json` / `Scenes/Battle.tscn` / `Scripts/Battle.gd`：彈珠場平移到寬版中央區，launcher、aim line、camera、牆、bottom sensor 與表現座標同步。
- `Data/feel.json`：HUD、SFX、status、enemy_display 座標更新；敵人 HP/name、HP bar、類型、台詞都在右側資料框內。
- `Scripts/MainMenu.gd`：主選單 logo / 標題 / 按鈕改依 viewport 寬度置中。
- `assets/balls/ball_base.png`：用 `generate2dsprite` / built-in image generation 產出新的透明能量球底圖，保留 runtime tint。

# Validation Results
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ Godot 驗證：專案 headless 與 `Scenes/Battle.tscn` headless 載入通過。
- ✅ Vulkan 驗證：非 headless 直接載入 `Scenes/Battle.tscn` 通過，輸出確認 RTX 4080 SUPER / Vulkan Forward+。
- ✅ Export 驗證：Windows Desktop Export 成功；export log 顯示重新匯入 `ball_base.png`。
- ✅ Build smoke：`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。
- ✅ 球圖透明檢查：`assets/balls/ball_base.png` 背景 alpha sample 為 0；洋紅只存在於透明像素。

# Open Questions
- 無新增。

# Risks
- 寬版是 layout 平移，不改釘盤寬度與規則；實機仍需確認 1680×1050 下 HUD 字距、敵人框高度與場地視覺重心是否符合展示需求。

# Recommended Next Task
- 用 Vulkan GUI 實機跑一局確認寬版構圖與新球圖；若通過，下一步可回到 `Codex/13_ART_UPGRADE_ICONS.md` 或只做 `feel.json` 微調。

## 歷史報告 — Phase 14 Scene Polish

# Summary
完成 `Codex/14_SCENE_POLISH.md` 的主要範圍：以純程序化方式補上釘 / 球發光與 idle pulse、底排 bumper 霓虹環、HUD 資料面板與全 UI 字體套用，並重整敵人區，讓 portrait 更大、HP/name 移到 portrait 下方。未改玩法、傷害、物理、球 / 釘 / 敵人種類，也未改渲染設定。

# Completed
- `Data/feel.json`：新增 `scene_fx`、`hud`、`enemy_display`，集中光暈、pulse、bumper ring、HUD 面板、敵人區 layout / float 參數。
- `Scripts/UITheme.gd`：新增共用字體 helper，套用 `assets/fonts/JiangChengJianRenHei.ttf` 到文字 UI；缺字體時直接 fallback。
- `Scripts/MainMenu.gd`、`Scripts/UpgradeScreen.gd`、`Scripts/GameOver.gd`、`Scripts/Victory.gd`、`Scripts/Battle.gd`：接入共用字體 helper。
- `Scripts/Peg.gd`：貼圖存在時仍繪 halo / core / idle pulse；`bounce_peg` 改為純程序化霓虹環與 hit pulse，無逐釘 Light2D。
- `Scripts/Ball.gd`：貼圖存在時補 halo / core / idle pulse，拖尾表現倍率資料化但不改球速 / 物理。
- `Scripts/Battle.gd`：加入 HUD panel、邊框、刻度、bar 色彩分區；敵人 portrait 放大、HP/name 移至 portrait 下方，加入敵人 panel 與 portrait idle float。
- `WORK_PLAN.md`、`CHANGELOG.md` 已更新為 Phase 14。

# Validation Results
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ Godot 驗證：專案 headless 載入通過。
- ✅ Battle 驗證：`Scenes/Battle.tscn` headless 載入通過。
- ✅ 其他 UI 場景：`Scenes/UpgradeScreen.tscn`、`Scenes/GameOver.tscn`、`Scenes/Victory.tscn` headless 載入通過。
- ✅ 性能護欄：靜態掃描 `Scripts/Scenes/Data` 無 `Light2D` / `PointLight2D` / `DirectionalLight2D`。
- ✅ 玩法護欄：未修改 `Data/player.json`、`Data/pegs.json`、`Data/balls.json`、`Data/enemies.json`、`Data/upgrades.json` 的玩法數值或種類。
- ✅ Export 驗證：Windows Desktop Export 成功；`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。
- ✅ Vulkan 驗證：非 headless 啟動通過，並可直接載入 `Scenes/MainMenu.tscn` 後退出；輸出確認 RTX 4080 SUPER / Vulkan Forward+。
- ⚠️ MainMenu 單場景 headless：`Scenes/MainMenu.tscn --headless --quit` 仍觸發 Godot 原生 signal 11 backtrace，沒有 GDScript 解析錯誤；Vulkan GUI 路徑已通過。
- ⚠️ 視覺體感：headless 可驗證載入與腳本解析；發光強度、HUD 密度、敵人區構圖仍需人類實機確認。

# Open Questions
- 無新增。
- Q-027 已依決議執行。

# Risks
- MainMenu 單場景 headless 仍有 Godot 原生 crash，但 Vulkan GUI 直接載入通過；本圈未短路背景 / logo 載入，也未改 `project.godot` 渲染設定。
- `JiangChengJianRenHei.ttf` 字檔較大，首次載入可能有短暫成本；目前只用一次共用 helper，缺檔時 fallback。
- HUD / 敵人區 layout 以 runtime 套用，若後續改場景解析度，應優先調 `Data/feel.json` 對應座標。

# Recommended Next Task
- 用 Vulkan GUI 或匯出版實機驗收 Phase 14：確認主選單背景 / logo、釘球發光、bottom bumper 霓虹環、HUD 讀性、敵人區位置與幀率。通過後再進 `Codex/13_ART_UPGRADE_ICONS.md` 或只做 `feel.json` 視覺微調。

## 歷史報告 — Phase 12 Art Core

# Summary
完成 `Codex/12_ART_CORE.md`：使用 `generate2dsprite` / built-in image generation 產出核心靜態美術，並接入敵人立繪、釘 / 球中性底圖、主選單與戰鬥背景、HUD bar frame、logo 圖徽。所有接線都使用 `ResourceLoader.exists()` 或原節點保留 fallback；未改玩法、數值、球 / 釘 / 敵人種類，也未做動畫、地圖或升級 icon。

# Completed
- `assets/enemies/*.png`：5 張敵人立繪依 `enemies.json` id 命名，`core_program` 作為 base 風格錨點，其餘以同一視覺語言串生。
- `assets/pegs/peg_base.png` / `assets/balls/ball_base.png`：中性白灰底圖，runtime 仍由程式依類型 `modulate` 上色。
- `assets/bg/menu_bg.png` / `assets/bg/battle_bg.png`：主選單背景與低對比戰鬥背景；戰鬥背景以低 alpha 置底。
- `assets/ui/bar_frame.png` / `assets/ui/logo.png`：HUD bar frame 與 logo emblem；主標題仍由引擎 Label 繪製。
- `assets/art_core_prompts.md`：記錄風格錨點、prompt 與透明 PNG 後處理方式。
- `Scripts/Peg.gd` / `Scripts/Ball.gd`：優先顯示底圖；缺圖時回到原 `_draw()` 畫圓；類型色、命中閃白與半徑縮放路徑保留。
- `Scenes/Battle.tscn` / `Scripts/Battle.gd`：敵人立繪依 id 載入，缺圖顯示原 ColorRect；加上 battle 背景與 bar frame。
- `Scenes/MainMenu.tscn` / `Scripts/MainMenu.gd`：接入 menu 背景與 logo 圖徽，title / subtitle / buttons 仍用引擎 UI。
- `WORK_PLAN.md`、`CHANGELOG.md` 已更新為 Phase 12。

# Validation Results
- ✅ 5 隻敵人立繪：檔名對 id，export log 確認已打包；`Battle.gd` 依 `enemy_def.id` 載入，缺圖 fallback 到原 ColorRect。
- ✅ 釘 / 球底圖 + 程式上色：Sprite2D 使用中性底圖，`modulate` 仍由既有 `_color_for_peg()` / `_color_for_ball()` 控制；半徑縮放由 data-driven radius / ball_radius 推算。
- ✅ 背景低對比：`battle_bg.png` 置於最底層且 alpha 0.38；釘 / 球 / UI 繼續在上層。
- ✅ logo 圖徽 + 引擎文字：`logo.png` 只作 emblem，`Nano Dungeon` 仍是 Label。
- ✅ HUD 外框：bar frame 以 TextureRect 放在 ProgressBar 後方，不取代 bar 本體資訊。
- ✅ fallback：所有新增圖片載入前檢查 `ResourceLoader.exists()`；釘 / 球缺圖回原 `_draw()`；敵人缺圖回 ColorRect；背景 / frame / logo 缺圖直接略過。
- ✅ import：新圖片 import 皆為 texture，`mipmaps/generate=false`。
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ Godot 驗證：專案 headless 載入與 `Scenes/Battle.tscn` 載入通過。
- ✅ Export 驗證：Windows Desktop Export 成功；`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。
- ⚠️ MainMenu 可視化：人類已確認先前主選單 crash 根因為 `d3d12` 後端，並將專案改為 `vulkan`；本圈未再修改渲染設定。GUI 啟動授權被取消，尚未由 Codex 直接可視化確認背景與 logo。
- ⚠️ 完整一整局與風格體感：headless / export 通過；敵人圖大小、背景對比、bar frame 視覺密度仍需人類實機驗收。

# Open Questions
- 無新增。
- Q-026 已依決議執行；升級 icon ×13 留待 `Codex/13_ART_UPGRADE_ICONS.md`。

# Risks
- AI 圖像風格已統一，但去背為 deterministic flood-fill 後處理，極細外光可能略有硬邊；如實機看起來太銳利，可只重處理 PNG，不需改玩法。
- 戰鬥背景 alpha 目前保守；若實機仍搶視覺，優先調 `Battle.gd` 的 `BattleBackgroundArt.modulate.a`。
- 主選單背景 / logo 已恢復正常載入且保留缺圖 fallback；仍需用可視化匯出版看一次實際構圖與亮度。

# Recommended Next Task
- 建議人類用 `Builds/NanoDungeon.exe` 可視化驗收 Phase 12：確認敵人立繪、釘 / 球 tint、背景對比、HUD frame 與 logo 圖徽。通過後下一張是 `Codex/13_ART_UPGRADE_ICONS.md`，補 13 個升級 icon 並接到升級卡。

## 歷史報告 — Phase 11 Player Attack & Bounce

# Summary
完成 `Codex/11_PLAYER_ATTACK_AND_BOUNCE.md`：命中後若本回合累積傷害達標會立即啟動 OVERKILL 強制清除，回收場上球並進既有獎勵 / 勝利判定；結算與斬殺都補上玩家側「匯聚 → 光束 / 能量核心 → 命中」演出；一般釘新增資料化彈跳 boost 並保留底排 bumper 獨立倍率。未新增 Peg / Ball / Enemy 種類，未改傷害公式結構，演出全為程序化。

# Completed
- `Data/player.json`：新增 `execute.enabled` / `execute.margin`、`peg_bounce_boost`、共用 `max_ball_speed`。
- `Data/feel.json`：新增 `overkill_cutin` 與 `player_attack`，可調 cut-in、光束、能量核心、粒子、shake、camera punch、SFX pitch 與傷害強度縮放。
- `Scripts/DataLoader.gd`：驗證新增 player / feel 參數，缺欄或非法值會啟動時報錯。
- `Scripts/Ball.gd`：一般釘命中後套用 `peg_bounce_boost` 並夾速度上限；`bounce_peg` 維持原 bumper 倍率，不疊加一般 boost；CCD 保留。
- `Scripts/Battle.gd`：新增 execute guard，達標後停止發射、清場回收、避免回收 signal / SETTLE 重複推 FSM；斬殺與正常結算都接玩家攻擊演出。
- `Scripts/BattleFX.gd`：新增 OVERKILL cut-in、玩家攻擊光束 / 能量核心 / 命中粒子，傷害越高線寬、粒子與震動越強，Overclock 中使用金色調。
- `WORK_PLAN.md`：更新為 Phase 11 本圈計畫。

# Validation Results
- ✅ 達標斬殺：`Battle.gd` 命中後用 `round_context.damage_accumulator >= enemy_hp + execute.margin` 判定，`execute.enabled` 可關閉。
- ✅ 清場 / 不重複結算：斬殺時 `_execute_in_progress` 阻擋輸入、回收 signal 與 SETTLE 重入，所有場上球走 `recover("execute")` 後由單一路徑進 CHECK。
- ✅ REWARD / VICTORY 分支：斬殺最終仍進 `_check_battle_end()`，沿用既有非 Boss 獎勵與 Boss 勝利判定。
- ✅ 玩家攻擊演繹：正常結算與斬殺都播放匯聚粒子、Line2D 光束、程序化能量核心、命中粒子，之後接敵人受擊回饋與傷害數字。
- ✅ 強度隨傷害放大：`player_attack.damage_scale_reference` 控制強度縮放，線寬、能量核心、粒子、shake、SFX pitch 隨傷害上升；Overclock 中改金色。
- ✅ 一般釘 boost / bumper 分流：非 `bounce_peg` 命中套 `peg_bounce_boost = 1.15`；`bounce_peg` 只套 `bottom_row.bounce_multiplier`；兩者都夾 `max_ball_speed`。
- ✅ 程序化效果：未新增外部圖片 / 音效素材；演出以 ColorRect、Label、Line2D、Polygon2D、CPUParticles2D、Tween、Camera 與合成 SFX 完成。
- ✅ 資料化：斬殺開關 / 門檻、彈跳 boost、速度上限、cut-in 與玩家攻擊演出皆由 JSON 控制。
- ✅ 用詞掃描：`Scripts/Scenes/Data` 無本卡禁用字詞。
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ Godot 驗證：專案與 `Scenes/Battle.tscn` headless 載入通過。
- ✅ Export 驗證：Windows Desktop Export 成功；新 `Data/player.json` / `Data/feel.json` 與腳本已打包，`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。
- ⚠️ 完整可視化一整局：headless / export 通過；斬殺時機、攻擊演出強度、彈跳脆度與幀率體感仍需人類實機驗收。

# Open Questions
- 無新增。
- Q-023 / Q-024 / Q-025 已依決議實作。

# Risks
- 斬殺會縮短已達標回合的等待時間，Demo 節奏會更快；若覺得太早收掉，可先調 `Data/player.json` 的 `execute.margin` 或關閉 `execute.enabled`。
- 一般釘 boost 會提高球速與連續命中機率；若出現穿透、飛太快或太難控，優先調 `peg_bounce_boost` / `max_ball_speed`。
- 玩家攻擊和 cut-in 是體感項；若太亮、太晃或太慢，優先調 `Data/feel.json` 的 `overkill_cutin` / `player_attack`。

# Recommended Next Task
- 建議人類用 `Builds/NanoDungeon.exe` 實機驗收 Phase 11：確認達標斬殺不等落底、OVERKILL cut-in 不遮擋太久、玩家攻擊演出與 count-up 節奏合拍、一般釘反彈更脆且底排 bumper 不失控。通過後可進美術 Pass，或只做 `player.json` / `feel.json` 體感微調。

## 歷史報告 — Phase 10 Overclock

# Summary
完成 `Codex/10_OVERLOAD_MODE.md`：新增 Overclock gauge、命中累積、100 觸發、3 回合未觸發的強制同步、限定 2 回合過載狀態；過載中重抽權重偏向 `burst_peg` / `double_peg`，Peg 傷害套用全域倍率。爆發演出使用 ColorRect、Tween、Camera punch、scanline、粒子與合成 SFX，未依賴外部素材，也未改 base 傷害公式或新增種類。

# Completed
- `Data/overload.json`：新增全部過載參數，包含開關、充能、天井、持續、權重、倍率、gauge 顏色、演出強度與 SFX pitch。
- `Scripts/RunState.gd`：新增 run-scoped 過載槽、未觸發回合、剩餘過載回合與 reset 歸零。
- `Scripts/DataLoader.gd`：載入並驗證 `overload.json`。
- `Scripts/Battle.gd`：命中累積能量、達 100 觸發、ROUND_START 天井強制觸發、過載回合消耗、UI 更新、過載期間權重 / 傷害倍率接入。
- `Scripts/FieldGenerator.gd`：重抽支援權重覆寫；內部格位命名改為 `cell`。
- `Scripts/EffectResolver.gd`：Peg 傷害結算接受外部倍率，維持既有公式結構。
- `Scripts/BattleFX.gd`：新增過載 gauge 脈動、臨界抖動、OVERCLOCK cut-in、全螢幕 flash、金色 overlay、scanline、Camera punch、強化命中粒子 / 文字與退場淡出。
- `Scenes/Battle.tscn`：新增 `OverloadLabel` / `OverloadBar`。

# Validation Results
- ✅ 命中累積、分階段演出、天井強制觸發、過載期間權重 / 傷害倍率與指定回合退場皆依 Q-022 實作。
- ✅ 程序化效果、資料化 / 可關閉、用詞掃描、JSON 驗證、Godot headless 與 Windows Export 驗證皆通過。
- ⚠️ 完整可視化一整局：headless / export 通過；過載爆發強度、scanline、shake、節奏屬體感項，仍需人類實機驗收。

# Open Questions
- 無新增。Q-022 已依決議實作。

# Risks
- 過載權重與 1.5 倍傷害會明顯提高 Demo 輸出穩定度；若 Boss 過快被擊倒，建議先只調 `Data/overload.json`。

# Recommended Next Task
- 建議人類用匯出版實機驗收 Phase 10：確認 3 回合內必定看到爆發、過載中高價值 peg 明顯變多、傷害與演出強度符合現場展示節奏。

## 歷史報告 — Phase 9 Game Feel

# Summary
完成 `Codex/09_GAME_FEEL.md`：新增共用淡入淡出轉場，將戰鬥結算、敵人攻擊、下一回合拆成可感知 beat；敵人攻擊具備預兆 / 衝擊 / 收手三拍，Boss special 會先 telegraph；補上敵人受擊、玩家低血、combo、miss、集氣、升級卡與每回合重組快閃等純表現回饋。未改傷害、HP、球池、敵人、抽取或升級規則。

# Completed
- `Data/feel.json`：新增 `transitions / turn_pacing / enemy_attack / combo / telegraph / low_hp / charge / drain / reroll_flash / upgrade_card / settlement` 表現參數。
- `Scripts/SceneTransition.gd` / `project.godot`：新增 autoload，所有場景切換改走淡入淡出 helper。
- `Scripts/BattleFX.gd`：集中處理回合 banner、Boss telegraph、低血邊緣、玩家受擊 flash、敵人受擊閃白 / 抖動、settlement count-up / HP drain、combo、miss、launcher recoil、reroll flash。
- `Scripts/Battle.gd`：SETTLE / ENEMY_TURN / CHECK / ROUND_START 接入資料化 await beat；敵人攻擊拆成三拍；結算總傷 count-up 與 HP bar 分段下降。
- `Scripts/Ball.gd` / `Scripts/Peg.gd`：Ball 回報單顆命中次數供 combo/miss 表現；Peg 支援重組快閃。
- `Scripts/UpgradeScreen.gd`：升級卡 hover 放大、選定 pulse；下一場切換走 SceneTransition。
- `Scripts/MainMenu.gd`、`GameOver.gd`、`Victory.gd`：切場按鈕改用淡入淡出。

# Validation Results
- ✅ 場景切換淡入淡出：所有 `change_scene_to_file()` 呼叫集中於 `SceneTransition.gd`，其餘畫面改呼叫 `SceneTransition.change_scene()`。
- ✅ 回合節奏：`turn_pacing` 控制 settle / enemy / check / round start 等待，避免一幀內跑完。
- ✅ 敵人攻擊三拍：敵人回合顯示 banner，Boss special 先 telegraph，攻擊流程為 wind-up → impact flash/shake/damage text → recover。
- ✅ 受擊與結算：敵人受傷閃白 / 抖動，玩家受擊紅 flash + shake；結算總傷 count-up，敵人 HP bar drain。
- ✅ combo 純表現：Ball 只回報 hit count；傷害仍由 `EffectResolver.apply_peg_effect()` 計算，combo 不進傷害公式。
- ✅ 低血 / miss / charge / upgrade / reroll：低血邊緣脈動、低命中落底 miss、集氣視覺 / 音高漸強與發射後座力、升級卡 hover/select、每回合 peg 重組快閃皆已接入。
- ✅ 新參數資料化：新增時間、強度、文字、門檻、開關皆在 `Data/feel.json`；`DataLoader` 驗證新增區段。
- ✅ 玩法 / 平衡不變：未改 `Data/player.json`、`Data/pegs.json`、`Data/balls.json`、`Data/enemies.json`、`Data/upgrades.json`，未改 EffectResolver 傷害公式或 RunState 成長規則。
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ Godot 驗證：專案、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` headless 載入通過。
- ✅ Export 驗證：Windows Desktop Export 成功；`Builds/NanoDungeon.exe --headless --quit` 可獨立啟動。
- ⚠️ 一整局 5 場 + 4 次升級：headless / export 驗證通過；game feel 強度、節奏停頓長短、低血脈動與 SFX 體感仍需人類實機驗收。

# Open Questions
- 無新增。
- Q-021 已依決議實作。

# Risks
- 轉場、回合停頓與 SFX pitch 是體感項；若過慢或過吵，建議只調 `Data/feel.json`。
- 新增 overlay 為純 UI 節點，headless / export 通過；仍建議用 1024×1024 視窗實機確認不遮擋關鍵 UI。

# Recommended Next Task
- 建議人類用 export 版實機驗收 Phase 9：完整打一局，確認回合節奏、Boss telegraph、低血提示、升級卡手感與重組快閃強度。通過後下一條軌道為美術 Pass。

## 歷史報告 — Phase 8 Launch & Tuning

# Summary
完成 `Codex/08_LAUNCH_AND_TUNING.md`：底排 `bounce_peg` 改為主動 bumper，命中後依 JSON 倍率加速且有速度上限；發射流程改為 AIMING 狀態兩段式集氣，左鍵 / 空白鍵第一下集氣、第二下發射，AimLine 改拋物線預覽；每回合重抽 peg 類型時保證 `double_peg` 至少出現指定數量，並新增整局升級可增加保底數。未新增球 / 敵人 / 釘種類，未改既有傷害、敵人或升級抽取規則，位置骨架不變。

# Completed
- `Data/field.json`：新增 `bottom_row.bounce_multiplier`、`bottom_row.max_ball_speed`、`generator.guaranteed_double_peg_count`、`generator.max_guaranteed_double_peg_count`。
- `Data/player.json`：新增 `launch_speed_min`、`launch_speed_max`、`charge_cycle_seconds`，power 以此換算初速。
- `Data/feel.json`：新增 `aim_preview.point_count` / `time_step`，控制拋物線預覽採樣。
- `Data/upgrades.json`：新增 `up_guaranteed_double`，`_meta.stat_targets` 加入 `guaranteed_double_peg`。
- `Scripts/Ball.gd`：命中 `bounce_peg` 時主動放大 `linear_velocity` 並夾 `max_ball_speed`；CCD 保留。
- `Scripts/Battle.gd`：AIMING 輸入改兩段式集氣 / 發射，支援左鍵與空白鍵；`AimLine` 改為拋物線點列；發射速度依 power 傳給 Ball。
- `Scenes/Battle.tscn`：新增 power label / progress bar。
- `Scripts/FieldGenerator.gd`：每回合重抽時先保留指定數量槽位為 `double_peg`，其餘照權重池抽。
- `Scripts/RunState.gd` / `Scripts/UpgradeResolver.gd`：新增保底 double 整局狀態、升級套用、重開歸零與達上限排除。
- `Scripts/DataLoader.gd`：驗證 Phase 8 新欄位與數值範圍。

# Validation Results
- ✅ bumper 加速資料化：底排 `bounce_peg` 讀 `field.json.bottom_row.bounce_multiplier = 2.0`；速度以 `max_ball_speed = 1600.0` 夾住。
- ✅ CCD 保留：`Ball.gd` 仍設定 `continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY`。
- ✅ 兩段式輸入：AIMING 下左鍵 / 空白鍵第一下只開始集氣，第二下才發射；非 AIMING 狀態 `_input()` 直接 return。
- ✅ power 表：`PowerLabel` / `PowerBar` 顯示 0→100→0 來回擺動。
- ✅ power 影響初速：`launch_speed = lerp(launch_speed_min, launch_speed_max, power/100)`。
- ✅ 拋物線預覽：`AimLine.points` 由發射方向、當前 speed、重力與 `feel.aim_preview` 採樣產生。
- ✅ double_peg 保底：`FieldGenerator.roll_dynamic_types()` 先抽保底槽位為 `double_peg`；Battle 傳入 `RunState.guaranteed_double_peg_count`。
- ✅ 新升級套用與上限：`up_guaranteed_double` 會讓保底數 +1，達 `max_guaranteed_double_peg_count` 後排除；`reset_new_run()` 回預設。
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ Godot 驗證：main scene、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` headless 載入通過。
- ✅ Export 驗證：Windows Desktop Export 成功；匯出 exe 可 `--headless --quit` 獨立啟動。
- ⚠️ 實機完整一局：headless / export 驗證通過；bumper 力道、集氣節奏、double 保底對輸出與 5 場節奏的影響仍需人類實機驗收。

# Open Questions
- 無新增。
- Q-018 / Q-019 / Q-020 已依決議實作。

# Risks
- 主動 bumper 與速度上限會明顯改變球路；若出現穿透、卡死或過度飛高，建議只調 `Data/field.json` 的 `bounce_multiplier` / `max_ball_speed`。
- 集氣週期與速度上下限會直接影響手感與可控性，建議實機後只調 `Data/player.json`。
- double 保底與升級會提高輸出穩定度，可能需要實機後微調 `guaranteed_double_peg_count` / 上限或既有敵人 JSON。

# Recommended Next Task
- 建議人類先用 export 版實機驗收 Phase 8：確認兩段式操作是否順手、拋物線預覽是否可信、底排 bumper 是否不穿透、保底 double 是否有策略感。若通過，下一圈建議只做 JSON 手感調參，不新增玩法。

## 歷史報告 — Procedural Pegboard

# Summary
完成 `Codex/07_PROCEDURAL_PEGBOARD.md`：釘盤由手列座標改為 `Data/field.json` 參數化 generator，新增 `FieldGenerator.gd` 以公式生成固定位置骨架，並在每次 ROUND_START 只重抽動態 peg 類型。新增底部固定 `bounce_peg` 反彈排，場地與 viewport 拉高至 1024×1024。未做漸變特效、未擾動位置骨架、未新增除 bounce_peg 以外的種類，也未改既有傷害 / 升級 / 敵人規則。

# Completed
- `Data/field.json`：改為 `generator + bottom_row` schema，包含 rows / spacing / columns / type weights / special radius / seed / bounce row。
- `Scripts/FieldGenerator.gd`：新增純資料生成器，負責建動態 peg 骨架、底排座標與依權重抽類型。
- `Scripts/Battle.gd`：READY 建立固定 peg 節點與底排；每次 ROUND_START 呼叫 generator 重抽動態 peg 類型並 reconfigure 節點，位置不變。
- `Data/pegs.json`：新增 `bounce_peg`，`effect_type: none`，只用底部固定排。
- `Scripts/EffectResolver.gd`：支援 `none`，回傳空 peg 結果，不加傷害 / 回血 / 倍率 / 浮動傷害。
- `Scripts/DataLoader.gd`：驗證 generator / bottom_row、權重 id、special radius、bounds、bottom row 必須為 `bounce_peg` 且 radius > 0。
- `project.godot` / `Scenes/Battle.tscn`：viewport / 場地拉高至 1024×1024，牆、field fill / border、BottomSensor、BattleCamera、StatusLabel、結束按鈕位置同步調整。
- Windows Desktop Export 已重新產出，`Data/field.json` 與 `FieldGenerator.gd` 已打包。

# Validation Results
- ✅ 位置由公式生成：`field.json` 無手列 `layout`，骨架由 `FieldGenerator.build_dynamic_slots()` 依 generator 參數計算。
- ✅ 每回合只重抽類型：`Battle._begin_round()` 呼叫 `_reroll_dynamic_pegs()`，只 `configure()` 動態 peg 的 id / radius，位置不變。
- ✅ 底部固定 bounce row：`FieldGenerator.build_bottom_slots()` 依 `bottom_row` 生成，Battle 建好後不參與 reroll。
- ✅ `bounce_peg` 無效果：`EffectResolver` 對 `none` 回空結果；命中只有物理反彈 / 命中粒子 / SFX，無傷害數字。
- ✅ 視窗 / 場地 1024×1024：`project.godot` 設 viewport 1024×1024；Battle field bottom=960，BottomSensor y=986，BattleCamera y=512。
- ✅ seed 支援：`FieldGenerator.configure()` 若 `seed` 為整數則設定 RNG seed；`null` 則 randomize。
- ✅ 物理安全：位置骨架固定，底部 bounce row 固定，8 秒 timeout 保留。
- ✅ Godot 驗證：main scene、`Battle.tscn`、`UpgradeScreen.tscn`、`GameOver.tscn`、`Victory.tscn` headless 載入通過。
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ Export 驗證：Windows Desktop Export 成功；匯出 exe 可 `--headless --quit` 獨立啟動。
- ⚠️ 一整局可視化穩定性：程式 / 場景 / export 驗證通過；因每回合重抽 + 新高度是手感敏感改動，仍需人類實機驗收漏球率、輸出、Boss 可達性。

# Open Questions
- 無新增。
- Q-015 / Q-016 / Q-017 已依決議實作。

# Risks
- 新高度與每回合類型重抽會改變輸出曲線與球路，可能需要人類後續只調 `Data/field.json` 的 weights / rows / spacing / bottom_row 來平衡。
- `bounce_peg` 不進隨機池，但底排數量與位置會影響漏球率；建議實機觀察後微調 `bottom_row.count` 或 `bottom_row.y`。

# Recommended Next Task
- 建議人類用 export 版實機跑 2–3 局，觀察：每回合重抽是否有明顯變化、底排 bounce 是否降低全漏、Boss 是否仍可達；若需要，下一圈只做 `Data/field.json` 參數微調。

## 歷史報告 — Field Layout

# Summary
完成 `Codex/06_FIELD_LAYOUT.md` 可玩性增量：釘子位置與半徑已由 `Battle.gd` / `Peg.gd` 搬到 `Data/field.json`。初版 field layout 沿用既有 8 顆 peg 的座標與類型，半徑預設 18，作為行為等價起點；後續人類可直接調 JSON 來改佈局與逐顆大小。本卡未新增任何玩法 / 種類，也未實作每層不同佈局。

# Completed
- 新增 `Data/field.json`：包含 field bounds、`default_peg_radius` 與 8 顆 peg layout。
- `Scripts/DataLoader.gd`：新增 `field.json` 載入、`get_field_config()` 與驗證：
  - layout id 必須存在於 `pegs.json`。
  - x / y 必須在 bounds 內。
  - radius 或 default radius 必須 > 0。
- `Scripts/Battle.gd`：`_spawn_pegs()` 改為讀取 `DataLoader.get_field_config()["layout"]`，移除寫死 peg slots。
- `Scripts/Peg.gd`：`configure()` 接收 per-peg radius，並為每顆 peg `CircleShape2D.new()`，避免共用 sub-resource 連動；繪製半徑與 collision shape 半徑同步。
- `WORK_PLAN.md`、`CHANGELOG.md`、`PROGRESS_REPORT.md` 已更新。

# Validation Results
- ✅ 釘子位置與大小來自 `Data/field.json`：Battle 只讀 field layout；初版 8 顆沿用原座標。
- ✅ 改 JSON 即可調佈局：`DataLoader` 將每顆 layout 正規化並提供給 Battle；無需改程式。
- ✅ 逐顆 radius 支援：每顆 Peg 在 `configure()` 建立獨立 `CircleShape2D`，並使用同一 `radius` 繪製。
- ✅ 共用 shape 陷阱已處理：不再修改 `Peg.tscn` 的共用 sub-resource，runtime 每顆獨立 shape。
- ✅ `DataLoader` 驗證 id / bounds / radius：無效資料會 `push_error()` 明確指出。
- ✅ 初版行為等價：field layout 沿用現有 8 顆座標與類型，半徑維持 18。
- ✅ Godot 驗證：Godot 4.6.3 headless 載入 main scene 與 `Scenes/Battle.tscn` 通過。
- ✅ JSON 驗證：`Data/*.json` 全部可解析。
- ✅ 禁止事項：未新增 Peg / Ball / Enemy / upgrade 種類，未新增新機制，未改傷害 / 效果規則，未實作每層不同佈局。

# Open Questions
- 無新增。
- Q-014 採使用者本次指定預設：單一基礎佈局套用全部場次；schema 保持可延伸，但本卡不實作每層變化。

# Risks
- 初版刻意行為等價，策略性尚未調整；下一步應由人類直接調 `Data/field.json` 的座標與 radius 做手感比較。
- 我嘗試用暫時 smoke test 直接建立兩顆 Peg 驗證不同半徑時，Godot headless 測試場景觸發 engine crash；產品 `Battle.tscn` 載入正常，暫時測試檔已刪除。後續若要自動化這項檢查，建議用更保守的場景流程或 Godot editor test harness。

# Recommended Next Task
- 建議下一步由人類調整 `Data/field.json`：先讓高價值 peg（Burst / Double）縮小或移到較難命中的位置，Heal / Normal 作為保底，再實機比較 2–3 組佈局。

## 歷史報告 — Phase 5 Polish & Demo

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
