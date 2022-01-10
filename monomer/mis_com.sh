#区分单体monomer  残基缺失（missing residual） 残基完整（complete）

dir=/home/user/Documents/wjm/PDBbind/refined-set/monomer/monomer


for protein_file in `ls $dir`
do

	cd $dir/$protein_file
	#打印单体蛋白的残基编号到临时文件中
	res_true=`grep 'ATOM' ${protein_file}_protein.pdb | awk '{print $6}' | awk '!a[$0]++' | awk 'END{print NR}'`

	#确认临时文件中的行数是否吻合于序列数，以此判断其蛋白质文件是否存在残基的缺失
	
	num=$(grep 'SEQRES' ${protein_file}_protein.pdb | awk '{print $4}' | awk '!a[$0]++')
	#确认残基差值是否与序列数一致
	#first=$(awk 'NR==1{print $1}' temp.txt)
	#last=$(awk 'NR=='${hang_num}'{print $1}' temp.txt)
	#根据目前已知信息，开头序列号含有字母而导致无法计算的蛋白质为完整的，后续可以根据情况修改
	#if [[ $first == *[a-zA-Z]* ]] || [[ $last == *[a-zA-Z]* ]] ;then
	#	detal=$(echo "${hang_num}") 
	#else
	#	detal=$(echo "${last}-(${first})+1"|bc)		
	#fi
	
	#清除临时文件
	#rm temp.txt
	
	#判断分类
	if [ ${num} -eq ${res_true} ] ;then
		echo $protein_file-complete
		cp -rf $dir/$protein_file /home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/complete/	
	else
			
	        echo $protein_file-missing
		cp -rf $dir/$protein_file /home/user/Documents/wjm/PDBbind/refined-set/monomer/missing/missing
	fi
done
