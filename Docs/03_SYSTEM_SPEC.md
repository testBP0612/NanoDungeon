# 03 — SYSTEM SPEC 系統規格

本檔給 Codex 實作參考：場景結構、狀態機、資料結構、JSON 使用原則、模組邊界。**為建議架構，非強制；若 Codex 有更穩定的等效做法，可在 `OPEN_QUESTIONS.md` 提出後採用，但不得偏離玩法規格（見 `02_GAME_DESIGN.md`）。**

---

## Godot 場景建議（Scene Tree）

採 2D，主入口場景之間用換場（`change_scene_to_file`）切換。

```txt
Main (autoload bootstrap 或第一個場景)
├── MainMenu.tscn            主選單（開始 / 離開）
├── Battle.tscn              戰鬥場景（核心）
│   ├── PinballField (Node2D)        彈珠場：邊界、釘子容器
│   │   ├── Walls (StaticBody2D)
│   │   ├── PegContainer (Node2D)    動態生成 Peg 實例
│   │   └── BottomSensor (Area2D)    落底偵測
│   ├── Launcher (Node2D)            瞄準與發射
│   ├── BallContainer (Node2D)       發射出的 Ball 實例
│   ├── EnemyDisplay (Node2D)        敵人立繪 + HP
│   ├── BattleUI (CanvasLayer)       玩家 HP、球數、回合傷害、回合數
│   └── BattleState (Node)           戰鬥狀態機（見下）
├── UpgradeScreen.tscn        三選一升級
├── GameOver.tscn             死亡結算
└── Victory.tscn              勝利結算
```

建議的可重用元件場景：
- `Peg.tscn`（`StaticBody2D` 或 `Area2D` + 視覺 + 粒子），以 `peg_id` 套用 `pegs.json` 數值。
- `Ball.tscn`（`RigidBody2D` 2D 物理），以 `ball_id` 套用 `balls.json`。

## 狀態機設計（Battle State Machine）

戰鬥用一個明確的有限狀態機（FSM），由 `BattleState` 管理。建議狀態：

```txt
INIT          載入敵人與場地、產生 Peg
ROUND_START   給球、重置回合倍率與傷害累計器
AIMING        等待玩家瞄準（可發射下一顆）
LAUNCHED      球在飛行中，累積命中傷害
SETTLE        所有球落底，套用結算（傷害、Blast 加成、Heal）
ENEMY_TURN    敵人存活 → 敵人攻擊玩家（套用 Shield 減傷）
CHECK         判定勝 / 敗 / 繼續
  → 玩家死 → GAME_OVER（切 GameOver.tscn）
  → 敵人死且為 Boss → VICTORY（切 Victory.tscn）
  → 敵人死非 Boss → REWARD（切 UpgradeScreen.tscn）
  → 都活著 → ROUND_START
```

狀態轉移原則：
- 單一入口推進（如 `transition_to(state)`），避免散落的旗標。
- `AIMING → LAUNCHED → AIMING` 在回合內可循環（逐顆發射）。
- 只有「所有球回收」才允許 `LAUNCHED → SETTLE`（含超時保險，見 Q-006）。

## 主要資料結構（建議）

執行期狀態建議集中在一個 `RunState`（可用 autoload singleton）：

```gdscript
# 僅為結構示意，Phase 0 不實作
RunState:
    player_max_hp: int
    player_hp: int
    balls_per_round: int
    unlocked_balls: Array[String]      # ["normal_ball", ...]
    peg_damage_mods: Dictionary        # { "normal_peg": +2, ... }
    stat_mods: Dictionary              # { "enemy_attack_down": 1, ... }
    current_battle_index: int          # 0..4
    kills: int
```

回合期暫存（戰鬥內、不跨回合保留）：

```gdscript
RoundContext:
    damage_accumulator: int
    round_multiplier: float            # Double Peg 影響
    highest_single_hit: int            # Blast Ball 用
    incoming_damage_reduction: float   # Shield Ball 用
    balls_remaining: int
    balls_in_play: int
```

資料定義（唯讀，從 JSON 載入，見下）：`PegDef`、`BallDef`、`EnemyDef`、`UpgradeDef`，欄位對應 `Data/*.json`。

## JSON config 使用原則

1. **單向資料流**：JSON 是唯讀定義，遊戲只**讀**不寫回。執行期變化存在 `RunState`，不改 JSON。
2. **以 id 為鍵**：所有定義用穩定的 `id`（如 `normal_peg`）互相引用；升級的 `target_id` 必須能對應到某個 `id`。
3. **載入時驗證**：啟動時載入並檢查必要欄位齊全、id 不重複、`target_id` 有對應；缺漏時明確報錯（不要靜默失敗）。
4. **數值全外置**：傷害、HP、球數、倍率、減傷等可調數值一律放 JSON，程式不寫死魔術數字。
5. **新增內容靠加資料**：新 Peg / Ball / 敵人 / 升級優先以新增 JSON 條目達成，避免改邏輯。
6. **effect_type 驅動分支**：實作用 `effect_type` 字串對應到效果處理函式（查表 / match），新增效果型別時集中在一處擴充。

## 模組邊界（Module Boundaries）

| 模組 | 職責 | 不該碰 |
| --- | --- | --- |
| Data Loader | 載入 / 驗證 JSON，提供唯讀定義 | 遊戲流程、UI |
| RunState | 持有整局成長狀態 | 物理、繪製 |
| BattleState (FSM) | 推進戰鬥流程 | 不直接讀檔（透過 Loader） |
| Pinball / Physics | 球、釘、碰撞、落底 | 不決定勝敗、不切場景 |
| Effect Resolver | 依 effect_type 套用 Peg/Ball 效果 | 不畫 UI |
| UI / Screens | 顯示 HP / 傷害 / 升級 / 結算 | 不算傷害邏輯 |

原則：**物理層只回報事件（命中了哪個 peg、球落底了），傷害與規則由 Effect Resolver / BattleState 決定。** 避免把規則寫死在物理節點裡。

## 未來 Codex 實作注意事項

- **先可運行，再強化**：Phase 1 先讓流程跑通（哪怕視覺很陽春），Phase 2 才加 feel / 特效。
- **不一次重寫**：每張任務卡只動其範圍內的東西，不重構無關模組。
- **不寫死數值**：任何想 hardcode 的數值，改放 JSON 或 `RunState`。
- **超時保險**：球可能卡住，務必有「N 秒未落底強制回收」（見 Q-006，暫定 8 秒）。
- **2D 物理穩定性**：用 `RigidBody2D`，避免過小碰撞體與過高速度造成穿透（必要時開連續碰撞偵測）。
- **可重入**：戰鬥結束能乾淨重來（重玩 Demo 不殘留狀態）。
- **遇到規格沒寫的選擇**：寫進 `OPEN_QUESTIONS.md`，採暫行假設時明確標記。
- **既有 `project.godot`**：目前含 3D 物理引擎設定；本遊戲為 2D，如需調整專案設定請先記錄於 `OPEN_QUESTIONS.md`，不要無聲更動。
