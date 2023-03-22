# AutomaticProbeStation
This is the code for operating the Remote Probing station. In my paper, I go over the operation and setup of the system.
This is a description of the code for quick reference.

-= Equipment used =-

	ASI imaging MS-2000 optical stage
	A microprobe arm
	A massive Anorad linear stage to hold optical path
	Thorlabs IR sensors
	Ekspla BaF2 lenses, gold mirrors
	Thorlabs and Newport optical parts
	HGH CRN1350 Blackbody
	SR830 Lock-in Amplifier
	A teensy 4.0 microcontroller
	Custom 3D printed hardware

-= Process =-

First the beam profile can be characterized with a lock-ing amplifier and a photodetector. Then the Process of aligning the 
chip requires you to place it in the correct position and move the stage a known direction. Based on the location of the 
microscope image, the chip can be rotated. This process is run multiple times until it is aligned sufficiently well. This 
means, the camera must align with devices on all parts of the chip. It takes a while, but is very possible.

-= Beam Profile Beam characterization =-

StagePDAVJ10.m  -  This file runs the beam characterization code. It scans a photodiode on the stage around in a grid of 40 
	points, total size 0.6cm
SR830Ctrl.m  -  This is a class for communication with a SR830 lock-in amplifier
-= Automated probing Files =-

main3_1_integrated.m  -  This is the main function of code that communicates to the peripherals and holds the photomask data. 
	It is responsible for sending move commands to the stage and probe arm. It performs admittance tests with and without 
	IR radiation and takes a noise measurement for all specified devices.
main3_Qonly.m  -  This command is similar to the "main3_1_integrated.m", but only takes a single admittance measurment, no 
	stage movement.
alignTest.m  -  This shows the process of alignment. Basically uses visual inspection with a microscope to ensure all the pads 
	are lining up and chip angle is correct.
VNAmeasurement.m  -  This command performs a VNA measurement. 
VNAmeasurement_noise.m  -  This command performs a VNA measurement and a noise measurement. 
moveStage.m  -   The rest are all movement functions for peripherals
moveStageLong.m
probeDown.m
probeUp.m
linStageFor.m
linStageBak.m
