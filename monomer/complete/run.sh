#!/bin/bash

pwa=/home/user/Documents/l_S/atom_pick
dir2=/home/user/Documents/l_S/results
for file in `ls $pwa`
do 
	cd $pwa/$file
	ambpdb -p *.prmtop -c equil.rst > $file"_last".pdb   #拓扑和坐标转成pdb
	sed -i '/WAT/d;/Na+/d;/Cl-/d' $file"_last".pdb    #去水 去掉na,cl
	line=$(awk 'END{print NR}' $file"_last".pdb)     
	lin=`expr $line - 5`
	name=$(awk "NR==$lin{print}" $file"_last".pdb | awk '{print $4}')
	
	mkdir $dir2/$file
	cat $pwa/$file/$file"_last".pdb | grep "$name" > $dir2/$file/ligand.pdb
	obabel $dir2/$file/ligand.pdb -ipdb -omol2 -O $dir2/$file/"$file"_ligand.mol2
	rm $dir2/$file/ligand.pdb
	sed "/$name/d" $pwa/$file/$file"_last".pdb > $dir2/$file/"$file"_protein.pdb


done

