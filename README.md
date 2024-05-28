# Water Maze Project

This repository contains the code associated with the thesis project "EEG Correlates of Spatial Navigation in Patients with Right Hippocampal Lesion: A Mobile Brain/Body Imaging (MoBI) Study".

The project focuses on analyzing electroencephalographic (EEG) activity during a spatial navigation task in immersive virtual reality (VR) using the Mobile Brain/Body Imaging (MoBI) approach. The analysis explores EEG dynamics, particularly frontal-midline (FM) theta oscillations, recorded during the task and investigates the association between FM theta activity and spatial navigation performance. Additionally, the project compares EEG dynamics between participants with right hippocampal lesions and healthy controls across desktop and MoBI setups, aiming to understand how brain dynamics differ under action during spatial navigation.

## Analysis Summary
- **Data Collection**: EEG data collected from 32 participants performing a spatial navigation task in a VR environment.
- **Preprocessing**: Independent component analysis (ICA) was applied to the data to remove artifacts and extract brain-related signals. The ICLabel algorithm was utilized to identify and remove non-brain data components.
- **Feature Extraction**: Frontal-midline theta oscillations (4-8 Hz) were examined using event-related desynchronization/synchronization (ERD/ERS) method.
- **Analysis**: Two-way ANOVA and regression analysis were performed.
