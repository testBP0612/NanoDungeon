# VALIDATION CHECKLIST — 全專案驗收清單

> 由 **AI Tester** 使用，也供 **Codex** 完成任務後自我檢查。每個 Phase 完成時，逐項勾選對應區塊。**未通過項不得宣稱完成**，需列出未過項與原因。最終以「Demo 展示驗收」與「禁止偏離項目」為驗收門檻。

驗收結果建議格式：每項標 `✅ 通過 / ❌ 未過 / ⚠️ 部分（附說明）`。

---

## A. 文件驗收（Phase 0）

- [ ] `README.md` 含：介紹、展示目標、技術棧、目錄說明、開發原則、AI Workflow、如何讓 Codex 接手。
- [ ] `ROADMAP.md` 含 Phase 0–5 與各自完成定義。
- [ ] `OPEN_QUESTIONS.md` 含使用規則、待決問題、記錄格式模板。
- [ ] `CHANGELOG.md` 含初始紀錄與後續記錄規則。
- [ ] `Docs/01–05` 五份皆存在且有實質內容，涵蓋各自要求章節。
- [ ] `Codex/00_MASTER_PROMPT.md` 含角色、必讀清單、不擅改方向、不重寫全專案、不確定寫 OPEN_QUESTIONS、更新 CHANGELOG、依清單自檢、可運行優先。
- [ ] `Codex/01–04` 四張任務卡皆含：範圍 / 不做範圍 / 預期產出 / 驗收條件 / 禁止事項（依各卡要求）。
- [ ] 文件全程正體中文、專有名詞保留英文。
- [ ] 文件彼此一致（玩法、數值、種類數無互相矛盾）。

## B. Data JSON 驗收（Phase 0）

- [ ] 四個 JSON 皆為合法格式、可被解析。
- [ ] `pegs.json`：4 種 peg，每項含 `id / name / description / base_damage / effect_type / effect_value`。
- [ ] `balls.json`：3 種 ball，每項含 `id / name / description / effect_type / effect_value`。
- [ ] `enemies.json`：5 場敵人，每項含 `id / name / type / hp / attack / description / dialogue`，順序為普通 / 普通 / 精英 / 普通 / Boss。
- [ ] `upgrades.json`：≥ 10 項，每項含 `id / name / description / target_type / target_id / effect_type / effect_value / rarity`。
- [ ] 所有 `id` 唯一、不重複。
- [ ] `upgrades.json` 的 `target_id` 皆能對應到既有 peg / ball / stat。
- [ ] 數值與 `Docs/04_BALANCE_RULES.md` 的基準大致一致。

## C. First Playable 驗收（Phase 1）

- [ ] 主選單可進入戰鬥，不報錯。
- [ ] 依 `balls_per_round` 給正確球數。
- [ ] 可瞄準並逐顆發射；球受重力、會與牆 / 釘碰撞彈跳。
- [ ] 命中 Normal Peg 累積傷害（值取自 `pegs.json`）。
- [ ] 所有球落底 / 超時後一次結算，敵人 HP 正確下降。
- [ ] 敵人 HP ≤ 0 有結束提示，可回主選單 / 重來。
- [ ] 球不會永久卡住（超時回收生效）。
- [ ] 連玩 3 回合不崩潰、無狀態殘留。
- [ ] 無寫死數值（皆來自 JSON）。

## D. Pinball Feel 驗收（Phase 2）

- [ ] 發射有瞄準線與明確輸入回饋。
- [ ] 命中有閃光 / 粒子 / 螢幕微震（至少明顯其一）。
- [ ] 命中跳出傷害數字，結算顯示總傷害。
- [ ] 4 種釘子效果可分別觀察（傷害差異、回血、倍率）。
- [ ] 3 種球效果可驗證（普通、落底加成、減傷）。
- [ ] 發射 / 命中 / 落底 / 結算有占位音效且可關。
- [ ] 加特效後 Phase 1 流程仍正常。
- [ ] 多球 + 粒子下幀率穩定、無物理穿透。

## E. Enemy System 驗收（Phase 3）

- [ ] 5 場敵人依序載入，數值來自 `enemies.json`。
- [ ] 完整回合循環：發射 → 結算 → 敵人攻擊 → 下一回合。
- [ ] 敵人會攻擊扣血；Shield 減免生效。
- [ ] Boss 會在指定回合施放強攻擊。
- [ ] 玩家 / 敵人 HP UI 正確顯示與更新。
- [ ] 玩家死 → 死亡結算；擊敗 Boss → 勝利結算。
- [ ] 結算可重來 / 回主選單，重來後狀態乾淨。
- [ ] 可從第 1 場打到第 5 場不崩潰。

## F. Roguelite Build 驗收（Phase 4）

- [ ] 每場非 Boss 勝利後出現三選一，選項來自 `upgrades.json`。
- [ ] 抽取依 rarity 加權並排除已解鎖 / 達上限項。
- [ ] 選擇後數值確實改變並反映於後續戰鬥。
- [ ] 解鎖 Blast / Shield 後球池確實出現該球種。
- [ ] 球數 / HP / 敵人攻擊等升級可驗證。
- [ ] 整局（5 場 + 4 次升級）穩定跑完並進勝利結算。
- [ ] 升級持續整局、重來後歸零。

## G. Demo 展示驗收（Phase 5）

- [ ] Windows Desktop Export 可獨立執行（不需編輯器）。
- [ ] 一局可在 5–10 分鐘內完成。
- [ ] 連續展示 3 局不崩潰。
- [ ] 正常玩家不會在前 2 場暴斃（下限保護有效）。
- [ ] 整體霓虹賽博風一致（黑底、glow、發光節點）。
- [ ] 過場 / 提示 / 重新開始順手，無卡死。
- [ ] 邊界情況（球卡住、連點、極端升級）已處理。
- [ ] 音效可關、無刺耳爆音。

## H. 禁止偏離項目（任何 Phase 皆檢查）

- [ ] 未擅自更改核心方向（玩法循環 / MVP 範圍 / 種類數）。
- [ ] 未一次重寫整個專案、未重構無關模組。
- [ ] 未引入非目標：多人、真金投注、商城、登入、存檔、複雜劇情、複雜 3D、Web Export、關卡編輯器。
- [ ] 未實作連鎖釘、連射球。
- [ ] 未把可調數值寫死（皆來自 `Data/*.json` 或 `RunState`）。
- [ ] 維持 Peg 種類（MVP 4 種；Phase 7 起含 `bounce_peg` 共 5 種，見 Q-016）、3 種 Ball、5 場敵人。
- [ ] 不確定處皆寫入 `OPEN_QUESTIONS.md`，暫行假設皆有標記。
- [ ] 每次任務皆更新 `CHANGELOG.md`。
- [ ] 「先可運行，再強化」原則被遵守（無為特效犧牲穩定）。
