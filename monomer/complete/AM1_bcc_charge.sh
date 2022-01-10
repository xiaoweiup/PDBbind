#!/usr/bin/env bash
# version 2.0
#file_dir=/home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/atom
file_dir=/home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/rerun
test -f /opt/software/amber20_src/amber.sh && source /opt/software/amber20_src/amber.sh
for name in `ls ${file_dir}`
do
	cd ${file_dir}/$name
        ((start=$(sed -n -e '/@<TRIPOS>ATOM/=' ${name}_ligand.mol2)+1))
        ((end=$(sed -n -e '/@<TRIPOS>BOND/=' ${name}_ligand.mol2)-1))
	unit_num=$(sed -n "${start},${end}p" ${name}_ligand.mol2 | awk '{print $8}' | awk '!a[$0]++' | awk 'END{print NR}')
        ######### single unit or multi-unit
        if [[ "$unit_num" -eq 1 ]];then
		ligand_name=$(tail -n 2 ${name}_ligand.mol2 | head -n 1 | awk '{print $2}')  
		molecular_charge=$(awk '$8 == "'${ligand_name}'" {print $9}' ${name}_ligand.mol2 | awk '{sum+=$1}END{printf("%.2f\n",sum)}')
		echo ${name}_${molecular_charge}
                ############### int or float    
		if [[ "${#molecular_charge}" -gt 2 ]];then
			floating=${molecular_charge#*.}
			floating_first=${floating:0:1}
			########################## Round off the charge
			if [[ "$floating_first" -ge 5 ]];then
				ele_pro=$(echo ${molecular_charge} | grep "-") 
				if [[ -n "${ele_pro}" ]];then
					molecular_charge_int=$(echo "${molecular_charge%.*}-1" | bc)
				else
					molecular_charge_int=$(echo "${molecular_charge%.*}+1" | bc)
				fi
			else
				molecular_charge_int=$(echo "${molecular_charge%.*}" | bc)
			fi
			molecular_charge=$molecular_charge_int
			#####################################	
		fi
		antechamber -i ${name}_ligand.mol2 -fi mol2 -o ${name}_ligand_amber.mol2 -fo mol2 -c bcc -pf y -j 4 -nc ${molecular_charge}
			if [ -f "${name}_ligand_amber.mol2" ]; then
				
				parmchk2 -i ${name}_ligand_amber.mol2 -f mol2 -o ligand.frcmod
			else
				echo $name >> ${file_dir%/*}/charge_error_2.log
			fi
	else
		
		echo $name >> ${file_dir%/*}/multi_unit_pdb_id.log
	fi	

done

