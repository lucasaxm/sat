#!/bin/bash
 
num_variaveis=500
num_ands=400
num_max_variaveis_no_or=5
 
sat='sat(" '
logictools=""
for i in `seq 1 $num_ands`
do
    sat+="("
    logictools+="("
    num_var=$(( $(( $RANDOM % $num_max_variaveis_no_or )) + 1 ))
    for j in `seq 1 $num_var`
    do
        number=$(( $(( $RANDOM % $num_variaveis )) + 1 ))
        istrue=$(( $RANDOM % 2))
        if [[ $istrue -eq 1 ]]; then
            sat+=" x$number "
            logictools+=" x$number "
        else
            sat+=" ~x$number "
            logictools+=" ~x$number "
        fi
       
        if [ $j -eq $num_var ]; then
            sat+=""
            logictools+=""
        else
            sat+="#"
            logictools+="v"
        fi
    done
    sat+=")"
    logictools+=")"
   
    if [ $i -eq $num_ands ]; then
        sat+=""
        logictools+=""
    else
        sat+=" & "
        logictools+=" & "
    fi
done
sat+='" ).'
 
clear
# echo -e '--------- Versão para usar no trabalho\n'
echo -e "$sat"> sat.in
# echo -e '--------- Versão para usar no logictools.org\n'
echo -e "$logictools" > logictools.in