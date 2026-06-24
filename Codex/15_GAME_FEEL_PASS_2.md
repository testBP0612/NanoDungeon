# 任務卡 15 — GAME FEEL PASS 2（情緒曲線：命中重音與累積爬升）

> 打磨軌道（第二輪）。先讀 `Codex/00_MASTER_PROMPT.md`。
> 來源：`Reviews/01_GAME_FEEL_REVIEW.md`（14 卡里程碑後的 Reviewer 回望）。
> 目標：**把「情緒曲線」從高原改成上坡**——給命中一個重音（hitstop）、讓不同 Peg 有不同身體感（查表分級）、讓累積感跨球升溫（round heat）。**不加玩法、不碰美術、不改任何平衡數值。**
>
> 排程：Phase 14 之後。本卡只做 Review 的 **P0 三項**；P1/P2 留待後續卡片。

---

## 核心紀律

- **純表現層**：本卡只做視覺 / 聽覺 / 時間節奏回饋，**不得改動任何玩法數值或規則**（傷害、HP、倍率、抽取、球池、敵人皆不變）。
- **資料化**：所有新增的時間 / 強度 / 開關 / 分級參數一律進 `Data/feel.json`。
- **查表優先，嚴禁分支**：Peg 個性化回饋一律以 `peg_id` 查表取得，**不得**新增 `if peg_id == ...` 的回饋分支（`Peg.gd` 既有 `_color_for_peg` 的 match 已是唯一允許的對照點，勿長出第二個）。
- **不開新節點**：combo / heat 一律沿用 `round_context` + `BattleFX`，**不得**為此新增 manager 節點或 autoload。
- **穩定優先**：hitstop 不得卡住狀態機、不得拖垮幀率、可被關閉（`enabled` 開關）；一整局（5 場 + 4 次升級）仍須穩定跑完。

## 先處理：未決項（依 SOP step 3，不得阻塞）

本卡含三個「規格未明、實作必須選一個」的點。**依 `00_MASTER_PROMPT.md` SOP step 3 處理，不要停下等待：**

1. 在 `OPEN_QUESTIONS.md` 各新增一條 Q（用該檔模板，附**背景 / 選項 / 你的建議 / 影響範圍**）：
   - **Q-A（Hitstop 節奏）**：是否引入全域 hitstop？凍結時長上限為何（須守一局 5–10 分鐘節奏，建議單次 ≤ 0.08s）？是否依 peg 傷害分級？
   - **Q-B（跨球累積熱度）**：是否新增「回合層級熱度」視聽爬升？此為純表現，但改變回合內情緒節奏，須確認不偏離 `Docs/02_GAME_DESIGN.md` 的「回合一次結算」精神。
   - **Q-C（feel.json schema 擴張）**：新增 `hitstop` / `peg_feel` / `round_heat` 區塊屬**新欄位結構**（權限矩陣 🔶 需提案）。
2. 對每條 Q **採用你的建議作為 `⚠️ 暫行假設`** 並於 Q 內明確標記，據此繼續實作。**不得**以暫行假設改寫 `Docs/` 或當成既定規格。
3. 於 `CHANGELOG.md` 留痕新增的 Q 題號。

## 任務範圍（要做 — Review P0）

### P0-1 全域 Hitstop（命中重音）
- `feel.json` 新增 `hitstop` 區塊：`enabled` / `base_seconds` / `time_scale`（凍結時的時間倍率）/ 依 peg 傷害的分級乘數（或併入下方 `peg_feel`）。
- `BattleFX` 新增單一入口（如 `apply_hitstop(scale)`）：以 `Engine.time_scale` 短暫降速再回 1.0，**單點實作、全域復用**。
- 在 `Battle.gd` `_on_ball_peg_hit` 命中時觸發，**時長依該 peg 分級**（normal 幾乎無感、burst 明顯、overkill 最重）。
- 約束：不得用 `await` 卡住狀態機；多次命中疊加須安全（不可累積成長凍結）。

### P0-2 Peg 回饋查表分級（身體感差異化）
- `feel.json` 新增 `peg_feel` 查表（key = peg_id）：每 peg 可配 `shake_mult` / `hitstop_mult` / `sfx_freq`（或 pitch 乘數）/ `flash_seconds` / `particle_scale`。
- 將 `Battle.gd:594` 的 `start_hit_shake()` 與 `Battle.gd:597` 的 `play_sfx("hit", ...)` 改為**吃 peg 查表乘數**；`Peg.gd` `play_hit_feedback()` 的白閃時長改吃 `flash_seconds`。
- 目標體感：`burst_peg` 像打鼓、`normal_peg` 像雨滴；缺值時回退到現有預設（不得因缺 key 崩潰）。

### P0-3 跨球累積熱度（round heat）
- `feel.json` 新增 `round_heat` 區塊：`enabled` / 由 `damage_accumulator`（或跨球累計命中數）映射的爬升曲線參數（如 audio pitch 漸升、場邊框輝度漸強）。
- 在 `round_context` 沿用既有 `damage_accumulator`（**不新增規則欄位**），由 `BattleFX` 將其比值映射為**漸強的視聽通道**，使回合內「越打越熱」。
- combo 仍每球重置（既有行為不變）；heat 是**回合層級**、跨球延續，**純表現、不得成為傷害**。

## 不做範圍（嚴禁）

- ❌ 不加任何玩法 / 種類 / 機制；不改傷害、HP、倍率、抽取、球池、敵人等規則與數值。
- ❌ 不做美術素材；不碰立繪 / icon / 背景。
- ❌ hitstop / heat / peg_feel **不得**成為傷害或機制加成（純表現）。
- ❌ 不做 Review 的 P1 / P2 項（敵人飛行反應、結算因果、Boss 舞台、降基線噪音等）——留待後續卡片。
- ❌ 不寫死數值；不開新 manager 節點；不長出第二個 peg 分支 match。

## 預期產出

- `Data/feel.json`：新增 `hitstop` / `peg_feel` / `round_heat` 區段。
- `Scripts/BattleFX.gd`：`apply_hitstop()`、peg 查表回饋接線、round heat 視聽爬升。
- `Scripts/Battle.gd`：命中時觸發 hitstop 與查表回饋的時序接線（不改規則）。
- `Scripts/Peg.gd`：`play_hit_feedback()` 吃 `flash_seconds`（仍純表現）。
- `OPEN_QUESTIONS.md`：新增 Q-A / Q-B / Q-C（含建議與暫行假設標記）。
- 更新 `CHANGELOG.md`、產出 / 更新 `PROGRESS_REPORT.md`、`WORK_PLAN.md`。

## 驗收條件（DoD）

- [ ] 命中有可感知頓挫；`burst_peg` 明顯重於 `normal_peg`；可由 `feel.json` 關閉 hitstop。
- [ ] 不同 Peg 的 shake / 音色 / 閃光 / 粒子有可辨差異，且全部來自 `feel.json` `peg_feel` 查表（無新 `if peg_id` 分支）。
- [ ] 回合內可感受到跨球「越打越熱」的視聽爬升；新球不會把熱度打回原點（combo 仍每球重置）。
- [ ] 傷害公式 / 平衡完全未變（可驗證：同輸入命中序列的 `damage_accumulator` 與改動前一致）。
- [ ] Q-A / Q-B / Q-C 已寫入 `OPEN_QUESTIONS.md`，含建議並標記 `⚠️ 暫行假設`。
- [ ] 關掉 SFX 仍正常；hitstop 不卡狀態機；幀率穩定；一整局可穩定跑完。
- [ ] Godot 載入無錯、`Data/*.json` 解析通過、export 在既有解析度可獨立執行。

## 禁止事項

- ❌ 不得以打磨之名改動任何玩法數值 / 規則。
- ❌ 不得讓 hitstop / heat / peg_feel 變成傷害或機制。
- ❌ 不得寫死參數、不得新增 peg 回饋分支、不得新增 manager 節點。
- ❌ 不得做 P1 / P2；如需擴張先回 `OPEN_QUESTIONS.md` 提案。

## 完成後

- 依本卡 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 回報：做了什麼、Q-A/B/C 的建議與暫行假設、驗收結果、建議下一張卡（Review P1：敵人存在感與結算因果）。
- 提醒人類：hitstop 時長與 heat 強度是**體感項**，務必實機驗收，可只調 `feel.json` 微調快慢 / 強弱。
