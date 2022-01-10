#筛选重原子缺失

pwa=/data/lwl/PDBbind/test/all

mkdir /data/lwl/PDBbind/test/complete/
mkdir /data/lwl/PDBbind/test/missing/
mkdir /data/lwl/PDBbind/test/miss_N_O/

for pdb in `ls $pwa`
do

	cd $pwa/$pdb
	#获得残基C原子的三维坐标，去掉最后一行端基
	cat ${pdb}_protein.pdb | awk '$3 == "C" {print $7}' | sed '$d' > C_x
	cat ${pdb}_protein.pdb | awk '$3 == "C" {print $8}' | sed '$d' > C_y
	cat ${pdb}_protein.pdb | awk '$3 == "C" {print $9}' | sed '$d' > C_z
	#获得残基N原子的三维坐标，去掉第一行端基
	cat ${pdb}_protein.pdb | awk '$3 == "N" {print $7}' | sed '1d' > N_x
	cat ${pdb}_protein.pdb | awk '$3 == "N" {print $8}' | sed '1d' > N_y
	cat ${pdb}_protein.pdb | awk '$3 == "N" {print $9}' | sed '1d' > N_z
	#合并三维坐标文件
	paste C_x C_y C_z N_x N_y N_z > C_N.txt
	
	#获得相邻C/N原子的距离的平方
	awk '{print ($1-$4)**2+($2-$5)**2+($3-$6)**2}' C_N.txt > bond.txt
	
	#获得C/N原子异常的距离
	miss=$(awk  '$1>2 {print $0}' bond.txt)

	#蛋白质中C/N原子数量
	C_x_num=$(awk 'END{print NR}' C_x)
	N_x_num=$(awk 'END{print NR}' N_x)

	#判断C/N原子数量是否一致，若一致，则进行判断；若不一致，则将文件夹复制到/miss_N_O文件夹下
	if [[ "${C_x_num}" = "${N_x_num}" ]];then
	
		rm C_x C_y C_z N_x N_y N_z C_N.txt bond.txt
		cd ..
		
		if [[ "$miss" = "" ]];then
			cp -rf $pdb /data/lwl/PDBbind/test/complete/
		else
			cp -rf $pdb /data/lwl/PDBbind/test/missing/
		fi
	else
		rm C_x C_y C_z N_x N_y N_z bond.txt
		cd ..
		
		cp -rf $pdb /data/lwl/PDBbind/test/miss_N_O/
	fi
	
	

done
