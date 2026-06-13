# 任務卡 08 — LAUNCH & TUNING（集氣發射、底排 bumper、保底倍傷釘）

> 可玩性擴充軌道。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：三項手感 / 策略強化——**底排主動 bumper、集氣發射 + 拋物線瞄準、double_peg 每回合保底數量 + 對應升級**。
>
> 排程：Phase 7（程序生成釘盤）之後。決策依據見 OPEN_QUESTIONS **Q-018 / Q-019 / Q-020**（皆已決議）。

---

## 功能 1：底排 bounce_peg 改為主動 bumper（Q-018）

- 底部固定排（`bounce_peg`）命中時，**主動把球的反彈速度乘上可調倍率**（預設 `2.0`），做出「強力彈跳台」手感。
- 數值資料化：在 `field.json` 的 `bottom_row` 增加 `bounce_multiplier`（預設 2.0）。
- 實作要點：
  - 物理彈性係數無法 >1，需主動加力。建議在 Ball 偵測命中底排 bounce peg 後，取碰撞後（或反射後）速度方向，將**速度大小 × bounce_multiplier** 再 set 回 `linear_velocity`；或沿碰撞法線施加額外 impulse。
  - **必須設速度上限**（如 `max_ball_speed`，放 `player.json` 或 `field.json`），夾住放大後速度，避免穿透牆 / 釘或飛出場地；保留既有 CCD。
  - 僅底排 bounce peg 有此效果；其他 bounce / 一般釘不變。
- bounce peg 仍**無傷無效果**（只有物理 + 既有命中回饋），不產生傷害數字。

## 功能 2：集氣發射 + 拋物線瞄準（Q-019）

- **瞄準**：保留滑鼠瞄方向；把 `AimLine` 由直線改為**拋物線弧線預覽**，依「當前 power 換算的初速 + 重力」模擬數段軌跡點繪出弧線（球落點預測）。
- **集氣表**：
  - 新增可見的 power 表（UI），數值在 **0 → 100 → 0 之間來回擺動**。
  - 操作：在 AIMING 狀態，第一下**左鍵或空白鍵**開始集氣（表開始擺動）；第二下（同為左鍵或空白鍵）以**當前 power 值發射**。
  - power 映射到初速：`launch_speed = lerp(launch_speed_min, launch_speed_max, power/100)`。
  - 集氣擺動週期時間資料化（`charge_cycle_seconds`）。
- **資料化**：在 `player.json` 新增 `launch_speed_min`、`launch_speed_max`（取代或衍生既有 `launch_speed`）、`charge_cycle_seconds`。弧線預覽取樣點數可放 `feel.json`。
- **流程**：仍逐顆發射；發射後回 AIMING 等下一顆；集氣狀態在球飛行 / 結算時不接受輸入（沿用既有 state 守門）。
- 邊界：發射前未集氣不應誤射；連點不應跳過集氣；球飛行中按鍵無效。

## 功能 3：double_peg 每回合保底數量 + 升級（Q-020）

- 每回合重抽動態釘時，**保證固定 `guaranteed_double_peg_count`（預設 2）顆 `double_peg`** 出現：先在動態骨架隨機保留該數量的槽位指定為 double_peg，其餘槽位再照 `type_weights` 抽。
- `guaranteed_double_peg_count` 預設值放 `field.json`（generator 區）；整局可被升級提升的部分由 `RunState` 持有（初始化為該預設值）。
- **新增升級**（`upgrades.json`）讓保底數 +1，例如：
  ```json
  { "id": "up_guaranteed_double", "name": "倍率增殖 Multiplier Surge", "description": "每回合場上保證的倍傷釘 +1。", "target_type": "stat", "target_id": "guaranteed_double_peg", "effect_type": "add", "effect_value": 1, "rarity": "legendary" }
  ```
  - `Data/upgrades.json` 的 `_meta.stat_targets` 增加 `guaranteed_double_peg`。
  - `UpgradeResolver._apply_stat_upgrade` 與 `RunState` 增加對應處理（整局成長、`reset_new_run` 歸零回預設）。
  - 建議設合理上限（避免保底數超過可用骨架槽位 / 數值爆炸），上限值可放 `field.json` 或 `RunState` 常數。

## 不做範圍（嚴禁）

- ❌ 不新增球 / 敵人 / 釘子「種類」（double_peg、bounce_peg 皆既有）。
- ❌ 不做漸變特效、不擾動位置骨架、不實作連鎖釘 / 連射球 / flippers。
- ❌ 不改傷害結算公式、敵人、Shield/Blast 等既有規則（本卡只動發射、底排物理、釘子保底數）。
- ❌ 不把可調數值寫死（倍率、速度上下限、集氣週期、保底數、上限皆進 JSON）。

## 預期產出

- `Data/field.json`：`bottom_row.bounce_multiplier`、generator `guaranteed_double_peg_count`、（如需）`max_ball_speed`。
- `Data/player.json`：`launch_speed_min/max`、`charge_cycle_seconds`。
- `Data/upgrades.json`：新增「保底倍傷釘 +1」升級 + `stat_targets` 更新。
- `Scripts/Ball.gd`：底排 bumper 加速 + 速度上限；power 初速發射。
- `Scripts/Battle.gd`：集氣 state / 輸入兩段化、power 表更新、拋物線瞄準預覽。
- `Scripts/FieldGenerator.gd`：保底 double_peg 槽位保留。
- `Scripts/RunState.gd` / `UpgradeResolver.gd` / `DataLoader.gd`：保底數成長與 stat target。
- `Scenes/Battle.tscn`：power 表 UI、AimLine 改弧線。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）

- [ ] 球碰底排會明顯加速反彈（約 ×2，可由 `field.json` 調），且不會穿透 / 飛出（速度上限生效）。
- [ ] 瞄準顯示拋物線弧線；集氣表在 0→100→0 來回；左鍵或空白鍵第一下集氣、第二下發射。
- [ ] power 高低確實改變初速 / 射程；未集氣不誤射、球飛行中輸入無效。
- [ ] 每回合場上保證有 `guaranteed_double_peg_count`（預設 2）顆 double_peg。
- [ ] 新升級可讓保底數 +1，套用後後續回合確實多 1 顆，且重新開始歸零。
- [ ] 升級抽取仍遵守 Q-004/005（權重、排重、精英保底、上限排除）。
- [ ] 所有新數值來自 JSON；位置骨架仍固定、不生成卡球 / 全漏盤。
- [ ] Godot 載入無錯、`Data/*.json` 解析通過、export 在 1024×1024 可獨立執行。
- [ ] 一整局（5 場 + 4 次升級）仍可穩定跑完。

## 禁止事項

- ❌ 不得讓 bumper 放大速度造成穿透 / 卡死（必夾上限）。
- ❌ 不得保留舊的「點一下即發射」而與集氣流程衝突（須整合為兩段式）。
- ❌ 不得新增種類、不得改既有傷害 / 敵人 / 升級規則（除本卡指定的新升級）。
- ❌ 不得偏離 Q-018/019/020；如需調整先回 `OPEN_QUESTIONS.md` 提案。

## 完成後

- 依本卡 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 提醒人類：集氣手感、bumper 力道、保底倍傷釘都會改變輸出與節奏，**務必實機驗收**並可只調 JSON 微調（集氣週期、speed_min/max、bounce_multiplier、guaranteed 數）。
