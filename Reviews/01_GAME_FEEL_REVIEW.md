# Review 01 — GAME FEEL（14 張任務卡後的里程碑回望）

> **這份文件不是任務卡。** 它是 Reviewer / Director 層的回望產物，產於 `Codex/01–14` 全部執行完畢之後。
> 角色定位：對應 `Codex/00_MASTER_PROMPT.md` 所述的 **AI Reviewer** 角色——評估體感、不下實作指令。
> 產出去向見文末「分流表」：**玩法決策回 `OPEN_QUESTIONS.md`（人類裁決），純表現項才生成 `Codex/15`。**
>
> 階段：Phase 14（藝術與場景打磨）之後。觸發原因：人類在里程碑點開新的乾淨上下文重新評估手感（無實作偏見）。

---

## 0. 先確認既有成果（避免重複建議）

本專案在「特效數量」上已成熟，以下皆**已存在**，不在缺漏之列：

- **Screen Shake**：分級存在（hit / enemy_attack / telegraph / miss / overkill），資料驅動於 `Data/feel.json` → `shake`。
- **Particles**：launch / hit / trail / combo 疊加、overload 倍率（`Scripts/BattleFX.gd` `spawn_particles`）。
- **Hit Effect**：peg 白閃（`Scripts/Peg.gd` `play_hit_feedback`）、floating text、combo text、bumper ring。
- **資料驅動架構**：`feel.json` 已是成熟 presentation config；`BattleFX` 全程 `_xxx_config()` 讀表。
- **結算高潮**：雷射光束攻擊 + count-up + overkill cut-in + camera zoom punch（`Battle.gd` `_settle_round` / `_begin_execute_clear`）。

→ 結論：問題**不是缺特效，是特效的「分配與輕重」**。

---

## 1. Executive Summary：目前最大的 Game Feel 問題

> **有「峰值」，沒有「爬升」；有大量「持續發光」，缺少「瞬間頓挫」。情緒曲線是一條高原，不是一條上坡。**

兩個根因：

**根因 A — 沒有 Hitstop（命中頓挫）。**
全 `Scripts/` 無任何 `time_scale` / `freeze` / hitstop 機制。所有命中回饋都是「加法」（多加 shake / 粒子 / 光），缺少「減法」（命中瞬間停時間 2–5 frame）。沒有頓挫，再多粒子也只是「亮」，不會「脆」。**CP 值最高的缺口。**

**根因 B — Peg 命中被平均化，缺少個性化動能回饋。**
`Ball.gd` `_on_body_entered` 對所有非 bounce peg 呼叫**完全相同**的 `Peg.gd` `play_hit_feedback()`（固定白閃）；`Battle.gd` `_on_ball_peg_hit` 的 `start_hit_shake()` 是**固定強度**、不分 peg；SFX 同為單一 920Hz、只隨 combo 升調。結果：1 傷的 `normal_peg` 與 7 傷的 `burst_peg`，**震動／音色／閃光完全相同**，只有顏色與飄字不同。玩家是用「讀字」分辨命中了什麼，不是用「身體感」。→ **有辨識度（顏色），沒有存在感（動能）。**

**結構性附帶問題 — 累積感被打斷。**
`Ball.gd` 的 `_combo_hits` 是**每顆球各自獨立**、每發新球歸零，因此 combo 升調 / 升級粒子每球被打回原點，回合內感受不到「越打越熱」。`damage_accumulator` 雖跨球存在並即時顯示（`Battle.gd` `_update_ui`），但只是 HUD 角落一行小字，**沒有任何爬升演出**。

---

## 2. 發現清單（依優先序，含檔案定位）

### P0 — 最少成本、最大爽感

| # | 發現 | 定位 | 性質 |
|---|---|---|---|
| P0-1 | **無全域 Hitstop**。命中缺重音節拍器。建議依 peg 傷害分級的極短時間凍結。 | 全 `Scripts/`（無 time_scale） | 含玩法決策（節奏影響）→ 需裁決 |
| P0-2 | **Peg 回饋未分級**。shake / sfx / 閃光對所有 peg 相同。建議改為依 peg 查表。 | `Peg.gd:48`、`Battle.gd:594`、`Battle.gd:597` | 純表現，但涉新 schema 欄位 → 需提案 |
| P0-3 | **combo 跨球歸零**，累積感被打斷。建議增「回合層級熱度」接既有 `damage_accumulator`。 | `Ball.gd:20`、`Ball.gd:107`、`Battle.gd:783` | 含玩法決策（是否影響體感平衡）→ 需裁決 |

### P1 — 進一步雕情緒曲線

| # | 發現 | 定位 | 性質 |
|---|---|---|---|
| P1-1 | **敵人在球飛行中毫無反應**，僅結算/自身回合才動。建議用 `accumulator/max_hp` 比值驅動 portrait 漸進反應。 | `feel.json` `enemy_display`、`Battle.gd:657` | 純表現 → 可生卡 |
| P1-2 | **結算為並列播放**，因果不清。建議蓄力→釋放→排空有先後。 | `BattleFX.gd:291` | 純表現 → 可生卡 |
| P1-3 | **Boss 與雜魚共用同框**，缺舞台感。建議對 `type=="boss"` 套放大的 enemy_display profile。 | `feel.json` `enemy_display`、`enemies.json` boss | 純表現 → 可生卡 |

### P2 — 加分項

| # | 發現 | 定位 | 性質 |
|---|---|---|---|
| P2-1 | **持續發光的基線噪音過高**（每 peg/ball 永遠 idle pulse + halo），稀釋命中訊噪比。建議降 idle alpha。 | `feel.json` `scene_fx` | 純表現（純調數值）→ 可生卡 |
| P2-2 | **Miss 洩氣感不足**，缺低谷對比。 | `BattleFX.gd:139` | 純表現 → 可生卡 |
| P2-3 | **無動態焦點引導**，各階段未壓暗非焦點區。 | `feel.json` `hud` / overlay | 純表現 → 可生卡 |

---

## 3. 架構契合度（落點建議）

| 發現 | 落點 | 為何契合 |
|---|---|---|
| Hitstop | `feel.json` 新增 `hitstop` 區塊 + `BattleFX.apply_hitstop()` | 與 `shake` 同層級，全域單點 |
| Peg 個性化 | `feel.json` 新增 `peg_feel` 查表（peg_id 為 key） | gameplay 與 feel 分離，改數值不改碼 |
| 跨球熱度 | `feel.json` 新增 `round_heat`，接 `damage_accumulator` | 數值已存在，只接視聽通道 |
| 敵人受傷反應 | `feel.json` `enemy_display` 加 `damage_reaction` | 沿用既有 portrait node |
| Boss 舞台 | 針對 `type=="boss"` 套不同 `enemy_display` profile | 資料分支，非新場景 |

**須避免的反模式**（擴張時易犯）：

- ❌ hitstop 時長寫死在 `Ball.gd` / `Battle.gd` → 應進 `feel.json`。
- ❌ 為每種 peg 寫 `if peg_id == ...` 回饋分支 → 應查表（`Peg.gd:73` 已有一個 match，勿長出第二個）。
- ❌ 為 combo / heat 開新 manager 節點 → 沿用 `round_context` + `BattleFX`。

---

## 4. 分流表（本 Review 的產出去向）

依 `Codex/00_MASTER_PROMPT.md` 權限矩陣，本 Review 的發現分流如下。**此分流本身即是 Self-Correcting Workflow 的演出。**

### 🔶/⛔ 需人類裁決 → 寫入 `OPEN_QUESTIONS.md`

- **Q-XXX（Hitstop）**：是否引入全域 hitstop？可接受的凍結時長上限為何（避免拖慢一局 5–10 分鐘的節奏）？是否依 peg 傷害分級？
- **Q-XXX（跨球累積熱度）**：是否新增「回合層級熱度」視聽爬升？此為純表現，但會改變回合內的情緒節奏，屬體感方向，需人類確認不偏離設計。
- **Q-XXX（peg_feel schema）**：在 `feel.json` 新增 `peg_feel` / `hitstop` / `round_heat` 區塊屬**新欄位結構**（權限矩陣 🔶 需提案）。請核可 schema 擴張。

### ✅ 已屬純表現、方向明確 → 可生成 `Codex/15`（待上述 schema 核可後）

- P1-1 敵人飛行中漸進反應、P1-2 結算因果化、P1-3 Boss 舞台、P2-1 降基線噪音、P2-2 Miss 洩氣、P2-3 焦點引導。
- 一旦 Q-XXX（hitstop / heat / schema）獲裁決，P0-1/P0-2/P0-3 亦併入卡 15 或拆為卡 16。

---

## 5. 建議下一步（給人類）

1. 讀本 Review，對第 4 節三條 Q-XXX 做裁決（接受 / 修改上限 / 否決）。
2. 裁決後，由 Reviewer 產生 `Codex/15_GAME_FEEL_PASS_2.md`：**僅含已核可範圍**，沿用 `Codex/09_GAME_FEEL.md` 的卡片格式（核心紀律 / 不做範圍 / 預期產出 / DoD / 禁止事項）。
3. 交付 Codex 執行卡 15 → 自驗 → 更新 `CHANGELOG.md` / `PROGRESS_REPORT.md` → 回到本 Review 對照是否消化。

> **一句話**：不需要更多特效，需要把現有特效「分配出輕重」。三個動作改寫情緒曲線——(1) hitstop 給命中重音、(2) peg 回饋查表分級、(3) 把已存在的 `damage_accumulator` 接成「跨球升溫 → 敵人漸痛 → 結算傾瀉」的爬升線。全部落在現有 JSON 驅動範式內，零新玩法。
