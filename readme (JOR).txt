This file briefly summarizes the organization of the stata code for 

"Learning from Coworkers" by Jarosch, Oberfield, Rossi-Hansberg.

The paper uses the LIAB LM 9310 (provided by the FDZ/IAB, https://fdz.iab.de/en/Integrated_Establishment_and_Individual_Data/LIAB.aspx); 
		the newest version of this dataset, described on the website is the LIAB LM 9317
		the dataset is provided by the German Social Security administration, see the website for how to apply for data access.
		---note that the IAB has a "fake" dataset available for download on which this code can be tested.

File globals_definition sets path and globals needed. 

Files 1 and 2 are directly from the IAB and turn the original data file which comes in spell into a monthly panel. See references in our Data Appendix.

File 3 uses the basic IAB establishment panel to identify mass layoffs.

File 4 turns the monthly panel into an annual panel (keeping just the January spell, again see data appendix for more detail).

Files 5 then create a "coworker dataset". 
	
	a) keep panel cases, additional cleaning (outliers, no wage info,..) and additional individual variables (censoring, wage growth, job loss,..)
	b) Summary Stats (wage distribution, size distribution, various cross-correlations). For final part to run need to run part c once (after running this file up to the final part, see the note in line 164 of the file for more detail).
		b2) Exit/Pseudo-Death instrument: Identify exiters
	c) Summary Stats for Teams and additional team-level (rather than invidiual) variables. Also constructs the instrument and various variables needed for the regressions.

File 6 carries out the regression analysis: Some of the regressions give an error on the IAB "fake" LIAB. To run the file on that dataset, turn on the local fake which eliminates those regressions. 

File 7 runs the pseudo-death IV where we instrument for the wedge-to-coworker RHS variable

Files 8 carry out the structural estimation:

	a) uses the annual dataset (constructed in file 4), forms coworker teams, and cleans outliers. also contains code to simulate a dataset for monte carlo exercises for the basic learning function
	b) estimates the basic learning function first reported in the paper. then conducts the various structural exercises reported in the paper
		b2) Estimates the basic learning function for various degrees of increasing and decreasing returns to scale (see size-dependent learning function). Also regresses the constructed z (for the constant returns case) on realized PV income
	c) estimates the piece-wise linear learning function next reported in the paper, then conducts the various exercises.
	d) estimates the age-specific learning function at the end of the paper.
