#!/bin/bash

#SBATCH -p gpu
#SBATCH -N 1
#SBATCH -n 5
#SBATCH --gres=gpu:1
#SBATCH --no-requeue

test -f /opt/software/amber20_src/amber.sh && source /opt/software/amber20_src/amber.sh

pwa=/home/user/Documents/wjm/PDBbind/refined-set/monomer/complete/rerun

for file in `ls $pwa`
do

	cd $pwa/$file
	echo $file
	echo min_wat_progress
	pmemd.cuda -O -i min_wat.in -o min_wat.out -p ${file}_complex_binding.prmtop -c ${file}_complex_binding.inpcrd -r min_wat.rst -x min_wat.netcdf -ref ${file}_complex_binding.inpcrd
	echo min_sys_progress
	pmemd.cuda -O -i min_sys.in -o min_sys.out -p ${file}_complex_binding.prmtop -c min_wat.rst -r min_sys.rst -x min_sys.netcdf -ref min_wat.rst
	echo heat_progress
	pmemd.cuda -O -i heat.in -o heat.out -p ${file}_complex_binding.prmtop -c min_sys.rst -r heat.rst -x heat.netcdf -ref min_sys.rst
	echo density_progress
	pmemd.cuda -O -i density.in -o density.out -p ${file}_complex_binding.prmtop -c heat.rst -r density.rst -x density.netcdf -ref heat.rst
	echo equil_progress
	pmemd.cuda -O -i equil.in -o equil.out -p ${file}_complex_binding.prmtop -c density.rst -r equil.rst -x equil.netcdf

done

echo Jobs have finished!

