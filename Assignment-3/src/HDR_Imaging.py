import cv2 as cv
import numpy as np
from PIL import Image
import subprocess
import matplotlib.pyplot as plt
import streamlit as st
import os

# Input image filenames
#img_fn = ["metro-1.jpeg", "metro-2.jpeg", "metro-3.jpeg"]
#img_fn = ["room-1.jpg", "room-2.jpg", "room-3.jpeg"]
img_fn = ["terrace-1.jpeg", "terrace-2.jpeg", "terrace-3.jpg"]
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

# Function to plot histogram
def plot_histogram(img, title):
    fig, ax = plt.subplots(figsize=(6, 4))
    colors = ('b', 'g', 'r')
    for i, color in enumerate(colors):
        hist = cv.calcHist([img], [i], None, [256], [0, 256])
        ax.plot(hist, color=color)
    ax.set_title(title)
    ax.set_xlabel('Pixel Intensity')
    ax.set_ylabel('Frequency')
    return fig

# Streamlit UI
def main():
    # Custom styling using Streamlit's markdown
    st.markdown("""
    <style>
    body {
        background-color: #f0f0f5;  /* Light gray background */
        font-family: 'Arial', sans-serif;
    }
    .stButton>button {
        background-color: #4CAF50;
        color: white;
        padding: 10px 20px;
        font-size: 16px;
        border-radius: 5px;
        border: none;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    .stButton>button:hover {
        background-color: #45a049;
    }
    .stText {
        color: #333;
        font-size: 18px;
    }
    .stTitle {
        color: #333;
        font-size: 30px;
        font-weight: bold;
    }
    .stImage {
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }
    .stSlider>div {
        color: #333;
    }
    </style>
    """, unsafe_allow_html=True)

    # Title of the page
    st.title("HDR Image Processing and Visualization")

    # Get processed HDR images
    img_fn, res_debevec_8bit, res_robertson_8bit, res_mertens_8bit = process_hdr_images()

    # Show the input images with their histograms in one row
    st.write("### Input LDR Images")
    col1, col2, col3 = st.columns(3)

    # Display input images and their histograms
    for i, fn in enumerate(img_fn):
        with eval(f"col{i+1}"):
            st.image(resize_image_preserve_aspect(fn), caption=f"Input Image {i+1}", use_container_width=True)
            hist_fig = plot_histogram(cv.imread(fn), f"Pixel Intensity Distribution: Input {i+1}")
            st.pyplot(hist_fig)

    # Create buttons to show HDR results
    st.write("\n")
    st.write("### HDR Outputs")

    # Function to display output images and histograms
    def display_output(output_image, title):
        st.image(resize_image_preserve_aspect(output_image), caption=title, use_container_width=True)
        hist_fig = plot_histogram(cv.imread(output_image), f"Pixel Intensity Distribution: {title}")
        st.pyplot(hist_fig)

    # Buttons for output
    col4, col5, col6 = st.columns(3)
    with col4:
        if st.button('View Debevec Output'):
            display_output('ldr_debevec.jpg', 'Debevec HDR Image')

    with col5:
        if st.button('View Robertson Output'):
            display_output('ldr_robertson.jpg', 'Robertson HDR Image')

    with col6:
        if st.button('View Mertens Output'):
            display_output('fusion_mertens.jpg', 'Fusion Mertens HDR Image')

# Run the Streamlit app only if executed directly
if __name__ == "__main__":
    if not os.getenv("IS_STREAMLIT"):
        os.environ["IS_STREAMLIT"] = "1"
        subprocess.run(["streamlit", "run", __file__])
    else:
        main()