# 📊 Simulation Results

This section presents the key findings from the Agent-Based Model (ABM) analysis of the impeachment vote. The simulation successfully reproduced the distinct patterns observed in the 1st and 2nd impeachment votes by modeling the interactions between **individual preference**, **party pressure**, **external public opinion**, and **peer effects (neighbor/vision)**.

Detailed statistical data and sensitivity analyses for various model configurations (e.g., *Party Pressure, Neighbor Conformity, Vision, Entrance Pressure models*) are available in the included file: [Impeachment_Sim_Result.pdf](Impeachment_Sim_Result.pdf).

## 1. Model Environment & Logic
The simulation environment represents the National Assembly plenary hall as a 20x20 grid.

### **Model Setup**
![Model Environment](Model%20Environment.png)
* **Figure 1:** The black grid represents the plenary hall seats. The gray circles represent the 108 People Power Party (PPP) lawmakers (Agents).
* **Agents:** Distributed randomly across the grid. Each agent holds an intrinsic preference ($P$) regarding impeachment (0 to 1).

### **Pressure Calculation Logic**
![Pressure Example](Pressure%20Example.png)
* **Figure 2:** This diagram illustrates how an agent calculates pressure from their surroundings.
    * **$\star$ (Star):** The target agent making a decision.
    * **$\bigcirc$ (Circles):** Immediate neighbors (left/right) exerting direct peer pressure.
    * **$\triangle$ (Triangles):** Agents within the "Vision Cone" (Standing Ovation Problem logic). The agent observes the behavior of colleagues in front of them.
    * **$\square$ (Squares):** Agents outside the visual range.
* **Decision Rule:** Agents decide to vote (participate/approve) if the combined utility of *Personal Preference ($P$)*, *External Pressure ($PO$)*, and *Inner-Group Conformity Pressure ($IGCP$)* exceeds a threshold ($T$).

---

## 2. Reproduction of the 1st Vote (Boycott)
The first simulation reproduces the scenario where the party leadership enforced a boycott, and a high "psychological cost" was applied to entering the hall.

![First Vote](First%20Vote.png)
* **Figure 3 & 4 (Simulation Screenshots):**
    * **Red Triangles ($\triangle$):** Agents who defied the party line and participated in the vote.
    * **Gray Circles ($\bigcirc$):** Agents who boycotted (absent).
* **Analysis:**
    * The model reflects the high cost of being the "first mover" to break the party line.
    * Consistent with actual events, only a very small number of agents (similar to Rep. Ahn Cheol-soo and two others) remained or entered the hall.
    * These agents typically had **extremely high intrinsic preference** for impeachment or **low sensitivity to party pressure**, allowing them to overcome the boycott cost.

---

## 3. Reproduction of the 2nd Vote (Approval)
The second simulation reproduces the successful passage of the impeachment motion, driven by increased external pressure (public opinion) and decreased party pressure.

![Second Vote](Second%20Vote.png)
* **Figure 5 (Simulation Result):**
    * **Mass Participation:** Unlike the 1st vote, all agents are present.
    * **Clustering of Defectors:** The red triangles (Yes votes) appear in clusters, demonstrating the **Neighbor Effect**.
* **Analysis:**
    * **Result:** The simulation produced approximately 21-23 approval/invalid votes, closely mirroring the actual result (12 Yes + 11 Invalid/Abstention).
    * **Mechanism:** As *External Pressure* accumulated over time (ticks), it crossed the threshold for agents with moderate preferences.
    * **Peer Effect:** Once key agents switched to "Approve," the **local conformity pressure** influenced neighboring agents to also defect from the party line, triggering a cascade sufficient to pass the motion.

---

## 4. Sensitivity Analysis & Additional Data
To validate the robustness of the model, extensive sensitivity analyses were conducted by varying key parameters.

> **Full statistical tables are available here:** [Impeachment_Sim_Result.pdf](Impeachment_Sim_Result.pdf)

The PDF report includes detailed metrics on:
* **Party Pressure Model:** Effects of varying party discipline strength.
* **Neighbor Conformity Model:** Impact of peer influence weight.
* **Vision (Visibility) Model:** How the radius of vision (3, 5, 7) affects information cascades.
* **Entrance Pressure Model:** The impact of the psychological cost of entering the voting hall.
* **Rapid Increase Model:** Simulation of sudden shocks in public opinion.
