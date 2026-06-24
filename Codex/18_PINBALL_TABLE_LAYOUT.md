# 任務卡 18 — PINBALL TABLE：場地重構與發射軌道（地基）

> 核心機制大改（第 1/2 張）。先讀 `Codex/00_MASTER_PROMPT.md`。
> 依據：`OPEN_QUESTIONS.md` **Q-033（人類決議 B：柏青哥柱塞 skill-shot）**，取代 Q-031。Docs/01、Docs/02 已同步更新。
> 分支：`feature/pinball-table-rework`（不在 main 上做）。
> 目標：把「頂部置中、球往下掉」改成「**真實彈珠台**」——右下柱塞、右側上射軌道、頂端導引入場、重力傾瀉、底部 drain。**本卡只把地基跑通：能穩定上射 → 灑下 → 回收。柱塞集氣演出與 skill-shot 映射屬卡 19。**

---

## 核心紀律

- **先求穩，再求爽**：本卡 DoD 是「球能穩定從右下上射、繞到頂端散入釘海、向下傾瀉、由底部回收，整局可跑完」。手感 / 演出留卡 19。
- **資料化**：所有幾何 / 物理 / 力道參數進 `Data/field.json` / `Data/player.json`，程式不得寫死座標與數值。
- **不改玩法規則**：傷害、HP、球數、倍率、抽取、敵人、結算時機一律不變；只改「球如何進場」與場地佈局。
- **保留既有系統接點**：peg 命中、re-hit cooldown、combo、結算、overload、hitstop 等既有邏輯不得破壞。

## 任務範圍（要做）

1. **場地重定向**（`Data/field.json`）：
   - 在 `field` 內新增 `launch_lane`（右側發射軌道）與 `plunger`（右下柱塞）區段：位置、寬度、軌道上下界、頂端導引壁（deflector）幾何，全部資料化。
   - 調整 `bounds` / `generator`，讓**釘海主體佔中央**、**右側清出一條無釘發射軌道**。
2. **FieldGenerator 讓道**（`Scripts/FieldGenerator.gd`）：
   - 釘盤生成時排除右側 `launch_lane` 範圍，不在軌道內長釘；底排 `bounce_peg` 與既有重抽邏輯保留。
3. **發射器搬家與上射物理**（`Scripts/Battle.gd`）：
   - `launcher_position` 由頂部置中（現 `816,118`）移到**右下柱塞口**（取自 `field.json`）。
   - 發射初速方向改為**沿軌道向上**；球上射、到頂端經導引壁撥入釘海、再受重力向下傾瀉。
   - 固定一個「本卡測試用」發射力道（卡 19 才接玩家集氣），確保物理鏈穩定。
4. **進場導引與牆體**（`Scenes/Battle.tscn` / 程式生成擇一，與現有架構一致）：
   - 右側軌道牆 + 頂端單向導引壁，讓球順順上去、不卡、不從軌道直接掉回。
5. **回收 / drain**：沿用底部 sensor 回收；確認新佈局下球最終都會落底回收、不會永久卡在軌道或頂端。

## 不做範圍（嚴禁）

- ❌ 不做柱塞集氣手感、蓄力動畫、力道→入口 skill-shot 映射、力道/軌跡預覽（全屬卡 19）。
- ❌ 不改傷害 / HP / 球數 / 倍率 / 抽取 / 敵人 / 結算規則與數值。
- ❌ 不寫死座標 / 力道 / 幾何；一律進 `Data/*.json`。
- ❌ 不破壞既有 peg 命中 / combo / overload / hitstop / 結算流程。
- ❌ 不在 main 上做；限 `feature/pinball-table-rework`。

## 預期產出

- `Data/field.json`：`launch_lane` / `plunger` / 導引壁幾何、`bounds` / `generator` 調整。
- `Data/player.json`：上射用發射力道參數（如 `plunger_launch_speed`，本卡先固定值）。
- `Scripts/FieldGenerator.gd`：右側軌道讓道。
- `Scripts/Battle.gd`：發射器位置 / 上射方向 / 物理鏈接線。
- `Scenes/Battle.tscn`：軌道牆 + 頂端導引壁（或程式生成）。
- 更新 `CHANGELOG.md`、`PROGRESS_REPORT.md`、`WORK_PLAN.md`。

## 驗收條件（DoD）

- [ ] 球從右下柱塞口以資料化力道**穩定上射**，沿右側軌道到頂端、經導引壁散入釘海。
- [ ] 球向下傾瀉穿過釘海、正常觸發既有 peg 效果與 combo，最終由底部 drain 回收。
- [ ] 右側軌道內無釘子；釘海主體置中；底排 bounce_peg 與每回合重抽仍正常。
- [ ] 球不會卡在軌道 / 頂端 / 任何死角；一整局（5 場 + 4 升級）可穩定跑完。
- [ ] 所有幾何 / 物理 / 力道來自 `Data/*.json`，程式未寫死。
- [ ] 既有傷害 / 平衡 / 結算 / overload / hitstop 流程未被破壞；Godot 載入無錯、`Data/*.json` 解析通過。

## 禁止事項

- ❌ 不得做卡 19 的集氣演出 / skill-shot。
- ❌ 不得改玩法數值 / 規則。
- ❌ 不得在 main 上提交。
- ❌ 偏離 Q-033 或想擴張，先回 `OPEN_QUESTIONS.md` 提案。

## 完成後

- 依 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 回報：上射 → 傾瀉 → 回收是否穩定、軌道幾何最終數值、任何卡球風險、建議卡 19 的集氣 / skill-shot 切入點。
- 提醒人類：幾何與物理為體感項，務必實機驗收；數值可只調 `Data/*.json`。
