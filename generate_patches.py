from __future__ import division
import os, sys, glob
import numpy as np
from multiprocessing import Pool, cpu_count
from utils import generate_patch_locations, perturb_patch_locations, generate_patch_probs, read_image

def batch_works(k):
    input_path = "G:/brats17-master/Brats17"
    output_path = "F:/patches"
    
# =============================================================================
#     #输出文件夹是否存在，不存在则创建
#     if not os.path.exists(output_path):
#         os.makedirs(output_path)
# =============================================================================
        
    #计算cpu数量
    n_processes = cpu_count()
    
    # Some variables
    patches_per_image = 20 #产生的patch数量
    patch_size = 64 #patch的大小8*8
    image_size = (240, 240, 155) #input_ image size
    
    all_paths = [] #path=paths=all_paths == dirpath = input_path + nii.gz所在文件夹名
    for dirpath, dirnames, files in os.walk(input_path): #遍历input_path的文件夹和文件，目的是获取所有nii.gz文件路径
        if os.path.basename(dirpath)[0:8] == 'Brats17_': #判断dirpath中nii.gz所在文件夹的名称
            all_paths.append(dirpath) #将所有dirpath赋给all_paths
    base_locs = generate_patch_locations(patches_per_image, patch_size, image_size) #确认patch的位置（x，y，z）  
    
    #判断路径的起始位置？no。n_processes=8，一个cpu处理35个文件夹，即35个患者数据，
    #k=0-6时，0-6号cpu（7个）处理前35*7个数据，8号cpu处理 35*7到最后的数据     
    if k == n_processes - 1: #判断k==7是否成立，为什么k=7时计算不一样？一样的
        paths = all_paths[k * int(len(all_paths) / n_processes) : ] # len(all_paths)=285时，paths=[245 ：)的路径
    else: #k=0，1，2，3，4，5，6时
        #len(all_paths)=285时，处理前0-244个数据，每个cpu处理35个
        paths = all_paths[k * int(len(all_paths) / n_processes) : (k + 1) * int(len(all_paths) / n_processes)] 
        
    for path in paths:
        o_path = os.path.join(output_path, os.path.basename(path))
        if not os.path.exists(o_path):
            os.makedirs(o_path)
        #对patch的位置（x，y，z）随机采样
        x, y, z = perturb_patch_locations(base_locs, patch_size / 16) #为什么除16
        #生成patch
        probs = generate_patch_probs(path, (x, y, z), patch_size, image_size)
        #len(probs)==144，从0-143以概率probs抽取64个数据
        selections = np.random.choice(range(len(probs)), size=patches_per_image, replace=False, p=probs)
        #读取4个模态的数据和金标准
        image = read_image(path)
        
        for num, sel in enumerate(selections):
            i, j, k = np.unravel_index(sel, (len(x), len(y), len(z)))
            patch = image[int(x[i] - patch_size / 2) : int(x[i] + patch_size / 2),
                          int(y[j] - patch_size / 2) : int(y[j] + patch_size / 2),
                          int(z[k] - patch_size / 2) : int(z[k] + patch_size / 2), :]
            f = os.path.join(o_path, str(num))
            np.save(f, patch)
    
if __name__ == '__main__':
# =============================================================================
#     input_path = "G:/brats17-master/Brats17"
#     output_path = "G:/brats17-master/Brats17/patches"
#     if len(sys.argv) < 2:
#         raise Exception("Need at least the input data directory")
#     input_path = sys.argv[1]
#     if len(sys.argv) > 2:
#         output_path = sys.argv[2]
#     else:
#         output_path = './patches'
#     if not os.path.exists(output_path):
#         os.makedirs(output_path)
#     
#     # Some variables
#     patches_per_image = 400
#     patch_size = 64
#     image_size = (240, 240, 155)
#     
#     all_paths = []
#     for dirpath, dirnames, files in os.walk(input_path):
#         if os.path.basename(dirpath)[0:7] == 'Brats17':
#             all_paths.append(dirpath)
#     
#     base_locs = generate_patch_locations(patches_per_image, patch_size, image_size)
# =============================================================================
    
    n_processes = cpu_count()
    pool = Pool(processes=n_processes)
    pool.map(batch_works, range(n_processes))