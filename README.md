## Synopsis

This github refer to https://github.com/xf4j/brats17. I use it in Brats18 (https://www.med.upenn.edu/sbia/brats2018/participation-summary.html) and TCIA's dataset(http://www.cancerimagingarchive.net/).

A patch-based 3D U-Net model is used. Instead of predicting the class label of the center pixel, this model predicts the class label for the entire patch. A sliding-window method is used in deployment with overlaps between patches to average the predictions.

## Code Example

This code can run in Ubuntu and windows10.
The workflow includes bias correction, image fusion, patch extraction, training, post-processing, testing and submission.</br></br>

1. After training data is downloaded, run `python bias_correction.py` to perform bias field correction based on N4ITK (https://www.ncbi.nlm.nih.gov/pubmed/20378467). 
If you need improve the speed and just run process, you can only one of the 4 modal. But the accuracy may be low. The corrected dataset will be saved at the same folder with the raw dataset as the end of "_corrected.nii.gz". </br></br>.

2. Run 'nii2mat.m' in load_nii,then the mat file will be saved at the same folder. And run 'main_wavelet_brain.m' to fusion 4 modal. Finally, you need run 'mat2nii' in load_nii to get the fusion result.

3. Run `python generate_patches.py` to generate patches for training. Just modify the path of files. The patches will be saved in output_path</br></br>

4. To train the model, run `python main.py`. It will show number of iterations, train_loss and test_loss. 
Check `model.py` for more details about the network structure.<br/></br>

5. To test the model on validation dataset, run `python main.py`. Set the 'train' as 'False'. The results will be saved at `deploy_output_dir`. 

6. The network structure for survival prediction is not working good as the result is similar as random guessing. So you can ignore that by setting `run_survival` to `False`.<br/></br>

7. To combine the results and generate the final label maps, run `python prepare_for_submission.py`.

## Installation

The model is implemented and tested using `python 3.6` and `Tensorflow 1.6.0`.
Other required libraries include: `numpy`, `h5py`, `skimage`, `transforms3d`, `nibabel`, `scipy`, `nipype`. You also need to install `ants` for bias correction. Read the instructions for Nipype (http://nipy.org/nipype/0.9.2/interfaces/generated/nipype.interfaces.ants.segmentation.html) and Ants (http://stnava.github.io/ANTs/) for more information. When you run "bias_correction.py", you may need in ubuntu, because in windows the configuration of ants is inconvenient.


## Contributors
Jinchang Gong, Department of Biomedical Engineering, University of Shanghai for Science and Technology
172702180@st.usst.edu.cn
