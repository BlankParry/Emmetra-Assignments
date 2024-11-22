import cv2 as cv
import numpy as np
from PIL import Image
import subprocess

# Input image filenames
#img_fn = ["../test-data/metro-1.jpeg", "../test-data/metro-2.jpeg", "../test-data/metro-3.jpeg"]
#img_fn = ["../test-data/room-1.jpg", "../test-data/room-2.jpg", "../test-data/room-3.jpeg"]
img_fn = ["../test-data/terrace-1.jpeg", "../test-data/terrace-2.jpeg", "../test-data/terrace-3.jpg"]
img_list = [cv.imread(fn) for fn in img_fn]
exposure_times = np.array([0.04, 0.005, 0.01], dtype=np.float32)

# HDR merging and tonemapping algorithms
def process_hdr_images():
    # Debevec merging
    merge_debevec = cv.createMergeDebevec()
    hdr_debevec = merge_debevec.process(img_list, times=exposure_times.copy())

    # Robertson merging
    merge_robertson = cv.createMergeRobertson()
    hdr_robertson = merge_robertson.process(img_list, times=exposure_times.copy())

    # Tonemap and adjust gamma
    tonemap1 = cv.createTonemap(gamma=1.6)
    tonemap2 = cv.createTonemap(gamma=1.6)
    res_debevec = tonemap1.process(hdr_debevec.copy())
    res_robertson = tonemap2.process(hdr_debevec.copy())

    # Mertens fusion
    merge_mertens = cv.createMergeMertens()
    res_mertens = merge_mertens.process(img_list)

    # Save the result images as 8-bit
    res_debevec_8bit = np.clip(res_debevec * 255, 0, 255).astype('uint8')
    res_robertson_8bit = np.clip(res_robertson * 255, 0, 255).astype('uint8')
    res_mertens_8bit = np.clip(res_mertens * 255, 0, 255).astype('uint8')

    cv.imwrite("ldr_debevec.jpg", res_debevec_8bit)
    cv.imwrite("ldr_robertson.jpg", res_robertson_8bit)
    cv.imwrite("fusion_mertens.jpg", res_mertens_8bit)

    return img_fn, res_debevec_8bit, res_robertson_8bit, res_mertens_8bit

# Function to resize the image
def resize_image_preserve_aspect(img_path, max_width=600, max_height=400):
    img = Image.open(img_path)
    img_width, img_height = img.size

    aspect_ratio = img_width / img_height

    if img_width > img_height:  # Landscape
        new_width = min(max_width, img_width)
        new_height = int(new_width / aspect_ratio)
    else:  # Portrait
        new_height = min(max_height, img_height)
        new_width = int(new_height * aspect_ratio)

    return img.resize((new_width, new_height), Image.Resampling.LANCZOS)

# Automatically launch the Streamlit UI
if __name__ == "__main__":
    subprocess.run(["streamlit", "run", "./Streamlit.py"])