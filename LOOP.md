# LOOP — AI 開發迴圈（AI Loop Development Framework）

> 本檔定義 **Nano Dungeon 的 AI 開發迴圈**。它讓未來的 Codex 能自主理解專案狀態、規劃下一步、實作、驗收並產出進度報告——**同時保持人類掌握方向、AI 不得修改核心規格、不確定必須回報**。
>
> 這是一個 **可控的 Self-Correcting Agent Loop**，不是全自動 Self-Improving Agent。迴圈會自我推進，但任何觸及核心方向的決策都會被導回人類。

---

## Core Loop（核心迴圈）

```txt
Read Context          讀取 README / ROADMAP / OPEN_QUESTIONS / CHANGELOG / LOOP + Docs + 當前任務卡
        ↓
Analyze Current State 盤點已完成 / 未完成、目前 Phase、未解問題
        ↓
Compare Against Roadmap 對照 ROADMAP 找出與 DoD 的差距
        ↓
Generate Work Plan    產出 / 更新 WORK_PLAN.md（決定這一圈要做什麼、為什麼）
        ↓
Implement             依任務卡與 WORK_PLAN 小步實作（資料驅動、模組邊界清楚）
        ↓
Validate              依 Codex/VALIDATION_CHECKLIST.md 自我驗收
        ↓
Update Changelog      在 CHANGELOG.md 留痕（已完成的事 + 新增的 Q 題號）
        ↓
Generate Progress Report 產出 PROGRESS_REPORT.md（摘要、驗收結果、未解問題、建議下一步）
        ↓
Repeat                回到 Read Context，進入下一圈
```

每一圈（iteration）應對應**一張任務卡或一個可驗收的增量**，不可一圈內重寫整個專案。

## Human Responsibilities（人類職責）

**只有人類**可以修改以下項目。AI 不得自行更動，只能提案：

- 修改 `Docs/01_GAME_VISION.md`（GAME VISION）
- 修改 `Docs/02_GAME_DESIGN.md`（GAME DESIGN）
- 修改 `ROADMAP.md`
- 修改核心玩法（玩法循環、Peg/Ball/Enemy 種類與數量、MVP 範圍、非目標）
- 修改比賽目標 / 交付目標

## AI Responsibilities（AI 職責）

AI（Codex 等）在迴圈內**可以自主執行**：

- 撰寫程式（GDScript）
- 建立 / 修改場景（Scenes）
- 建立 / 調整資料（在既有 schema 內新增 JSON 條目與數值）
- 驗收（依 VALIDATION_CHECKLIST）
- 產生報告（WORK_PLAN、PROGRESS_REPORT）
- 建議下一步任務

詳細可動 / 不可動範圍見 `Codex/00_MASTER_PROMPT.md` 的 **Agent Permission Matrix**。

## Escalation Rules（升級回報規則）

當 AI 在迴圈中遇到下列任一情況，**必須停下並寫入 `OPEN_QUESTIONS.md`，而非自行決定**：

- **規格衝突**：兩份文件 / 資料互相矛盾。
- **缺少資訊**：實作所需的規格未被定義。
- **超出目前 Phase**：要做的事不在當前 Phase 範圍內。
- **不確定的架構決策**：會影響後續模組邊界或核心結構的選擇。

升級流程：
1. 用 `OPEN_QUESTIONS.md` 的模板記錄問題（背景、選項、AI 建議、影響範圍、狀態）。
2. 若為避免卡住而採用暫行方案，標記 `⚠️ 暫行假設`，且**不得當成既定規格**。
3. 在 `PROGRESS_REPORT.md` 的「Open Questions」列出對應題號。
4. **觸及人類職責範圍（Vision / Design / Roadmap / 核心玩法 / 比賽目標）的事項，一律等待人類決議，不得在迴圈內推進。**

## Loop Invariants（迴圈不變量）

每一圈結束時，下列條件必須成立：

- `WORK_PLAN.md` 反映本圈的計畫。
- `CHANGELOG.md` 有本圈的留痕。
- `PROGRESS_REPORT.md` 反映本圈結果。
- 核心規格（Vision / Design / Roadmap）未被 AI 更動。
- 所有不確定事項已進入 `OPEN_QUESTIONS.md`。
- 專案仍可運行（未因本圈而崩壞）。
