#! /usr/bin/bash
#if creation of archive is required


g++ checksum.cpp -o checksum > /dev/null
file=$2


flag=1
len=$#
#echo $len
args=("$@")

function list(){
    #! /usr/bin/bash
blocks=0
while [[ $(head $file -c $((blocks*512+1))| tail -c 1) != '' ]]
do
name=`head $file -c $((${blocks}*512 + 100)) | tail -c 100`

permissions=`head $file -c $((${blocks}*512 + 108)) | tail -c 8`


#echo $permissions
# uid=`head $file -c $((${blocks}*512 + 116)) | tail -c 8`
# gid=`head $file -c $((${blocks}*512 + 124)) | tail -c 8`
# uidfinal=`printf "%d" $uid`
# gidfinal=`printf "%d" $gid`

# echo $uidfinal $gidfinal
size=`head $file -c $((${blocks}*512 + 136)) | tail -c 12`
sized=`printf "%d" $size`
#echo $sized
mtime=`head $file -c $((${blocks}*512 + 148)) | tail -c 12`
#echo $mtime
uname=`head $file -c $((${blocks}*512 + 297)) | tail -c 32`
gname=`head $file -c $((${blocks}*512 + 329)) | tail -c 32`
# echo $uname $gname

# username=`cat /etc/passwd | grep $uidfinal | awk -F ':' '{print $1}'`
# groupname=`cat /etc/group | grep $gidfinal | awk -F ':' '{print $1}'`

#chown  $username:$groupname $name
$((++blocks))

mtimed=`printf "%d" 00$mtime`
#touch $name --date="@$mtimed"

if [[ $flag -eq 1 ]]
then
    printf "%o " $permissions
    printf "%s/%s " $uname $gname
    printf "%11d " $sized
    printf "%s " $(date --date="@$mtimed" "+%Y-%m-%d %H:%M")

    
fi
echo $name
rem=$((sized%512))
blocks=$((blocks + sized/512))
if [[ rem -ne 0 ]]
then
    $((++blocks))
fi
done
}


function create_append(){
touch $file


for ((i=2; i<${len}; i++))
do
    name=$(basename ${args[$i]})
    
    #name=${args[$i]}
    #echo ${name}
    #uname=`ls -lah ${args[$i]} | awk '{print $3}'`
    uname=`stat -c %U ${args[$i]}`
    #echo ${uname}
    #gname=`ls -lah ${args[$i]} | awk '{print $4}'`
    gname=`stat -c %G ${args[$i]}`
    #echo ${gname}
    #uid=`cat /etc/passwd | grep ${uname} | awk -F ':' '{print $3}'`
    #gid=`cat /etc/passwd | grep ${uname} | awk -F ':' '{print $4}'`
    uid=`stat -c %u ${args[$i]}`
    gid=`stat -c %g ${args[$i]}`
    #echo ${uid}
    uido=`printf "%.7o" $uid`
    #echo $uido
    gido=`printf "%.7o" $gid`
    #echo $gido
    #size=`ls -l ${args[$i]} | awk '{print $5}'`
    size=`stat -c %s ${args[$i]}`
    sizefinal=`printf "%.11o" $size`
    #echo $sizefinal
    mtimeo=`stat -c %Y ${args[$i]}`
    mtime=`printf "%.11o" $mtimeo`
    #echo $mtime
    permissions=`printf "%.7d" $(stat -c %a ${args[$i]})`
    #echo $permissions
    
    checksum=`./checksum $name $permissions $uido $gido $sizefinal $mtime "        " ustar 00 $gname $uname 00000000000000 0`
    #echo $checksum
    echo -ne $name >> $file
    for((j=0; j<(100-${#name}); j++))
    do
        echo -ne "\0000" >> $file
    done

    echo -ne "$permissions\0000" >> $file
    echo -ne "$uido\0000" >> $file
    echo -ne "$gido\0000" >> $file
    echo -ne "$sizefinal\0000" >> $file
    echo -ne "$mtime\0000" >> $file
    echo -ne "$checksum\0000 " >> $file

    echo -ne "0" >> $file

    for((j=0; j<(100); j++))
    do
        echo -ne "\0000" >> $file
    done
    
    echo -ne "ustar\0000" >> $file
    echo -ne "00" >> $file
    echo -ne $uname >> $file

    for((j=0; j<(32-${#uname}); j++))
    do
        echo -ne "\0000" >> $file
    done

    echo -ne $gname >> $file

    for((j=0; j<(32-${#gname}); j++))
    do
        echo -ne "\0000" >> $file
    done
    echo -ne "0000000\0000" >> $file
    echo -ne "0000000\0000" >> $file

    for((j=0; j<167; j++))
    do
        echo -ne "\0000" >> $file
    done
    
    cat ${args[$i]} >> $file

    rem=$(($size%512))

    if [[ $rem -ne 0 ]]
    then
        for((j=0; j<(512-${rem}); j++))
            do
                echo -ne "\0000" >> $file
            done
    fi

    if [[ $flag -eq 1 ]]
    then
    printf "%o " $permissions
    printf "%s/%s " $uname $gname
    printf "%11d " $size
    printf "%s " $(date --date="@$mtimeo" "+%Y-%m-%d %H:%M")
    fi
    echo $name
done

for((j=0; j<1024; j++))
do
    echo -ne "\0000" >> $file
done
}

function extract(){
blocks=0
while [[ $(head $file -c $((blocks*512+1))| tail -c 1) != '' ]]
do
name=`head $file -c $((${blocks}*512 + 100)) | tail -c 100`
#echo $name
permissions=`head $file -c $((${blocks}*512 + 108)) | tail -c 8`
#echo $permissions
# uid=`head $file -c $((${blocks}*512 + 116)) | tail -c 8`
# gid=`head $file -c $((${blocks}*512 + 124)) | tail -c 8`
# uidfinal=`printf "%d" $uid`
# gidfinal=`printf "%d" $gid`

# echo $uidfinal $gidfinal
size=`head $file -c $((${blocks}*512 + 136)) | tail -c 12`
sized=`printf "%d" $size`
#echo $sized
mtime=`head $file -c $((${blocks}*512 + 148)) | tail -c 12`
#echo $mtime
uname=`head $file -c $((${blocks}*512 + 297)) | tail -c 32`
gname=`head $file -c $((${blocks}*512 + 329)) | tail -c 32`
# echo $uname $gname

touch $name
chmod  $permissions $name
# username=`cat /etc/passwd | grep $uidfinal | awk -F ':' '{print $1}'`
# groupname=`cat /etc/group | grep $gidfinal | awk -F ':' '{print $1}'`

#chown  $username:$groupname $name
$((++blocks))
head $file -c $((${blocks}*512+$sized))  | tail -c $sized > $name
mtimed=`printf "%d" 00$mtime`
touch $name --date="@$mtimed"

if [[ $flag -eq 1 ]]
then
    printf "%o " $permissions
    printf "%s/%s " $uname $gname
    printf "%11d " $sized
    printf "%s " $(date --date="@$mtimed" "+%Y-%m-%d %H:%M")

    
fi
echo $name

rem=$((sized%512))
blocks=$((blocks + sized/512))
if [[ rem -ne 0 ]]
then
    $((++blocks))
fi
done

}

function striparchive(){
echo
}

flags=$1
echo $flags
case $flags in
tf) 
flag=0
list
;;
tvf)
flag=1
list
;;
cf)
rm $file
flag=0
create_append
;;
cvf)
rm $file
flag=1
create_append
;;
xvf)
flag=1
extract
;;
xf)
flag=1
extract
;;
rf)
striparchive
create_append
;;
rvf)
flag=1
striparchive
create_append
;;
esac