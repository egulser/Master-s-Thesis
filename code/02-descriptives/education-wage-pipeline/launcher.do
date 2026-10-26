
 clear all
 

 global dofiles /Users/evrengulser/Desktop/do
 
 cd $dofiles 
 
 do $dofiles/01_clean_taslak_lfs.do
 
 do /Users/evrengulser/Desktop/do/02_prediction_hh_13.04.2023_.do

 do /Users/evrengulser/Desktop/do/03_prepcell.do
 
 do /Users/evrengulser/Desktop/do/04_assembcellsmarch.do
 
 do /Users/evrengulser/Desktop/do/05_assemb-march-lswts-exp.do
 
 do /Users/evrengulser/Desktop/do/06_assemb-marchwg-regs-exp.do 
 
 do /Users/evrengulser/Desktop/do/plotfig_AA_lfs.do
 
 