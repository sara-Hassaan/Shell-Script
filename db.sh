#!/bin/bash
shopt -s extglob
clear
##########
echo create Database Repo
read db_name
mkdir ./"$db_name"
cd ./"$db_name"/
##########
i="y"
while [ $i = "y" ]
do
clear
	echo "1.Create a Table "
	echo "2.View a Table "
	echo "3.Insert Record To a Table"
	echo "4.Update Record To a Table"
	echo "5.Delete Record From a Table "
	echo "6.View   Record  From a Table "
	echo "7.View   All Tables of DB "
	echo "8.Drop Table From DB "
	echo "9.Exit "
	echo "Enter your choice "
	read ch
	case $ch in
#create Table 
	1)
	echo "Enter table name"
	read tableName
	touch $tableName
	touch $tableName.meta
	echo "Enter primary key"
	read pk
	echo $pk >>$tableName.meta
	select choice in "Number" "String"
		do
		case $choice in 
		Number) var=`head -n 1 $tableName.meta`
		      var=$var:int:primary
		     # echo $var
		      echo $var>$tableName.meta
		break;;

		String) var=`head -n 1 $tableName.meta`
		      var=$var:String:primary
		      echo $var
		      echo $var>$tableName.meta
		break;;

		*) print $REPLY is not one of the choices.
		   print Try again
		;;
		esac
	done
	#----------------cols-------------------
	echo "Enter number of cols"
	read colNo
	i=0
	while test $i -lt  $colNo
	do
		echo "Enter col name"
		read colName
		select choice in "Number" "String"
		do
			case $choice in
			Number)
			      colName=$colName:int
			      echo $colName
			      echo $colName>>$tableName.meta

			break;;
			String)
			      colName=$colName:String
			      echo $colName
			      echo $colName>>$tableName.meta
			break;;

			*) echo $REPLY is not one of the choices.
			   echo Try again
			;;
			esac
			done
			let i=i+1
	done
	;;
#view Table 
	2)
	echo "Enter name of Table to be Viewed "
	read table_name
	ls ./"$db_name" | cat  $table_name
	;;
#Insert new records to table
	3)
	clear
	echo enter table name
	read table_name
	echo "Enter new Primary key id to check if possible to insert "
	read pk_val
 	colsNo=`wc -l < ./"$table_name".meta`
	index=0
	count=2
	if [ -z `grep ^$pk_val ./$table_name | cut -d"," -f1` ]; then
		while [[ index -lt  $colsNo-1 ]]
		do
			echo Valid 
			col_name="$(sed "${count}q;d"  $table_name.meta | cut -d: -f1)"
			echo "Enter $col_name";
			read val
			if [ $index -eq 0 ]
			then 
				var=$val
			else
				var=$var,$val
			fi
			index=$(($index+ 1))
			let count=count+1
		done
	printf $pk_val,>>./$table_name
	printf $var"\n">>./$table_name
	cat $table_name
	else
		echo "Primary Key Violation id cannot be redundant"
	fi
	;;
#Update Records To a Table
	4)
	echo "Enter name of Your Table "
	read table_name
	count=1
	data=''
	flag=0
	colNo="$( wc -l < $table_name.meta)"
	while test $count -le $colNo #<colNo
	do
		if [ $count -eq 1 ]
		then
			echo "Enter Id of Record to be updated"
			read col
			id=$col
			check="$(sed -n "/$id/p "  "$table_name" | cut -d: -f1)"
		else
			var="$(sed "${count}q;d"  $table_name.meta | cut -d: -f1)"
			echo "Enter $var"
			read col
		fi

		case $col in
			+([[:digit:]])) variable="int" ;;
			+([[:alpha:]])) variable="String" ;;
			*) echo "Unmatched Entry !";;
		esac
		varx="$(sed "${count}q;d" $table_name.meta | cut -d: -f2)"
		if [ $varx != $variable ]
		then
			echo "wrong col datatype"
			let flag=0
		break
		else
			if [ $count -eq 1 ]
			then
				data=$col
			else
				data=$data,$col
			fi
		let flag=1
		fi
		let count=count+1
	done
	if [ $flag -eq 1 ];
	then
	set -a
	sed '/'^$id'/d'   $table_name >.table1
	echo $data >>.table1
	cp .table1 $table_name
	cat $table_name
	echo "Record is updated"
	else
	echo "not updated"
	fi
	;;
#Delete Records From Table
	5)
	echo "Enter name of Your Table "
	read table_name
	echo "Enter Id of Record to be deleted"
	read id
	set -a
	sed '/'^$id'/d'   $table_name >.table1
	#grep -v "$id" $table_name >.table1
	cp .table1 $table_name
	echo "$table_name Content Is: "
	cat $table_name      
	echo "Record is deleted" 
	;;
#View Specific records of table
	6)
	echo "Enter name of Your Table "
	read table_name
	echo "Enter Primary Key id "
	read pk_val
	sed  " ${pk_val}q;d " $table_name;
	#cut -d "," -f $table_name"| grep -i "$id" | awk -F"," '{print $0}' $table_name "
	;;

#List All Tables of Data Base	
	7)
	echo __________________________________
	echo "          Database Tables"
	echo ----------------------------------
	echo
	ls  -I "*.meta" -I "*.sh"
	echo
	echo __________________________________
	;;
#Drop Table From DB 
	8)
	echo Enter Table Name to be dropped
	read table_name
	rm ./"$table_name"
	echo
	echo "Tables that Still In Your DB Are:"
	ls  -I "*.meta" -I "*.sh"
	;;

#exit
	9)exit
	;;

	*)echo "Invalid choice "
	;;
	esac

	echo "Do u want to continue ?"
	read i
	if [ $i != "y" ]
	then
	    exit
	fi
done  

