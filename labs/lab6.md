@def title = "Lab 6 - Offline Digital Filtering"
@def hascode = true

# Lab 6 - Offline Digital Filtering
In this assignment you will be analyzing and applying a digital filter on pre-collected data offline.

Before attempting this assignment, make sure you go through the Prelab 6 first. 

## Tools Required
- MATLAB v 2016b or higher, with DSP or Signal Processing Toolbox and Control System Toolbox

## References
1.	Lab Report Submission Guidelines

## Project Creation & Submission

You will work within a single MATLAB Live Script file, add your comments and code within it and submit only a single *.mlx file + a single pdf exported from the Live Script (From Live Editor Tab, click on the save drop down menu and select Export as PDF).

You may need to increase the heap size for MATLAB if you get an export to pdf error, by going to Home Tab then Preferences->MATLAB->General->Java Heap Memory, and doubling the allowable memory, this also speeds up MATLAB in general if you have spare RAM to allocate on your machine. 
You can also submit a Jupyter notebook (Julia, Python or MATLAB)


\fig{/labs/l6assets/matlab_memory.png}

## Questions

Perform the following in a MATLAB Live Script or Jupyter Notebook. 

1. Import the provided sensor data from the [`Dataset_Medium_Tap.xls`](/labs/l6assets/Dataset_Medium_Tap.xlsx) file and into MATLAB
2. Plot the acceleration in the z direction 
    
    a. Explain your observation about the data 

3. Analyze the acceleration data using FFT
    
    a. Explain your observation about the frequency characteristic of the data

4. Design a Low Pass First Order Filter on the accelerometer data
   
    a. Implement the filter using the difference equation method
    
    b. Compare the filtered output to the unfiltered output, and explain the observed differences

5. Design a Low Pass Butterworth second order filter to improve the filter performance
    
    a. Implement the filter using the difference equation method
    
    b. Compare the filtered output to the unfiltered output, as well as to the filtered output from the first order filter, and explain the observed difference.

6. Apply the Low Pass Butterworth second-order filter on the z-axis accelerometer data from the [`Dataset_Slow_Tap`](/labs/l6assets/Dataset_Slow_Tap.xlsx) and [`Dataset_Fast_Tap`](/labs/l6assets/Dataset_Fast_Tap.xlsx) data. Plot in 3 adjacent subplots the unfiltered and filtered signal for each of the 3 data sets z-axis accelerometer data. 

To read an excel table in MATLAB, you can use the function `readtable()`

```matlab
table = readtable("Dataset_Medium_Tap.xlsx");
% Plot data
figure()
plot(table.Time_ms_, table.AccZ_mg_);
```

