# 任務卡 19 — PLUNGER：柱塞集氣演出 + Skill-shot（手感層）

> 核心機制大改（第 2/2 張）。先讀 `Codex/00_MASTER_PROMPT.md`。
> 依據：`OPEN_QUESTIONS.md` **Q-033（人類決議 B：柏青哥柱塞 skill-shot）**。前置：卡 18 的場地 / 軌道 / 上射地基已跑通。
> 分支：`feature/pinball-table-rework`。
> 目標：把柱塞發射做到**爽**——蓄力手感、放開的衝擊回饋、**力道→灑下入口的 skill-shot 映射**、力道 / 軌跡預覽。
>
> 本輪優先級：**演出爽度 > 數值保守**（人類已聲明，數值由人類後續微調；你把表現層做滿、全資料化、可回退）。

---

## 核心紀律

- **承接卡 18**：只接玩家集氣與演出，不重做場地幾何（除非為 skill-shot 必要的微調，且須資料化）。
- **力道是唯一主控軸**：不得引入頂部瞄準方向控制（Q-033 已排除）。
- **資料化**：蓄力時間 / 力道區間 / 入口映射 / 演出參數一律進 `Data/player.json` / `Data/feel.json`。
- **不改玩法規則**：傷害 / HP / 球數 / 倍率 / 抽取 / 敵人 / 結算不變。skill-shot 只改「球從哪進場」，不改傷害公式。

## 任務範圍（要做）

1. **柱塞集氣手勢**（`Scripts/Battle.gd`）：
   - 按住（左鍵 / 空白）→ 柱塞下拉蓄力、力道上升；放開 → 以當前力道上射。單一空間手勢，**無擺動 timing 條**。
   - 力道區間取 `Data/player.json`（如 `plunger_power_min/max`）；蓄力速度資料化。
2. **力道 → 入口 Skill-shot 映射**：
   - 力道大小映射到球從頂端**灑下的入口 / 車道 / 高度**（資料化映射表或曲線於 `field.json` / `player.json`）。
   - 讓玩家「灑下之前」就能憑力道規劃大致落點；映射須直覺、可預期。
3. **力道 / 軌跡預覽**（`Scripts/BattleFX.gd` / overlay）：
   - 蓄力時顯示力道強度（柱塞拉伸 / power bar）與**預估上射 + 灑下軌跡**預覽；參數進 `Data/feel.json`。
4. **發射演出（juice）**：
   - 柱塞下拉 / 彈回動畫、放開瞬間的衝擊（後座、閃光、粒子，可複用既有 `play_launcher_recoil` / 粒子）；
   - 可與卡 15 的 hitstop / round heat 協同，但**不得**改既有傷害或 hitstop 規則。
   - 集氣 SFX 音高隨力道漸強（沿用既有 SFX 管線）。

## 不做範圍（嚴禁）

- ❌ 不引入頂部瞄準方向控制或拉弓等 Q-033 已排除的模型。
- ❌ 不改傷害 / HP / 球數 / 倍率 / 抽取 / 敵人 / 結算規則與數值。
- ❌ skill-shot 不得變成傷害加成；它只影響「進場入口」。
- ❌ 不寫死力道 / 映射 / 演出數值；一律進 `Data/*.json`。
- ❌ 不在 main 上做。

## 預期產出

- `Data/player.json`：`plunger_power_min/max`、蓄力速度等。
- `Data/field.json` / `Data/player.json`：力道→入口映射參數。
- `Data/feel.json`：柱塞演出、power/軌跡預覽、集氣 SFX 參數。
- `Scripts/Battle.gd`：集氣手勢輸入、力道→入口映射接線。
- `Scripts/BattleFX.gd`：柱塞演出、力道/軌跡預覽。
- `Scenes/Battle.tscn`：柱塞視覺 / power 預覽節點（如需）。
- 更新 `CHANGELOG.md`、`PROGRESS_REPORT.md`、`WORK_PLAN.md`。

## 驗收條件（DoD）

- [ ] 按住蓄力、放開上射為單一空間手勢，無擺動 timing 條；力道區間來自 `player.json`。
- [ ] 力道明顯影響球灑下的入口 / 落點，且可預期（skill-shot 成立）。
- [ ] 蓄力有力道 / 軌跡預覽；放開有明確衝擊演出（後座 / 閃光 / 粒子 / SFX 漸強）。
- [ ] 傷害 / 平衡 / 結算 / overload / hitstop 規則完全未變；一整局可穩定跑完。
- [ ] 所有力道 / 映射 / 演出數值來自 `Data/*.json`；Godot 載入無錯、`Data/*.json` 解析通過。

## 禁止事項

- ❌ 不得復活方向瞄準或偏離 Q-033。
- ❌ 不得讓 skill-shot / 演出變成傷害或機制。
- ❌ 不得改玩法數值 / 規則、不得在 main 上提交。

## 完成後

- 依 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 回報：柱塞手感是否爽、skill-shot 是否直覺可預期、演出是否到位、最終力道 / 映射數值、建議下一張卡。
- 提醒人類：集氣力道區間與入口映射是體感項，務必實機驗收；數值可只調 `Data/*.json`。
