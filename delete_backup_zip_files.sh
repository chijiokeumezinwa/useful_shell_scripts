
#!/bin/bash


# For the previous months we should have only the last day of the month backup or the last back up the exists for
#  the month, then for the current month we should have all the backups days .

# so when the current month ends then it will become in a previous month and we only gonna have the last day backup of that month
# and the new current month we wil have all days

# this process should run at 2am daily

y_f=$(ls -lArth --time-style='+%Y-%m-%d-%H.%M.%S' | grep '\.zip$' | awk '{print $7}' | tail -n 1)
o_f=$(ls -lArth --time-style='+%Y-%m-%d-%H.%M.%S' | grep '\.zip$' | awk '{print $7}' | head -n 1)

diff=0
DATE1=$(date -r $o_f '+%Y%m')
DATE2=$(date -r $y_f '+%Y%m')

function dateDiffMonth() {
    y1=${DATE1:0:4}
    m1=${DATE1:4:2}

    y2=${DATE2:0:4}
    m2=${DATE2:4:2}

    diff=$(( $y2 - $y1 ))
    echo $diff
    diff=$(( diff * 12 ))
    echo $diff
    diff2=$(( 10#$m2 - 10#$m1 ))
    echo $diff2
    diff=$(( $diff + $diff2 ))
    echo diff

    echo $diff #compute the months difference 12*year diff+ months diff -> 10# force the shell to interpret the following number in base-10
}

# RESULT='dateDiffMonth $DATE1 $DATE2'
dateDiffMonth $DATE1 $DATE2
echo "there is a gap of $diff months betwen $DATE2 and $DATE1"


TODAY_DATE=$(date)


newdiff=$(( $diff+1 ))

printf "$TODAY_DATE Files to be deleted\n" > filestobedeleted-$(date +"%m-%d-%Y_%H-%M-%S").txt
printf "\n\n" >> filestobedeleted-$(date +"%m-%d-%Y_%H-%M-%S").txt

organize_files () {
    
    pwd
    jobdone=0

    counter=1

    while [[ "$counter" -ne "$newdiff" ]]; do
        output=$(ls -lArth --time-style='+%Y-%m-%d-%H.%M.%S' | grep "$(date -d "-$counter month" '+%Y-%m')" | grep '\.zip$')

        if [[ -n "$output" ]];then
            echo 'there is output'
            
            youngest_file=$(ls -lArth --time-style='+%Y-%m-%d-%H.%M.%S' | grep "$(date -d "-$counter month" '+%Y-%m')" | grep '\.zip$' | awk '{print $7}' | tail -n 1)
            echo $youngest_file
            
            date_youngest_file=$(date -r $youngest_file '+%Y%m%d')
            


            for file in $(ls -lArth --time-style='+%Y-%m-%d-%H.%M.%S' | grep "$(date -d "-$counter month" '+%Y-%m')" | grep '\.zip$' | awk '{print $7}' ); do 
                date_file=$(date -r $file '+%Y%m%d')

                printf "current file $file: $date_file youngest file $youngest_file youngest date: $date_youngest_file\n"
                if [ "$date_file" -lt "$date_youngest_file" ]; then 
                    echo "we can delete the file $file"; path_of_file="$(readlink -f $file)";
                    printf "$path_of_file\n" >> filestobedeleted-$(date +"%m-%d-%Y_%H-%M-%S").txt
                    rm "$file"
                fi;
            done
            
        else
            echo 'no output'
        fi
        counter=$(( $counter + 1))
    done


    printf "end\n"
}

organize_files
