# 📈 Raw Simulation Data (External Storage)

This directory serves as a pointer to the full raw dataset generated from the Agent-Based Model (ABM) simulations. The dataset includes extensive sensitivity analyses across different model configurations.

## 💾 Download Link
Due to the large file size of the simulation logs, the raw data files are hosted externally. You can access and download the full dataset via the link below:

👉 **[📂 Google Drive: Simulation Raw Data (Full Set)](https://drive.google.com/drive/folders/1p-TEw46fbtGB7Wpq3tiYtILX9ia_P705?usp=drive_link)**

---

## 📂 Data Contents & Experiment Conditions
The dataset is organized based on the variation of key model parameters. Specifically, it contains simulation logs for the following 5 experimental conditions:

### 1. Pressure Differences
* **Experiment:** Variations in **Party Pressure** and **External Public Opinion** weights.
* **Goal:** To analyze how the strength of party discipline vs. public sentiment affects voting behavior.

### 2. Vision Differences
* **Experiment:** Adjusting the **Cone-Length** (Vision Range) of agents.
* **Goal:** To observe how the scope of observation (how many colleagues an agent sees) influences the "Standing Ovation" effect.

### 3. Neighbor Effect Differences
* **Experiment:** Varying the weight of influence from immediate neighbors (left/right).
* **Goal:** To determine the impact of local peer pressure compared to global party pressure.

### 4. Enter Pressure (Cost) Differences
* **Experiment:** Modifying the **"Cost of Entry"** function (U-shaped curve).
* **Goal:** To analyze how the political cost of breaking the boycott (entering the hall) suppresses participation in the 1st vote.

### 5. Sudden Rise in Pressure
* **Experiment:** Simulating a scenario where external pressure jumps abruptly (Trigger Event).
* **Goal:** To replicate the dynamics of the 2nd vote where a "Tipping Point" leads to mass defection and regime overthrow.

---

## ❓ Why External Link?
GitHub has a strict file size limit (100MB per file). Since the raw simulation results (Excel/CSV logs) contain extensive tick-by-tick data for all 800+ simulation runs across these conditions, they exceed this limit.

To ensure easy access without requiring Git LFS (Large File Storage) configuration, the data is provided via Google Drive.

*Please refer to the `Model` directory for the source code used to generate this data.*
