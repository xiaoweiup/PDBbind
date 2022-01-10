#区分多聚体polymer  残基缺失（missing residual） 残基完整（complete）

dir=/home/user/Documents/wjm/PDBbind/refined-set/polymer/polymer


for protein_file in `ls $dir`
do

	cd $dir/$protein_file
	
        #实际残基数
	res_true=`grep 'ATOM' ${protein_file}_protein.pdb | awk '{print $6}' | awk '!a[$0]++' | wc -l`

	#序列数
	
	num=$(grep 'SEQRES' ${protein_file}_protein.pdb | awk '{print $4}' | awk '!a[$0]++')
	
	#判断分类
	if [ ${num} -eq ${res_true} ] ;then
		echo $protein_file-complete
		cp -rf $dir/$protein_file /home/user/Documents/wjm/PDBbind/refined-set/polymer/complete/	
        else

                echo $protein_file-missing
		cp -rf $dir/$protein_file /home/user/Documents/wjm/PDBbind/refined-set/polymer/missing/
			
	fi
	
done
