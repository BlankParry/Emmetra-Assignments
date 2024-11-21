# Emmetra-Assignments
[Contains the code and documentation for the Image processing assignments provided by Emmetra]




**PREREQUISITES:**

Matlab Software (Version used: 2024b)

MATLAB Add-Ons: (1)Image Processing Toolbox  (2)Deep Learning Toolbox  (3)Parallel Computing Toolbox

Python (Version used: 3.8.0)

Required Python Libraries: 
- OpenCV (Version used: 4.10.0.84 )
- Numpy (Version used: 1.24.4)
- Pillow (Version used: 10.4.0 )
- Matplotlib (Version used: 3.7.5 )
- Streamlit (Version used: 1.40.1)




**PROCEDURE:**

**MATLAB Setup**

1. Open MATLAB.
2. Click on Add-Ons.
![addon](https://github.com/user-attachments/assets/9f34f9ed-9ec7-4241-9fb1-c3c79493b6fe)




3. Search for the required toolboxes in the search bar and Install:
   
(a)Image Processing Toolbox

![iptb](https://github.com/user-attachments/assets/6906e831-3672-4d90-a08c-b9a70e73a2f6)


(b)Deep Learning Toolbox

![dltb](https://github.com/user-attachments/assets/7a266060-4384-4ea7-890c-60ba29566d6a)


(c)Parallel Computing Toolbox    

![pctb](https://github.com/user-attachments/assets/725c0581-04ec-48b1-9d4b-beb93c8556b6)



 
4. Close the Add-on Explorer.

5. Open the respective file containing the code and click on Run in the Editor tab.

![runar](https://github.com/user-attachments/assets/4d991cf1-7576-4969-baaf-d0e660a8ef0e)



**For Assignment 1:**

![as1base](https://github.com/user-attachments/assets/755a7204-8e90-4377-a9be-5a457eda513b)





1. Click on load image and upload the RAW image from your system directory


![as1load](https://github.com/user-attachments/assets/7557b04b-0c36-4cda-8b51-b9e3c3605826)













2. Click on demosaic and adjust the parameters through the sliders according to your desired output 


![as1out](https://github.com/user-attachments/assets/52d76ee2-e2df-4419-b2f8-9b9ab6f5ad88)












**For Assignment 2:**

![as2base](https://github.com/user-attachments/assets/e4f9342b-3f10-4f47-acec-cbc0e2ac9064)








1. Click on upload RAW Image and select the desired file from your system



![as2load](https://github.com/user-attachments/assets/c744f852-a6dc-4518-b429-cd25abb1e298)






2. Click on OK and then Generate Output to view the results (output will take around 8-10 seconds to process)


![as2out](https://github.com/user-attachments/assets/d63f26d3-faa9-457b-9b3c-2385b222cea9)



**For Assignment 3:**

1. Clone or download the project.

2. Open a terminal or command prompt, navigate to the project directory, and run:
 `pip install -r requirements.txt`

3. Ensure the input images are placed in the same directory as the code files. The default input images referenced in the code can be found in the **Test Data** folder. If you wish to use your own images, update the filenames in **HDR_Imaging.py** accordingly to match your image file names.


![instr](https://github.com/user-attachments/assets/b542668e-f377-4677-8076-4b4d97c14535) 





4. Execute the main script (HDR_Imaging.py), which automatically starts the Streamlit application:
`python HDR_Imaging.py`

5. The Streamlit application will open in your default browser (or provide a URL in the terminal to access it).

![streamlit_UI](https://github.com/user-attachments/assets/17f6c929-e98b-42b1-8a22-6587cb193c96)











6. Use the View Debevec Output, View Robertson Output and View Mertens Output buttons to explore the HDR outputs.

![debevec_output](https://github.com/user-attachments/assets/2d6880d9-428d-4702-bb16-830343e4f71d) ![robertson_output](https://github.com/user-attachments/assets/7133b20e-cc64-4d41-8880-7c27ad14fca5) ![mertens_output](https://github.com/user-attachments/assets/12322f30-9c48-48fe-8186-f007c1876129)







