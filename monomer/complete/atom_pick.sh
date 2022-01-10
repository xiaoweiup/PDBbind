#!/bin/bash
path1=atom
path2=multi_unit
file=multi_unit_pdb_id.log
while read name     
do
   mv $path1/$name $path2/$name 
done <$file        
