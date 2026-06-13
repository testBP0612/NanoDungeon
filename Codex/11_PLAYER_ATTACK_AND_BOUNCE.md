# 任務卡 11 — PLAYER ATTACK & BOUNCE（斬殺、玩家攻擊演繹、彈跳手感）

> 可玩性擴充 / 打磨軌道。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標三項：**① 回合內達標即斬殺（OVERKILL）、② 玩家造成傷害的攻擊演繹、③ 釘子彈跳手感參數化**。
>
> 排程：Phase 10 之後。決策依據見 OPEN_QUESTIONS **Q-023 / Q-024 / Q-025**（皆已決議）。
>
> ⚠️ 紀律：演出**純程序化**（不依賴外部素材）；數值全進 JSON；**不改傷害公式結構、不新增種類**；用詞賽博化，不出現柏青術語。

---

## 功能 1：斬殺 / 強制清除（OVERKILL）— Q-023

- 回合進行中，每次命中累積傷害後檢查：**當前累積傷害（含過載倍率）≥ 敵人當前 HP** → 立即觸發斬殺。
- 斬殺流程：
  - 停止接受發射、回收 / 清除場上飛行球（沿用既有 recover 流程，確保不殘留）。
  - 直接結算讓敵人 HP 歸零 → 進入既有 CHECK → REWARD / VICTORY 分支。
  - 播放賽博爆閃 cut-in（文字如「OVERKILL / 強制清除」），純程序化（ColorRect flash + 大字 `Tween` + camera punch + 粒子，沿用 BattleFX）。
- 參數（`Data/player.json` 的 `execute` 區段或等義位置）：
  - `enabled`（預設 true）。
  - 判定基準預設為「累積傷害 ≥ 敵人當前 HP」；如需緩衝可加 `margin`（預設 0）。
- 邊界：斬殺與「所有球落底才結算」互斥——一旦斬殺就不再等落底；過載 / blast 等不得造成重複結算或狀態殘留。
- cut-in FX 強度參數放 `feel.json`。

## 功能 2：玩家攻擊演繹 — Q-024

- 在**結算對敵人造成傷害時**（含斬殺），播放玩家攻擊演繹，與敵人攻擊三拍對稱：
  - **匯聚**：能量在發射區 / 場地底部短暫匯聚（粒子收束）。
  - **射出**：一道**光束 / 能量彈**從玩家側飛向敵人（`Line2D` 漸現的光束，或一顆發光 `Node2D` + 拖尾 `Tween` 位移）。
  - **命中**：接既有敵人受擊回饋（閃白 / 抖動 / 傷害數字 / 粒子）。
- **強度隨本回合傷害放大**（線寬 / 粒子量 / 亮度 / 數字大小），讓大傷害的一擊更有份量。
- 過載中可用更強配色（金色）呼應。
- **純程序化**：`Line2D` + `GPUParticles2D` + `Tween` + 既有 SFX；**不需任何 PNG / 外部資源**。
- 時序需與 Phase 9 的回合 beats / count-up 相容（建議：count-up 與光束命中對齊，數字在命中時跳出）。
- 參數放 `feel.json` 的 `player_attack` 區段（匯聚時間、射出時間、線寬、顏色、粒子量、scale-by-damage 係數）。

## 功能 3：釘子彈跳手感 — Q-025

- 新增 `peg_bounce_boost`（**一般釘**命中時，將反彈後速度小幅加乘，預設約 `1.15`），讓彈跳更脆更爽。
  - 套用範圍：一般動態釘（normal/heal/burst/double）；**底排 bounce_peg 維持自己的 `bounce_multiplier`（2.0）不變、不疊加本 boost**。
  - **必須夾速度上限**（沿用 / 共用 `max_ball_speed`），保留 CCD，避免穿透 / 飛出。
- 開放 `ball_bounce`（`player.json`）作為整體彈性微調。
- 實作位置：`Ball.gd` 命中一般釘時套用 boost（與底排 bumper 分流處理）。
- 參數放 `player.json`（彈跳屬物理 / 手感數值）。

## 不做範圍（嚴禁）

- ❌ 不新增 Peg / Ball / Enemy 種類；不改傷害公式結構（斬殺只是提早結算，傷害值不變）。
- ❌ 不依賴外部美術素材（攻擊演繹 / cut-in 全程序化）。
- ❌ 不讓彈跳 boost 造成穿透 / 卡死（必夾上限 + CCD）。
- ❌ 不出現柏青術語；不為演出犧牲穩定 / export 可用性。

## 預期產出

- `Data/player.json`：`execute`（toggle/margin）、`peg_bounce_boost`、（如需）共用 `max_ball_speed`。
- `Data/feel.json`：`overkill_cutin`、`player_attack` 演出參數。
- `Scripts/Battle.gd`：命中後斬殺判定與提早結算分支；結算 / 斬殺時觸發玩家攻擊演繹（與 count-up 對齊）。
- `Scripts/BattleFX.gd`：OVERKILL cut-in、玩家攻擊光束 / 匯聚 / 命中演繹（程序化）。
- `Scripts/Ball.gd`：一般釘 `peg_bounce_boost` + 速度上限（與底排 bumper 分流）。
- `Scripts/DataLoader.gd`：驗證新參數。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）

- [ ] 回合內累積傷害 ≥ 敵人 HP 時立即斬殺，不等落底；場上球乾淨回收、無重複結算 / 殘留。
- [ ] 斬殺有 OVERKILL cut-in（程序化），並正確進 REWARD / VICTORY。
- [ ] 結算 / 斬殺時播放玩家攻擊演繹（匯聚→射出→命中），強度隨傷害放大，命中接既有敵人受擊回饋。
- [ ] 玩家攻擊與敵人攻擊在節奏上對稱、與 count-up 對齊、不卡狀態機。
- [ ] 一般釘彈跳明顯更脆（`peg_bounce_boost` 生效），底排 bumper 不受影響、不疊加；無穿透 / 飛出（上限 + CCD）。
- [ ] 所有新數值來自 JSON，手調即生效；可關閉斬殺。
- [ ] 演出純程序化、無外部素材；export（1024×1024）後正常、不掉幀。
- [ ] 既有玩法 / 平衡不被破壞；一整局（5 場 + 4 次升級）仍可穩定跑完。
- [ ] Godot 載入無錯、`Data/*.json` 解析通過、用詞無柏青術語。

## 禁止事項

- ❌ 不得讓斬殺造成重複結算 / 狀態殘留 / 跳過勝敗判定。
- ❌ 不得用外部素材冒充攻擊演繹；必須是可執行的程序化效果。
- ❌ 不得讓彈跳 boost 破壞物理穩定（必夾上限）。
- ❌ 不得偏離 Q-023/024/025；如需擴張先回 `OPEN_QUESTIONS.md` 提案。

## 完成後

- 依本卡 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 提醒人類：斬殺節奏、攻擊演繹強度、彈跳手感皆為體感項，**務必實機驗收**，並可只調 `player.json` / `feel.json` 微調。
