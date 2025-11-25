# 💻 NetLogo Simulation Models

This directory contains the source code for the Agent-Based Models (ABM) used to simulate the impeachment voting behavior. The models are built using **NetLogo 6.x**.

## 📂 Model Files

| File Name | Description |
| :--- | :--- |
| **[standing ovation_perople_power_party.nlogo](./standing%20ovation_perople_power_party.nlogo)** | **Basic Model (Scenario 1)**<br>Simulates the 1st vote (boycott). Features a high "Cost" function for early defectors and gradual external pressure increase. |
| **[standing ovation_people_power_party_pressure_sudden_increase.nlogo](./standing%20ovation_people_power_party_pressure_sudden_increase.nlogo)** | **Sudden Pressure Model (Scenario 2)**<br>Simulates the 2nd vote. External pressure starts lower (0.1) but follows a different pressure dynamic to simulate a sudden tipping point. |

---

## 🧠 Key Algorithms & Logic

The simulation is driven by the interaction between individual beliefs, external public opinion, and internal peer pressure (Inner-Group Conformity).

### 1. Decision Rule (The `Go` Procedure)
At every tick, agents calculate their probability ($P$) of voting "Yes" (Standing). If $P$ exceeds the `threshold` (0.5), the agent stands.

```netlogo
set P (external-pressure * belief) - cost
set pressure (exp((peer-w * (neighbor-p + funnel-p)) + (total-w * total-p))) - 0.5
set P P + pressure
belief: Randomly assigned internal preference (0.0 ~ 1.0).
```
external-pressure: Public opinion pressure. Increases by 0.001 per tick (and 0.01 every 10 ticks).

cost: The political cost of breaking the party line (see below).

###2. Strategic Cost Function (The Boycott Logic)
To simulate the 1st vote boycott, a U-shaped cost function is applied. This imposes a high penalty on the first few defectors and the last few needed to reach the quorum.
```
; Cost is high for the first few defectors and rises again as quorum approaches
set cost w-cost * ((n-standing - 3.5) ^ 2 / 12.25 + epsilon)
```
###3. Inner-Group Conformity Pressure (IGCP)
Agents are influenced by three types of peer pressure:

A. Neighbor Pressure (Immediate)
Influence from agents directly to the left and right.
```
to-report neighbor-pressure
  ; Checks immediate left/right patches
  let relevant-patches patches with [pycor = my-ycor and abs(pxcor - my-xcor) = 1]
  ; Returns weighted average state of neighbors
end
```

B. Funnel Pressure (Cone of Vision)Based on the Standing Ovation Problem (SOP). Agents look forward within a cone-length. Agents closer to the front have a stronger influence ($1/d^2$).
```
to-report funnel-pressure
  ; Loop through distance (dist) 1 to cone-length
  let weight 1 / (dist ^ 2)
  set funnel funnel + (avg-state * weight)
end
```

C. Total Pressure (Party Mood)
The global ratio of standing agents in the entire assembly.
```
to-report total-pressure
  report standing-ratio ; (Count Standing / Total Agents)
end
```
🛠️ Agent Properties (turtles-own)VariableDescriptionstanding?true if voting Yes (Red Triangle), false if Boycotting (Gray Circle).beliefIntrinsic preference for impeachment (Random 0~1).awkwardnessMeasure of discrepancy between the agent's action and their neighbors.thresholdThe tipping point for decision making (Fixed at 0.5).

🚀 How to Run
Open the .nlogo file in NetLogo.

Click Setup to initialize 108 agents (PPP lawmakers).

Select an Updating method (Sync, Async, or Incentive-based).

Click Go to run the simulation.
