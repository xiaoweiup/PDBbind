#!/usr/bin/env bash
# 挑选出需要重跑的含有二硫键的初始文件
file=out.log
path1=atom_pick_2
path2=rerun
while read name     
do
	cp -avx $path1/$name $path2/$name
	
done <$file     
