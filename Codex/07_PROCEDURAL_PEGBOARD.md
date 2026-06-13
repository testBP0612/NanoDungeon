# 任務卡 07 — PROCEDURAL PEGBOARD（程序生成釘盤與每回合重組）

> 可玩性擴充軌道。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：**把釘盤從手列座標改為參數化程序生成，並在每個玩家回合機率性重抽釘子類型**，營造柏青哥釘盤的亂彈趣味與賽博「自我重構」主題。
>
> 排程：Phase 6（佈局資料化）之後。決策依據見 OPEN_QUESTIONS **Q-015 / Q-016 / Q-017**（皆已決議）。

---

## 背景

現況：`Data/field.json` 為**手列的固定座標清單**，`Battle._spawn_pegs()` 於 `_ready` 一次生成，整局不變。
目標：改為**公式生成 + 每回合重抽類型**，並拉高場地、新增純反彈釘與固定底排。

## 任務範圍（要做）

### 1. `field.json` 改為參數化（取代手列座標）
建議 schema（可微調，需 `DataLoader` 驗證）：
```json
{
  "field": {
    "bounds": { "left": 196, "right": 828, "top": 72, "bottom": 960 },
    "default_peg_radius": 9,
    "generator": {
      "top_y": 210,
      "row_count": 9,
      "row_spacing": 64,
      "wide_cols": 5,
      "narrow_cols": 4,
      "col_spacing": 88,
      "center_x": 512,
      "type_weights": { "normal_peg": 60, "heal_peg": 22, "burst_peg": 10, "double_peg": 8 },
      "special_radius": { "burst_peg": 8, "double_peg": 7 },
      "reroll_each_round": true,
      "seed": null
    },
    "bottom_row": { "id": "bounce_peg", "y": 900, "count": 7, "radius": 9 }
  }
}
```
- **位置骨架由公式算**（交錯梅花樁）：寬排 `center_x + (i-(wide_cols-1)/2)*col_spacing`，窄排錯開半格；`y = top_y + row*row_spacing`，寬窄排交替。
- `type_weights` 僅含 Normal/Heal/Burst/Double（**不含 bounce**）。
- `seed: null` → 每回合隨機；給定整數 → 可重現（展示用）。

### 2. 新增 `FieldGenerator`（程序生成器）
- 新增 `Scripts/FieldGenerator.gd`（或併入 DataLoader 的純函式區），依 `generator` 參數**算出骨架座標**（與類型無關）。
- 提供「依權重為每個骨架節點抽一個類型」的函式（Bounce 不在池內）。
- 底排（`bottom_row`）座標固定、類型固定為 `bounce_peg`，**不參與重抽**。
- 邏輯與繪製分離：生成器只算資料，不碰節點。

### 3. 每回合重抽類型（位置骨架固定）— Q-015
- 在 `Battle` 的 **ROUND_START** 重抽骨架節點的類型並更新場上釘子（底排不變）。
- **位置骨架整局固定不變**（只有類型/顏色換），確保物理可預期、不生成卡球/全漏盤。
- 重抽可重用既有 Peg 節點（呼叫 `configure` 換類型/半徑）或清空重建，擇一；底排 bounce 維持。
- 若 `seed` 有值，使用可重現亂數；否則每回合隨機。

### 4. 新增 `bounce_peg`（第 5 種釘，僅底排）— Q-016
- `Data/pegs.json` 新增：
  ```json
  { "id": "bounce_peg", "name": "反彈釘 Bounce Peg", "description": "純反彈節點，無傷害無效果，只改變球路徑。", "base_damage": 0, "effect_type": "none", "effect_value": 0 }
  ```
- `EffectResolver` 對 `effect_type: "none"` 回傳空結果（命中只有物理反彈與輕量回饋，無傷/無回血/無倍率/無浮動傷害數字）。
- **僅用於底部固定排**，不進每回合隨機池。

### 5. 場地拉高至 1024×1024 — Q-017
- 設定 `project.godot` 的 viewport / window 為 **1024×1024**（維持寬度、加高）。
- 連動調整並保持等價行為：
  - `Battle.tscn` 牆（左/右/上）、`BottomSensor`（移到場地底部新 y）、`Launcher`（維持頂部中央 512,118）。
  - `field.json` 的 `bounds.bottom` 配合加高（建議 ~960），底排 y 在其上方。
  - `BattleUI` 錨點：HP/狀態/按鈕重新定位以適配新高度（StatusLabel 仍在底部、結束按鈕仍置中可見）。
  - `BattleCamera` 置中於新場地中心。
  - `export_presets.cfg`：確認匯出解析度一致。
- `MainMenu` / `GameOver` / `Victory` 若有絕對座標，檢查在 1024×1024 下版面正常。

## 不做範圍（嚴禁）

- ❌ 不做漸變 / 類型切換特效（本輪人類未選；留待後續）。
- ❌ 不把 bounce_peg 放進每回合隨機池（只當底排）。
- ❌ 不擾動位置骨架（只重抽類型；位置整局固定）。
- ❌ 不新增除 bounce_peg 以外的釘 / 球 / 敵人種類；不做連鎖釘、連射球。
- ❌ 不改傷害結算、升級、敵人等既有規則（只動生成與場地）。
- ❌ 不做「每層不同佈局」以外的內容擴張（本卡仍是單一參數套全場次；每層差異未決議）。

## 預期產出

- 參數化的 `Data/field.json`（generator + bottom_row）。
- `Scripts/FieldGenerator.gd`（座標與類型抽取）。
- `Battle.gd` ROUND_START 重抽接線；`Peg`/`EffectResolver` 支援 `bounce_peg`。
- `Data/pegs.json` 新增 `bounce_peg`。
- `project.godot` / `Battle.tscn` / `export_presets.cfg` 的 1024×1024 調整。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）

- [ ] 釘盤位置由公式生成，`field.json` 改參數即改變佈局（毋需改程式）。
- [ ] 每回合釘子**類型**會依權重重抽且可見變化；**位置骨架整回合固定不變**。
- [ ] 底部固定一排 `bounce_peg` 永遠存在、不參與重抽。
- [ ] `bounce_peg` 命中只反彈，無傷/無回血/無倍率/無傷害數字。
- [ ] 視窗為 1024×1024；launcher/牆/落底/UI/camera 在新高度下正常，流程不崩。
- [ ] 給定 `seed` 時佈局可重現；`null` 時每回合隨機。
- [ ] 不會生成卡球 / 整盤漏球（骨架固定 + 8 秒超時保險仍在）。
- [ ] Godot 載入無錯；`Data/*.json` 解析通過；export 在新解析度可獨立執行。
- [ ] 一整局（5 場 + 4 次升級）仍可穩定跑完。

## 禁止事項

- ❌ 不得保留手列釘子座標於程式或 `field.json`（改為參數生成）。
- ❌ 不得讓重抽改變位置骨架或破壞物理穩定性。
- ❌ 不得偏離 Q-015 / Q-016 / Q-017；如需動其他規格先回 `OPEN_QUESTIONS.md` 提案。

## 完成後

- 依本卡 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 提醒人類：每回合重抽 + 新高度屬手感/平衡敏感改動，**務必實機驗收**（亂彈手感、漏球率、整局輸出、Boss 可達性）。
