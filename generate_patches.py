from __future__ import division
import os, sys, glob
import numpy as np
from multiprocessing import Pool, cpu_count
from utils import generate_patch_locations, perturb_patch_locations, generate_patch_probs, read_image

def batch_works(k):
    input_path = "G:/brats18-master/Brats18"
    output_path = "F:/patches"
    n_processes = cpu_count()
    
    # Some variables
    patches_per_image = 20 
    patch_size = 64 
    image_size = (240, 240, 155) #input_ image size
    
    all_paths = [] #path=paths=all_paths == dirpath = input_path + nii.gz
    for dirpath, dirnames, files in os.walk(input_path): 
        if os.path.basename(dirpath)[0:7] == 'Brats18': 
            all_paths.append(dirpath) 
    base_locs = generate_patch_locations(patches_per_image, patch_size, image_size)   
    #Multi-process processing  
    if k == n_processes - 1: 
        paths = all_paths[k * int(len(all_paths) / n_processes) : ] 
    else: # When k=0 ~ n_processes-2
        paths = all_paths[k * int(len(all_paths) / n_processes) : (k + 1) * int(len(all_paths) / n_processes)] 
        
    for path in paths:
        o_path = os.path.join(output_path, os.path.basename(path))
        if not os.path.exists(o_path):
            os.makedirs(o_path)
        x, y, z = perturb_patch_locations(base_locs, patch_size / 16) 
        probs = generate_patch_probs(path, (x, y, z), patch_size, image_size)
        selections = np.random.choice(range(len(probs)), size=patches_per_image, replace=False, p=probs)
        image = read_image(path)
        
        for num, sel in enumerate(selections):
            i, j, k = np.unravel_index(sel, (len(x), len(y), len(z)))
            patch = image[int(x[i] - patch_size / 2) : int(x[i] + patch_size / 2),
                          int(y[j] - patch_size / 2) : int(y[j] + patch_size / 2),
                          int(z[k] - patch_size / 2) : int(z[k] + patch_size / 2), :]
            f = os.path.join(o_path, str(num))
            np.save(f, patch)
    
if __name__ == '__main__':  
    n_processes = cpu_count()
    pool = Pool(processes=n_processes)
    pool.map(batch_works, range(n_processes))
