# 任務卡 10 — OVERLOAD MODE（過載模式：張力鋪陳 → 爆發）

> 可玩性擴充軌道。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：加入「**鋪陳張力 → 大爆發**」的賽博爽感——過載槽累積、分階段升壓、觸發後進入數回合的「過載模式」（高價值釘變多 + 傷害爆發 + 全螢幕演出）。
>
> 排程：Phase 9 之後。決策依據見 OPEN_QUESTIONS **Q-022**（已決議）。
>
> ⚠️ **用詞規範**：一律使用賽博語彙（過載 / Overclock / 系統崩潰 / 升壓 / 臨界），**不得出現任何柏青哥 / 確変 / フィーバー / 拉霸等術語**（畫面文字、變數名、註解皆然）。

---

## 核心紀律

- **爽度 = 程序化效果**：所有爆發演出用 **Godot 內建程序化手段**實現（shader、`GPUParticles2D`、WorldEnvironment glow、`Tween`、Camera2D、合成 SFX），**不得依賴任何外部美術素材**。確保 Codex 能完整產出、穩定、且 export 後可用。
- **資料化**：所有過載參數（觸發、天井、持續、權重、倍率、各階段演出強度）集中在新檔 `Data/overload.json`，可手調。
- **限定與保底**：效果限定回合數、天井保證觸發，避免失控或現場觸發不到。
- **穩定優先**：任何 shader / hitstop 不得造成穿透、卡死或掉幀；可被關閉。

## 玩法規格

### 過載槽（Overclock Gauge）
- 新增一條 gauge（建議 `Battle.tscn` 內 UI，垂直或水平條 + 狀態字）。
- 命中釘子累積能量，數值依釘類型（`charge_per_hit`，放 `overload.json`）。預設：
  - `normal_peg: 1`、`heal_peg: 1`、`burst_peg: 3`、`double_peg: 5`、`bounce_peg: 0`。
- 槽值達 `trigger_threshold`（預設 100）→ 觸發過載。
- 槽與「未觸發回合計數」存於 `RunState`（整局，run-scoped），`reset_new_run()` 歸零。

### 天井保底（DEMO 預設 3 回合）
- 連續 `pity_rounds`（預設 **3**）回合未觸發過載 → 下個 ROUND_START **強制觸發**。
- 參數化可手調（`overload.json`）。
- 目的：確保現場一定看得到爆發。

### 過載模式（觸發後）
- 持續 `overload_duration_rounds`（預設 2，可調）回合：
  - **重抽權重倒向高價值**：該模式回合的 ROUND_START 重抽時，`burst_peg` / `double_peg` 權重乘上 `overload_weight_multiplier`（預設 burst ×3、double ×4），其餘照舊。（沿用 `FieldGenerator` 既有重抽，僅換權重來源。）
  - **全域傷害倍率**：過載期間 peg 傷害結算乘上 `overload_damage_multiplier`（預設 1.5）。在 `EffectResolver` / 結算讀取過載旗標套用，**不改 base 數值、不改傷害公式結構**。
- 結束：槽歸零、天井計數重置、退場演出。

## 爽度規格（給 Codex 的具體演繹提示）

依張力階梯逐階升級；**括號內為可直接使用的 Godot 技術提示**，強度 / 時間 / 顏色全進 `overload.json`：

**Tier 0（0–69%）平時**
- gauge 條柔和青色脈動（`Tween` modulate 來回）。

**Tier 1（≥70%）升壓**
- 場地 glow / 邊框色由青漸轉洋紅（WorldEnvironment glow intensity 漸升 + `Line2D`/`Polygon2D` modulate `Tween`）。
- 低頻嗡鳴漸起（合成 SFX，pitch 隨槽值上升）。
- 每回合「重組洗牌」閃爍加長加亮（沿用 Phase 9 reroll flash，參數放大）。

**Tier 2（≥90%）臨界 / UNSTABLE**
- 輕微全螢幕抖動 + **故障感 shader 漸強**（CanvasLayer + ColorRect + CanvasItem shader：UV 抖動、色差 chromatic aberration、scanline；用 `time` uniform 由 `Tween`/`_process` 推進；如需取樣畫面用 `BackBufferCopy` 或 `hint_screen_texture`）。
- 瞄準線閃紅、警告字樣「系統不穩 / UNSTABLE」（Label glitch 位移）。
- 心跳式 SFX。

**觸發瞬間（100% 或天井）**
- **凝滯一拍**（建議用短計時 await / `Engine.time_scale` 短暫降到 ~0.1 再恢復；⚠️ time_scale 會影響物理，務必極短並測試，不穩就改用「暫停輸入 + 演出計時」不動 time_scale）。
- 畫面變暗 → **全螢幕故障爆閃 + 「OVERCLOCK」cut-in**（大字 RichText/Label，scale+fade+位移 jitter `Tween`；ColorRect 閃白/閃金）。
- Camera 變焦衝擊（`Camera2D.zoom` `Tween` punch）+ 強 shake（沿用 BattleFX）。
- 重低音 SFX（pitch 下沉）。

**過載中（持續回合）**
- 場地金光化（glow 提升 + modulate 偏金）、持續但克制的 scanline/glitch overlay。
- 釘子命中粒子更大、SFX pitch 更高、傷害數字加大偏金（沿用 BattleFX，參數加強）。
- gauge UI 改顯示「OVERCLOCK ×N 回合」。

**退場**
- 降壓掃描（glow 漸退、overlay 淡出、降頻 SFX），回到平時。

> 全部用程序化效果即可達成；**不要求任何 PNG / 外部資源**。若 shader 在 export / 1024×1024 下有相容或效能疑慮，降級為「ColorRect 閃光 + modulate + 粒子」仍可達 80% 效果，**穩定優先於華麗**。

## 不做範圍（嚴禁）

- ❌ 不做拉霸 / 轉輪 / 任何柏青哥外型或術語。
- ❌ 不新增 Peg / Ball / Enemy 種類；不改 base 傷害數值或傷害公式結構（過載倍率為清楚界定的全域狀態乘數）。
- ❌ 不依賴外部美術素材（純程序化）。
- ❌ 不做無限 / 不可關閉的爆發；必須限定回合 + 天井 + 全參數化。
- ❌ 不為演出犧牲穩定幀率 / 物理安全 / export 可用性。

## 預期產出

- `Data/overload.json`：charge_per_hit、trigger_threshold、pity_rounds(3)、overload_duration_rounds、overload_weight_multiplier、overload_damage_multiplier、各 tier 演出強度 / 顏色 / 時間。
- `Scripts/RunState.gd`：過載槽值、未觸發回合計數、過載剩餘回合、旗標；reset 歸零。
- `Scripts/Battle.gd`：ROUND_START 結算槽 / 天井 / 觸發 / 退場；過載期間以強化權重重抽。
- `Scripts/FieldGenerator.gd`：接受過載權重覆寫。
- `Scripts/EffectResolver.gd`：過載期間套用傷害倍率（讀旗標）。
- `Scripts/BattleFX.gd`：tier 升壓 / 臨界 / 觸發 cut-in / 過載中 / 退場演出（程序化）。
- `Scenes/Battle.tscn`：過載槽 UI + 全螢幕 overlay 節點。
- `Scripts/DataLoader.gd`：載入並驗證 `overload.json`。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）

- [ ] 過載槽會隨命中累積（double 加最多），UI 可見、分階段變色。
- [ ] ≥70% 升壓、≥90% 臨界、觸發爆發三階段演出明顯且漸強。
- [ ] 連續 3 回合（預設）未觸發 → 天井強制觸發，現場必定看得到。
- [ ] 過載期間 burst/double 明顯變多、傷害倍率生效；持續指定回合後正確退場、槽與計數歸零。
- [ ] 所有演出為程序化（無外部素材）；export（1024×1024）後仍正常、不掉幀、不穿透。
- [ ] 全參數來自 `Data/overload.json`，手調即生效。
- [ ] 畫面 / 變數 / 註解無任何柏青哥術語，全賽博用詞。
- [ ] 既有玩法不被破壞；一整局（5 場 + 4 次升級）仍可穩定跑完；可關閉過載（設定）。
- [ ] Godot 載入無錯、`Data/*.json` 解析通過。

## 禁止事項

- ❌ 不得用外部美術素材冒充「做得出效果」；爽度必須是程序化、可執行的真效果。
- ❌ 不得讓 time_scale / shader 造成不穩；有疑慮一律降級保穩定。
- ❌ 不得偏離 Q-022；如需擴張先回 `OPEN_QUESTIONS.md` 提案。

## 完成後

- 依本卡 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 提醒人類：爆發強度 / 節奏為體感項，**務必實機驗收**，並可只調 `Data/overload.json`（門檻、天井、持續、權重、倍率、演出強度）微調爽度。
