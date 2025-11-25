# 🗳️ ABM Analysis of Impeachment Voting Behavior
**Extending the Standing Ovation Problem (SOP) to Analyze PPP Lawmakers' Decisions**

![NetLogo Badge](https://img.shields.io/badge/NetLogo-6.x-red) ![License Badge](https://img.shields.io/badge/License-MIT-blue)

> **"Why did the ruling party boycott the 1st vote but defect in the 2nd?"**
> This project simulates the voting behavior of People Power Party (PPP) lawmakers during the impeachment of President Yoon Suk-yeol (Dec 2024). Using an **Agent-Based Model (ABM)** based on Miller & Page's *Standing Ovation Problem*, it analyzes the dynamics of peer pressure, public opinion, and political survival.

---

## 📌 Project Overview

In political crises, lawmakers act strategically under immense pressure. This simulation answers two key questions:
1.  **The Boycott (1st Vote):** How did the party leadership successfully enforce a boycott despite public outrage?
2.  **The Defection (2nd Vote):** What triggered the sudden collapse of the party line, leading to the impeachment?

We argue that a lawmaker's choice is a complex interaction of **Individual Preference**, **Party Pressure**, **External Public Opinion**, and **Peer Effects (Neighbor/Vision)**.

---

## 📂 Repository Structure

Click the links below to navigate to specific resources.

### 1. [💻 Model Source Code](./Model)
Contains the **NetLogo source codes (`.nlogo`)** for the simulation scenarios.
* **Scenario 1 (Boycott):** Features high strategic entry costs & strong party pressure.
* **Scenario 2 (Defection):** Features sudden rise in external pressure & tipping point dynamics.

### 2. [📊 Results & Analysis](./RESULTS)
Contains detailed statistical data and sensitivity analyses.
* **Main Report:** [📄 Impeachment_Sim_Result.pdf](./RESULTS/Impeachment_Sim_Result.pdf)
* Includes analysis on Party Pressure, Neighbor Conformity, and Vision models.

### 3. [📈 Raw Simulation Data](./Simulation%20Data)
Contains the **raw dataset (Excel/CSV)** exported from 800+ simulation runs.
* *Hosted via Google Drive link due to file size limits.*

---

## 🧠 Model Logic & Environment

The simulation environment represents the National Assembly plenary hall as a 20x20 grid.

### 1. Model Setup
![Model Environment](./images/Model%20Environment.png)
* **Grid:** The black grid represents the plenary hall seats.
* **Agents:** 108 gray circles represent PPP lawmakers, distributed randomly. Each holds an intrinsic preference ($P$) regarding impeachment (0 to 1).

### 2. Pressure Calculation Logic
![Pressure Example](./images/Pressure%20Example.png)
* **$\star$ (Star):** The target agent making a decision.
* **$\bigcirc$ (Circles):** Immediate neighbors (left/right) exerting direct peer pressure.
* **$\triangle$ (Triangles):** Agents within the **"Vision Cone"** (Standing Ovation logic). The agent observes colleagues in front of them.
* **Decision Rule:**
  $$L_{i} = (P_{i} \times PO) + IGCP - Cost > T$$
  *(Agents vote if the combined utility of Preference, Public Opinion, and Group Conformity exceeds the threshold.)*

---

## 📊 Key Simulation Results

### Case 1: Reproduction of the 1st Vote (Boycott)
The party leadership enforced a boycott, applying a high "psychological cost" to entering the hall.

![First Vote](./images/First%20Vote.png)
* **Outcome:** Only a few isolated agents (outliers) participate.
* **Analysis:** The model reflects the high cost of being the "first mover." Consistent with actual events (e.g., Rep. Ahn Cheol-soo), only agents with **extremely high intrinsic preference** or **low sensitivity to party pressure** could overcome the boycott cost.

### Case 2: Reproduction of the 2nd Vote (Approval)
Driven by increased external pressure (public opinion) and decreased party pressure.

![Second Vote](./images/Second%20Vote.png)
* **Outcome:** Mass participation and clustering of defectors (Red Triangles).
* **Analysis:**
    * The simulation produced approximately **21-23 approval/invalid votes**, closely mirroring the actual result (12 Yes + 11 Invalid).
    * **Mechanism:** As *External Pressure* crossed the threshold for moderate agents, the **Neighbor Effect** triggered a cascade, leading to the passage of the motion.

---

## 🚀 How to Run
1.  **Install:** Download [NetLogo 6.x](https://ccl.northwestern.edu/netlogo/).
2.  **Download:** Clone this repository.
3.  **Run:** Open the `.nlogo` files in the `Model` folder.
4.  **Experiment:**
    * Click **`Setup`** to initialize 108 agents.
    * Click **`Go`** to observe the voting dynamics.

---

## 👤 Author & Reference
* **Research & Dev:** [KANG, JI HUN/JKCENA / KIM, JUN_SEOK]
* **Citation:** Kang, J., & Kim, J. (2025). "An Agent-Based Model Analysis of the People Power Party's Impeachment Voting Behavior".

*Licensed under the MIT License.*
