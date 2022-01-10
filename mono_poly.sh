#将蛋白质分子分成单体和多聚体


dir=/home/user/Documents/wjm/PDBbind/refined-set/refined-set

for protein_file in `ls $dir`
do

	cd $dir/$protein_file
	num=$(grep -o 'TER' ${protein_file}_protein.pdb |wc -l)   #"TER"为1则为单体，大于1为多聚体
	
	if [[ $(echo "$num == 1"|bc) -eq 1 ]];then
		
		echo $protein_file-monomer
		cp -rf $dir/$protein_file /home/user/Documents/wjm/PDBbind/refined-set/monomer/
		
	else
		echo $protein_file-polymer
		cp -rf $dir/$protein_file /home/user/Documents/wjm/PDBbind/refined-set/polymer/
	fi

done
