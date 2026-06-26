# Model-Based Denoising of Digital Mammography Incorporating Spatial Noise Correlation

This repository contains the MATLAB implementation and supplementary material associated with the paper:

> **Brandão RF, Borges LR, Caron RF, Barufaldi B, Maidment ADA, Vieira MAC.**
>
> *Model-Based Denoising of Digital Mammography Incorporating Spatial Noise Correlation.*
>
> Proceedings of the **18th International Workshop on Breast Imaging (IWBI 2026)**.

---

## 📄 Full Paper

The complete manuscript is available in this repository:

📄 **[IWBI2026_FullPaper.pdf](IWBI2026_FullPaper.pdf)**

Please refer to the paper for a detailed description of the proposed methodology, experimental setup, and quantitative results.

---

# Overview

Digital mammography images acquired at reduced radiation dose suffer from increased quantum noise, which may compromise the detectability of lesions such as microcalcifications. This repository provides a complete framework for simulating correlated noise in digital mammography (DM) images, restoring degraded images using model-based denoising techniques, and quantitatively evaluating restoration performance.

The proposed framework includes:

* Correlated Poisson-Gaussian noise simulation;
* Variance Stabilization Transform (VST);
* Model-based denoising using:

  * conventional BM3D (non-correlated noise assumption);
  * correlation-aware BM3D (correlated noise assumption);
* Inverse variance stabilization;
* Quantitative image quality assessment;
* Model observer evaluation using a Channelized Hotelling Observer (CHO).

---

# Repository Structure

```text
BM3D_New/
Functions/
MC cropped (Ge)/
Metrics/
ModelObserver (Dataset)/
NoiseParameters/
Results/
VCT (Noise free Image)/

main_01_noise_simulation.m
main_02_denoising_spatial_corr.m
main_03_eval_mnse_psd.m
main_04_generate_CHO_dataset.m
main_05_eval_model_observer.m
```

---

# Workflow

Execute the scripts in the following order:

| Script                               | Description                                                                                                                              |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| **main_01_noise_simulation.m**       | Simulates correlated Poisson-Gaussian noise at different dose levels.                                                                    |
| **main_02_denoising_spatial_corr.m** | Restores noisy mammograms using conventional BM3D and the proposed correlation-aware BM3D.                                               |
| **main_03_eval_mnse_psd.m**          | Computes quantitative image quality metrics (MNSE, Bias², Residual Noise and Power Spectrum Density).                                    |
| **main_04_generate_CHO_dataset.m**   | Generates the signal-present and signal-absent datasets by inserting simulated microcalcification clusters for the Model Observer study. |
| **main_05_eval_model_observer.m**    | Evaluates lesion detectability using a Laguerre–Gauss Channelized Hotelling Observer (CHO).                                              |

---

# Repository Contents

This repository contains:

* MATLAB source code used in the paper;
* Estimated noise model parameters;
* Reference VCT mammography images;
* Library of segmented microcalcifications;
* Dataset for the Channelized Hotelling Observer experiments;
* Image quality assessment metrics;
* Scripts required to reproduce all experiments presented in the manuscript.

---

# Softwares

This repository incorporates algorithms developed by other authors. Please cite the corresponding publications when using these implementations.

## BM3D

The denoising framework includes the BM3D implementation described in:

> Mäkinen Y, Azzari L, Foi A.
>
> **Collaborative Filtering of Correlated Noise: Exact Transform-Domain Variance for Improved Shrinkage and Patch Matching.**
>
> *IEEE Transactions on Image Processing*, 29, 8339–8354, 2020.

The implementation is provided in the `BM3D_New` folder.

---

## Channelized Hotelling Observer (CHO)

The repository also includes an implementation of the **Laguerre–Gauss Channelized Hotelling Observer (LG-CHO)** for lesion detectability assessment.

The implementation is available in the `Functions` folder and is based on:

> Diaz I, Abbey CK, Timberg PAS, Eckstein MP, Verdun FR, Castella C, et al.
>
> **Derivation of an Observer Model Adapted to Irregular Signals Based on Convolution Channels.**
>
> *IEEE Transactions on Medical Imaging*, **34**(7), 1428–1435, 2015.

Please cite the above publication if you use the LG-CHO implementation in your work.

---

# Software Requirements

The code was developed and tested using:

* MATLAB R2025b
* Image Processing Toolbox
* Statistics and Machine Learning Toolbox

Other MATLAB versions may also work but have not been extensively tested.

---

# Citation

If you use this repository in your research, please cite:

```bibtex
@inproceedings{Brandao2026IWBI,
  author    = {Brandão, Renann F. and Borges, Luiz R. and Caron, Rafael F. and Barufaldi, Bruno and Maidment, Andrew D. A. and Vieira, Marcelo A. C.},
  title     = {Model-Based Denoising of Digital Mammography Incorporating Spatial Noise Correlation},
  booktitle = {18th International Workshop on Breast Imaging (IWBI)},
  year      = {2026}
}
```

---

# Acknowledgements

This work was developed at the **Laboratory of Applied Vision (LAVI)**, University of São Paulo (USP), Brazil.

The authors gratefully acknowledge **Hospital de Amor (Barretos, Brazil)** for providing the mammographic images used in this study.

---

# Contact

**Renann F. Brandão**

Laboratory of Applied Vision (LAVI)

University of São Paulo (USP)

São Carlos, SP, Brazil

📧 **[renannbrandao@usp.br](mailto:renannbrandao@usp.br)**
