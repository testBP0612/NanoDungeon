# 任務卡 06 — FIELD LAYOUT（釘子佈局資料化與策略性）

> 可玩性調整軌道（非 polish、非美術）。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：**把釘子的位置與大小從程式碼搬進資料**，讓佈局可在不改程式的前提下反覆調整，並支援「逐顆不同大小」以做出策略性。
>
> 排程：**Phase 5 之後執行**（MVP 已完成）。本卡是行為可控的增量，不加新玩法機制、不改種類數量。

---

## 背景（為什麼有這張卡）

現況（對照碼）：
- 釘子**位置**寫死在 `Scripts/Battle.gd._spawn_pegs()` 的 `peg_slots` 陣列（8 個 `{id, position}`）。
- 釘子**大小**寫死在 `Scripts/Peg.gd` 的 `radius := 18.0`（與 `Scenes/Peg.tscn` 的 `CircleShape2D`），**全部釘子共用單一值**。

問題：佈局調整要改程式（違反資料驅動原則），且無法逐顆設定大小（策略性所需）。

⚠️ **必須處理的陷阱**：`Peg.tscn` 的 `CircleShape2D` 是 sub-resource，多個 Peg 實例**會共用同一份**。若直接對共用 shape 設 `radius` 做逐顆大小，會讓所有釘子一起變。實作時必須**為每顆 Peg 建立獨立的 `CircleShape2D`**（在 `Peg.configure` 內 `CircleShape2D.new()`），或設 `resource_local_to_scene = true`。碰撞半徑與繪製半徑必須一致。

## 任務範圍（要做）

### 1. 新增 `Data/field.json`（佈局資料化）
建議 schema（可微調，但需 `DataLoader` 驗證）：
```json
{
  "_meta": { "description": "彈珠場佈局：釘子位置與大小。座標為場地像素座標。" },
  "field": {
    "bounds": { "left": 196, "right": 828, "top": 72, "bottom": 680 },
    "default_peg_radius": 18,
    "layout": [
      { "id": "normal_peg", "x": 370, "y": 230 },
      { "id": "burst_peg",  "x": 512, "y": 230, "radius": 12 },
      { "id": "heal_peg",   "x": 654, "y": 230, "radius": 22 },
      { "id": "double_peg", "x": 440, "y": 340, "radius": 10 }
    ]
  }
}
```
- `radius` 為**每顆選填**，缺省則用 `default_peg_radius`。
- 初版 `layout` 請**沿用目前 8 顆的座標與類型**（行為等價起步），只是搬到資料；策略性微調交給人類在編輯器/JSON 反覆調。

### 2. `DataLoader` 載入與驗證
- 比照其他 JSON 載入 `field.json`，提供 `get_field_config()`。
- 驗證：`layout` 每項的 `id` 必須存在於 `pegs.json`；`x/y` 必須在 `bounds` 內；`radius`（若有）> 0。無效明確報錯。

### 3. `Battle.gd` 改讀資料生成釘子
- `_spawn_pegs()` 改為迭代 `field.json` 的 `layout`，移除寫死的 `peg_slots`。
- 將每顆的 `radius`（或 default）傳給 `Peg.configure`。

### 4. `Peg.gd` 支援逐顆大小（修共用 shape 陷阱）
- `configure` 接收 `radius` 參數，**建立獨立 `CircleShape2D`** 套用，繪製半徑同步。
- 移除寫死的 `radius := 18.0`（改由資料傳入）。

### 5. 策略性佈局（人類主導，AI 提供可調基礎）
本卡只需**讓佈局可調**並提供一組合理初版；「策略性」由人類在 `field.json` 反覆調整達成。可在 `field.json` 註解或 PR 說明附上設計原則供參考：
- 高價值釘（burst / double）放較難導球處（角落 / 被普通釘包圍），低價值（normal / heal）放好打的中上區。
- 用較小 `radius`（10–12）當技術門檻、較大（20+）當保底。
- 適度聚簇製造彈跳鏈（搭配既有 0.2s re-hit cooldown，不會無限刷）。
- 左右不對稱以製造「往左 vs 往右」的取捨。

## 不做範圍（嚴禁）

- ❌ 不新增 Peg / Ball / Enemy / 升級「種類」或新機制。
- ❌ 不做釘子耗損 / 消失、連鎖釘、移動釘（非目標）。
- ❌ 不改傷害 / 效果規則（只搬位置與大小到資料）。
- ❌ 不在本卡實作「每層不同佈局」——schema 可預留擴充，但 MVP 維持**單一基礎佈局套用全部場次**（每層變化見下方待決）。
- ❌ 不重構與佈局無關的模組。

## 預期產出

- `Data/field.json`（含初版佈局，等價於現有 8 顆）。
- `DataLoader` 的 `field.json` 載入與驗證。
- `Battle.gd._spawn_pegs` 改為資料驅動。
- `Peg.gd` / `Peg.tscn` 支援逐顆獨立半徑（修共用 shape 陷阱）。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）

- [ ] 釘子位置與大小完全來自 `Data/field.json`，`Battle.gd` / `Peg.gd` 無對應寫死值。
- [ ] 改 `field.json` 的座標 / 半徑後，重啟遊戲即反映，毋需改程式。
- [ ] 逐顆不同 `radius` 能正確生效，且**碰撞半徑與繪製半徑一致、各顆獨立**（無共用 shape 連動）。
- [ ] `DataLoader` 會驗證 id 存在、座標在 bounds 內、radius > 0，無效有明確錯誤。
- [ ] 初版佈局與調整前**行為等價可玩**（不崩潰、流程不變）。
- [ ] Godot 載入無腳本 / 場景錯誤；`Data/*.json` 解析通過。

## 禁止事項

- ❌ 不得保留任何寫死的釘子座標 / 半徑於程式碼。
- ❌ 不得用共用 sub-resource 套逐顆半徑（必須各自獨立）。
- ❌ 不得偏離已決議事項（Q-001~Q-013）；如需動玩法規則先回 `OPEN_QUESTIONS.md` 提案。

## 待人類決議（實作前確認）

- **Q-014（待你拍板）**：佈局是「**單一基礎套用全部場次**」（本卡 MVP 假設）還是「**每層 / 每場不同**（愈深愈刁鑽）」？後者屬內容擴張，需擴充 `field.json` schema（如 `by_battle_index` override）。本卡先以單一佈局實作，schema 預留擴充空間；若你要每層不同，請先決議再開後續卡。
