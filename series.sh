#!/bin/bash

file=series.file
temp=/tmp/$$.series

trap 'rm -f $temp' EXIT

list()
{
    awk < $file -F: '{printf "%s %s -> %s\n",$1,$2,$3}'     
}

modify()
{
    echo -e "Serie no: \c"
    read pos
    echo -e "Novo episódio: \c"
    read new_ep
	old=$(sed s/'\.'/'\\.'/ $file | sed s/'\ '/'\\ '/ | grep -e ^$pos)
	echo $new_ep > $temp
	new=$(sed s/'\.'/'\\.'/ $temp | sed s/'\ '/'\\ '/)
	posi=0

	IFS='
	'

	for i in $(cut -d: -f2 series.file) 
	do 
		posi=$(($posi+1))
		if [ $posi -eq $pos ]
		then 
			name=$i
		fi
	done

	IFS=""
	sed s/$old/$pos:$name:$new/ $file > $temp
	unset IFS
	cat $temp > $file
	> $temp
}

delete()
{
	echo -e "Serie no: \c"
	read pos
	posf=0
	IFS='
	'
	for i in $(cat $file)
	do
		posi=${i%%:*}
		if [ $posi -ne $pos ]
		then
			posf=$(($posf+1))
			name=$(cut -d: -f2 $file | awk FNR==$posi)
			next=$(cut -d: -f3 $file | awk FNR==$posi)
			echo $posf:$name:$next >> $temp
		fi
	done
	unset IFS		
	cat $temp > $file
	> $temp
}

add()
{
	echo -e "Name: \c"
	read name
	echo -e "Next: \c"
	read next
	for line in $(cat $file)
	do
		pos=${line%%:*}
	done
	pos=$(($pos+1))
	echo $pos:$name:$next >> $file
}

menu()
{
	echo -e "\n\n"
	echo "l) List"
	echo "a) Add"
	echo "m) Modify"
	echo "d) Delete"
	echo "q) Quit"
	echo -e "Opção: \c"
	read opt
	case $opt in
		l) list;menu;;
		a) add;menu;;
		m) modify;menu;;
		d) delete;menu;;
		q) exit 0;;
		*) echo FAIL;;
	esac
}

menu