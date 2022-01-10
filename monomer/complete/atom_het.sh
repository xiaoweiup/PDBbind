#mono-com 分类 atom/het

path=/home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/complete
path_atom=/home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/atom
path_het=/home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/het

for name in `ls $path`
do

	#判断除水外是否还存在HETATM部分
	het=$(grep 'HETATM' $path/$name/${name}_protein.pdb | sed '/HOH/d')
	if [[ "$het" = "" ]];then
		echo $name-atom
		cp -rf $path/$name $path_atom
	else
		echo $name-het
		cp -rf $path/$name $path_het
#		echo $file >> /data/lwl/PDBbind/refined_set_doing/monomer/missing/het.txt
#		grep 'HETATM' $pwd/$file/${file}_protein.pdb | sed '/HOH/d' >> /data/lwl/PDBbind/refined_set_doing/monomer/missing/het.txt
	fi
	
done
