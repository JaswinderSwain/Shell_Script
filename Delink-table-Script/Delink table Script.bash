#!/bin/bash


#############################################################################
#####                                                                   #####
#####       Delink table Script          					            #####
#####       			                                                #####
#####   Author: Jaswinder Swain                                         #####
#####                                                                   #####
#############################################################################


echo "***** Delink table Script *****"

final_De_link_table_script_prd=$(pgrep -c final_De_link_table_script_prd)

#This line uses the pgrep command to count the number of running processes with the name "final_De_link_table_script_prd". The count is stored in the variable final_De_link_table_script_prd.

if [ "$final_De_link_table_script_prd" -lt "5" ]; then

#This line starts an if statement to check if the value of final_De_link_table_script_prd is less than 5.

  while true; do
    echo ""
    echo "1 - Raw Table Delink"
    echo "2 - Final N Intermediate Table Delink"
    echo "3 - Final N Intermediate Table Addition"
    echo "0 - Exit"
    echo ""
    read -p "Please Enter Your Choice: " choice
	
	#These lines display the menu options for the user to choose from and read the user's input into the variable choice.
    
    case $choice in
      1)
	  #This line starts a case statement based on the value of choice.
        echo "***** 1 - Raw Table Delink *****"
        sudo sh /your/path/delink_tables/raw_table_Delink.sh
        ;;
	  #This case option is executed when the user enters 1. It displays a message and executes the script raw_table_Delink.sh with superuser privileges using sudo.
      2)
        echo "***** 2 - Final N Intermediate Table Delink *****"
        sudo sh /your/path/delink_tables/final_n_inter_Delink.sh
        ;;
		
		#This case option is executed when the user enters 2. It displays a message and executes the script final_n_inter_Delink.sh with superuser privileges using sudo.
      3)
        echo "***** 3 - Final N Intermediate Table Addition *****"
        sudo sh /your/path/delink_tables/final_n_inter_addition.sh
        ;;
		#This case option is executed when the user enters 3. It displays a message and executes the script final_n_inter_addition.sh with superuser privileges using sudo.
      0)
        exit
        ;;
		#This case option is executed when the user enters 0. It exits the script.
      *)
        echo "Invalid Number"
        ;;
    esac
  done
#This line marks the end of the infinite loop.
else

#This line is part of the if statement. It is executed when the condition in the if statement is false.

  echo $final_De_link_table_script_prd
  echo $Delink_table_script_prod1
  echo -e "\n\n\n\n"
  echo "***** Sorry someone is already running the script *****"
  echo -e "\n\n\n\n"
fi

#These lines display a message indicating that someone else is already running the script.

#The script assumes that you will replace /your/path/delink_tables/ with the actual path to the script files in your system.


########################################################## Part 1 :- final_n_inter_Delink.sh ##################################################################



#!/bin/sh

output_file="/your/path/delink_tables/decom_table.csv"
input_file="/your/path/delink_tables/Input_tables.csv"

#These lines define variables output_file and input_file to store the paths of the output file (decom_table.csv) and the input file (Input_tables.csv), respectively. Please replace the paths with the actual paths in your system.

> "$output_file"
echo "Table_name,status_before_change,status_After_change" >> "$output_file"

#These lines clear the content of the decom_table.csv file (if it exists) and then write the header line into the file.

export PGPASSWORD="password"

#This line sets the PGPASSWORD environment variable to the password of your PostgreSQL database. This is required for authentication when running PostgreSQL commands later in the script. Make sure to replace "password" with the actual password.

while IFS="," read -r f1
do

#This starts a while loop that reads each line from the Input_tables.csv file, with the delimiter set as a comma (,). Each line is stored in the variable f1.

    echo $f1
    f2=default"."$f1
    echo $f2
	
	#These lines echo the value of f1 (the table name) and set f2 to the concatenation of the string "default". and the table name.

    tbl_stat=$(psql -h 00.000.00.0 -d database_name -U postgres --tuples-only -c "select active from SCHEMA_INFO_TABLE where lower(tablename) = '${f2}'")
	
	#This line executes a PostgreSQL query using the psql command to retrieve the active status of the table specified by f2. The result is stored in the variable tbl_stat.

    echo "tbl_stat=${tbl_stat}"

    if [[ "$tbl_stat" == *"t"* ]]; then
	
	#This line checks if the value of tbl_stat contains the substring "t" (indicating an active table). If it does, the following code block is executed
	
        id=$(psql -h 00.000.00.0 -d database_name -U postgres --tuples-only -c "select id from SCHEMA_INFO_TABLE where lower(tablename) = '${f2}'")
        echo psql_query_completed
        echo $id
        echo id
		
		#These lines execute a PostgreSQL query to retrieve the id of the table specified by f2. The id is stored in the variable id, and then it is echoed for debugging purposes.
		
        update=$(psql -h 00.000.00.0 -d database_name -U postgres --tuples-only -c "update SCHEMA_INFO_TABLE set active='f' where id = ${id}")
        echo $update
		
		#These lines execute a PostgreSQL query to update the active status of the table specified by id to 'f' (false). The result of the update query is stored in the variable update, and then it is echoed for debugging purposes.
		
        tbl_stat1=$(psql -h 00.000.00.0 -d database_name -U postgres --tuples-only -c "select active from SCHEMA_INFO_TABLE where lower(tablename) = '${f2}'")

        echo "$tbl_stat1"

        if [[ "$tbl_stat1" == *"t"* ]]; then
            echo "afterchanging_table_status_not_updated=${tbl_stat1}"
            tbl_stat1="status_not_updated"
        else
            echo "afterchanging_table_status_changed=${tbl_stat1}"
            tbl_stat1="status_updated"
        fi
    else
        echo "table_alredy_in_false_state=${tbl_stat}"
        tbl_stat1="status_remains_same"
    fi

    echo "$f1,$tbl_stat,$tbl_stat1" >> "$output_file"

done < "$input_file"

mail -s 'Decommsioned jobs | changing active status of table in production' -a "$output_file" jaswinderswain7@gmail.com  <<< 'Hi All, Please find attached the decommissioned job status list.'


########################################################## Part 2 :- raw_table_Delink.sh ########################################################################



#!/bin/sh

output_file="/your/path/delink_tables/decom_raw_table.csv"
input_file="/your/path/delink_tables/Input_raw_tables.csv"

#These lines define variables output_file and input_file to store the paths of the output file (decom_raw_table.csv) and the input file (Input_raw_tables.csv), respectively. Replace the paths with the actual paths in your system.

> "$output_file"
echo "Table_name,status_before_change,status_After_change" >> "$output_file"

#These lines clear the content of the decom_raw_table.csv file (if it exists) and then write the header line into the file.

export PGPASSWORD="password"

#This line sets the PGPASSWORD environment variable to the password of your PostgreSQL database. This is required for authentication when running PostgreSQL commands later in the script. Replace "password" with the actual password.

while IFS="," read -r f1
do

#This starts a while loop that reads each line from the Input_raw_tables.csv file, with the delimiter set as a comma (,). Each line is stored in the variable f1.

    echo $f1
    f2=default"."$f1
    echo $f2
	
	#These lines echo the value of f1 (the table name) and set f2 to the concatenation of the string "default". and the table name.

    tbl_stat=$(psql -h 00.000.00.0 -d database_name -U postgres --tuples-only -c "select active from SCHEMA_INFO_TABLE where lower(tablename) = '${f2}'")

	#This line executes a PostgreSQL query using the psql command to retrieve the active status of the table specified by f2. The result is stored in the variable tbl_stat.

	
    echo "tbl_stat=${tbl_stat}"

    if [[ "$tbl_stat" == *"t"* ]]; then
        echo psql_started
		#This line checks if the value of tbl_stat contains the substring "t" (indicating an active table). If it does, the following code block is executed.
        id=$(psql -h 00.000.00.0 -d database_name -U postgres --tuples-only -c "select id from SCHEMA_INFO_TABLE where lower(tablename) = '${f2}'")

        echo psql_query
        echo $id
        echo id
		
		#These lines execute a PostgreSQL query to retrieve the id of the table specified by f2. The id is stored in the variable id, and then it is echoed for debugging purposes.

        delete=$(psql -h 00.000.00.0 -d database_name -U postgres --tuples-only -c "delete from SCHEMA_INFO_TABLE where id = ${id}")
        echo $delete
		
		#These lines execute a PostgreSQL query to delete the row from the SCHEMA_INFO_TABLE with the specified id. The result of the delete query is stored in the variable delete, and then it is echoed for debugging purposes.

        tbl_stat1=$(psql -h 00.000.00.0 -d database_name -U postgres --tuples-only -c "select active from SCHEMA_INFO_TABLE where lower(tablename) = '${f2}'")

        echo $tbl_stat1
		
		#These lines execute a PostgreSQL query

        if [[ "$tbl_stat1" == *"t"* ]]; then
            echo "afterchanging_table_status_not_updated=${tbl_stat1}"
            tbl_stat1="status_not_updated"
            echo $tbl_stat1
        else
            echo "afterchanging_table_status_changed=${tbl_stat1}"
            tbl_stat1="status_updated"
            echo $tbl_stat1
        }
    else
        echo "table_already_in_false_state=${tbl_stat}"
        echo $tbl_stat
        tbl_stat1="status_remains_same"
        tbl_stat="f"
    }

    echo "$f1,$tbl_stat,$tbl_stat1" >> "$output_file"

    cat "$output_file"

done < "$input_file"

mail -s 'Decommissioned jobs | changing active status of table in production' -a "$output_file" jaswinderswain7@gmail.com <<< 'Hi All, Please find attached the decommissioned job status list.'





















