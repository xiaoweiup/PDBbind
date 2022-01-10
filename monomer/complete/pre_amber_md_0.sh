#!/bin/bash

######################################################################################################################################
																     #
#此脚本用于PBDbind数据库中复合物体系的构建，即体系的溶剂化及其拓扑和坐标文件的生成；并生成MD输入文件和运行脚本。——By liuwenlang 2021.12.02            #
																     #
######################################################################################################################################
test -f /opt/software/amber20_src/amber.sh && source /opt/software/amber20_src/amber.sh
file_dir=/home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/atom_pick


for name in `ls ${file_dir}`
do 

	cd ${file_dir}/$neme 
	#生成去氢的蛋白质文件.
	cat ${neme}_protein.pdb | grep -E 'HETATM|ATOM|TER' | sed '/      H/d' > ${neme}_protein_nH.pdb  
	#生成tleap的输入文件.
	echo "source oldff/leaprc.ff14SB
source leaprc.gaff2
loadamberparams ligand.frcmod
LIG=loadmol2 ${name}_ligand_amber.mol2
pro=loadpdb ${neme}_protein_nH.pdb
com=combine {pro LIG}
charge com
addions com Cl- 0
addions com Na+ 0
source leaprc.water.tip3p
solvateBox com TIP3PBOX 10
savepdb com ${name}_complex_binding.pdb
saveamberparm com ${neme}_complex_binding.prmtop ${neme}_complex_binding.inpcrd
quit" > leap.in

	#命令3，运行tleap组件生成溶剂化后体系的拓扑和坐标文件.
	tleap -f leap.in > leap.out

	#判断蛋白质溶质单元数量,删除水和离子，最后一行ATOM的第五列数字即为该数量.
	unit_num=$(grep 'ATOM' ${pdb}_complex_binding.pdb | sed '/WAT/d;/Na+/d;/Cl-/d' \
|tail -n 1 | awk '{print $5}')
	
	#输出警告和错误的数量信息，注意amber16及以下版本，没有"Exiting LEaP",根据实际情况修改.
	echo $pdb >> ${pdb_dir%/*}/leap-warning-error.log
	cat leap.out | grep -E 'Exiting LEaP' >> ${pdb_dir%/*}/leap-warning-error.log


####################################生成模拟的输入文件#######################################
	echo " System minimization:
&cntrl
   imin=1, 
   ntmin=1, 
   nmropt=0, 
   drms=0.1
   maxcyc=2000, 
   ncyc=1500, 
   ntx=1, 
   irest=0,
   ntpr=100, 
   ntwr=100, 
   iwrap=0,
   ntf=1, 
   ntb=1, 
   cut=10.0, 
   nsnb=20,
   igb=0,
   ibelly=0, 
   ntr=1,
   restraintmask='!:WAT', 
   restraint_wt=10.0,
/" > min_wat.in                                                                                   
  
	echo "Entire system minimization
  &cntrl
  imin=1,
  maxcyc=20000,
  ncyc=10000,
  ntf=2,
  ntc=2,
  ntb=1,
  ntpr=5000,
  ntwr=5000,
  ntwx=2000,
  cut=10.0,
  ntr=1,
  restraintmask=':1-${unit_num}',
  restraint_wt=10.0,
/" > min_sys.in
                                                                                           
	echo "Heat
 &cntrl
  imin=0,
  ntx=1,
  irest=0,
  nstlim=200000,dt=0.002,
  ntf=2,
  ntc=2,
  tempi=0.0,
  temp0=300.0,
  ntpr=1000,
  ntwx=1000,
  ntwr=10000,
  cut=10.0,
  ntb=1,
  ntt=3,
  gamma_ln=2.0,
  ntwv = 0
  ig=-1,
  ntr=1,
  nmropt=1,
  restraintmask=':1-${unit_num}',
  restraint_wt=2.0,
/
&wt TYPE='TEMP0', istep1=0, istep2=190000, value1=0.0, value2=300.0 /
&wt TYPE='TEMP0', istep1=190001, istep2=200000, value1=300.0, value2=300.0 /
&wt TYPE='END',
/" > heat.in                                                                   
       
	echo " density 
    &cntrl
    imin=0, 
    irest=1, 
    ntx=5,
    ntb=2, 
    pres0=1.01325, 
    ntp=1,
    taup=5.0,
    cut=10.0,
    ntc=2, 
    ntf=2,
    tempi=300.0,
    temp0=300.0,
    ntt=3,
    gamma_ln=2.0,
    nstlim=50000,
    dt=0.002,
    ntpr=5000,
    ntwx=5000,
    ntwr=500,
    ntr=1,
    restraintmask=':1-${res_num}',
    restraint_wt=10.0,
/" > density.in
	                                                                                    
	echo " equil_MD 
    &cntrl
    imin=0, 
    irest=1, 
    ntx=5,
    ntb=2, 
    pres0=1.01325, 
    ntp=1,
    taup=5.0,
    cut=10.0,
    ntc=2, 
    ntf=2,
    tempi=300.0,
    temp0=300.0,
    ntt=3,
    gamma_ln=2.0,
    nstlim=500000,
    dt=0.002,
    ntpr=10000,
    ntwx=10000,
    ntwr=500,
/" > equil.in                                                                                 
                                                                                                                                                                                
                                                                                              
####################################生成模拟的输入文件#######################################


#####################生成运行脚本，这里脚本适用于超算GPU节点，可根据情况修改#######################

	echo "#!/bin/bash

#SBATCH -p gpu
#SBATCH -N 1
#SBATCH -n 5
#SBATCH --gres=gpu:1
#SBATCH --no-requeue

export MODULEPATH=/dat01/paraai_test/software/modulefiles:
module load amber/18


echo min_wat_progress
pmemd.cuda -O -i min_wat.in -o min_wat.out -p ${pdb}_complex_binding.prmtop -c ${pdb}_complex_binding.inpcrd -r min_wat.rst -x min_wat.netcdf -ref $top.inpcrd
echo min_sys_progress
pmemd.cuda -O -i min_sys.in -o min_sys.out -p ${pdb}_complex_binding.prmtop -c min_wat.rst -r min_sys.rst -x min_sys.netcdf -ref min_wat.rst
echo heat_progress
pmemd.cuda -O -i heat.in -o heat.out -p ${pdb}_complex_binding.prmtop -c min_sys.rst -r heat.rst -x heat.netcdf -ref min_sys.rst
echo density_progress
pmemd.cuda -O -i density.in -o density.out -p ${pdb}_complex_binding.prmtop -c heat.rst -r density.rst -x density.netcdf -ref heat.rst
echo equil_progress
pmemd.cuda -O -i equil.in -o equil.out -p ${pdb}_complex_binding.prmtop -c density.rst -r equil.rst -x equil.netcdf

echo Jobs have finished!
" | sed 's/modulefiles:/modulefiles:$MODULEPATH/g' > ${neme}_run.sh

#####################生成运行脚本，这里脚本用于超算GPU节点，可根据情况修改#######################

done
