# 项目排期: ethernet

## WBS (工作分解结构)

ethernet
- PAD Phase
  - Arch Spec          [Arch Agent]
  - Interface Spec     [Arch Agent]
  - Clock/Reset Spec   [Arch Agent]
- EDR Phase
  - Design Spec        [Design Agent]
  - Verification Plan  [Verification Agent]
  - DFT Spec           [DFT Agent]
  - FuSa Concept       [FuSa Agent]
- IDR Phase
  - RTL Coding         [Design_Coding_Agent]
  - UVM Env            [Verification_Coding_Agent]
  - Testcases          [Verification_Coding_Agent]
  - Coverage           [Verification_Coding_Agent]
- FDR Phase
  - Synthesis          [Flow Agent]
  - DFT Insertion      [Flow Agent]
  - PR                 [Flow Agent]
  - STA Sign-off       [Flow Agent]

## 甘特图

| 任务 | 周1 | 周2 | 周3 | 周4 | 周5 | 周6 | 周7 | 周8 |
|------|-----|-----|-----|-----|-----|-----|-----|-----|
| PAD  |     |     |     |     |     |     |     |     |
| EDR  |     |     |     |     |     |     |     |     |
| IDR  |     |     |     |     |     |     |     |     |
| FDR  |     |     |     |     |     |     |     |     |
