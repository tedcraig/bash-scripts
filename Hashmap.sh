#! /usr/bin/env bash

# hashmap experiments
create_hashmap() {
    [[ $# -lt 1 ]] && {
        echo "$FUNCNAME requires at least one argument."
        exit 1
    }
    
    # setup infrastructure for this hashmap instance
    local this=$1
    local class="Hashmap"
    
    eval "${this}_KEYS=()"
    eval "${this}_VALUES=()"
    eval "${this}_AVAILABLE_INDEXES=(0)"
    
    for method in $(compgen -A function "${class}_")
    do
      echo "$method in loop";
      local prep="${method/#$class\_/$this::}() { ${method} ${this} "'$@'"; }"
      echo $prep
      eval $prep
    done
    
    # handle any key/value pairs passed to us
    shift # remove instance name arg
    [[ $# -lt 1 ]] && {
        # no key/value pairs, so break out of this function
        return
    }
    Hashmap_add "${this}" "$@"
}

# add key/value pairs to hashmap
Hashmap_add() {
    # echo "${FUNCNAME[0]} invoked"
    # echo "args: $@"
    local this=$1
    # handle key/value pairs passed to us
    shift # remove instance name arg
    [[ $# -lt 1 ]] && {
        # no key/value pairs, so break out of this function
        return
    }
    for kv_pair in $@; do
        local KEY=${kv_pair%=*}
        local VAL=${kv_pair#*=}
        # eval 'local INDEX=${#'"$this"'_KEYS[@]}'
        eval 'local INDEX=${'"${this}"'_AVAILABLE_INDEXES[0]}'
        eval 'local INDEXES_LENGTH=${#'"${this}"'_AVAILABLE_INDEXES[@]}'
        
        

        local prep=

        if [[ "${INDEXES_LENGTH}" == "1" ]]; then
            # we must be pushing on to the end of the array
            # so update the value to be the new index for the next array element
            # echo "available indexes: ${INDEXES_LENGTH}"
            # echo "1 available index.  Overwrite"
            prep="${this}"'_AVAILABLE_INDEXES[0]='"$(( INDEX + 1 ))"
            # echo $prep
            eval $prep
        else
            # remove the 0-th index of AVAILABLE_INDEXES since it is now in use
            # echo "available indexes: ${INDEXES_LENGTH}"
            prep="${this}"'_AVAILABLE_INDEXES=(${'"${this}"'_AVAILABLE_INDEXES[@]:1})'
            # echo $prep
            eval $prep
        fi

        eval 'INDEXES_LENGTH=${#'"${this}"'_AVAILABLE_INDEXES[@]}'
        # echo "updated avail indexes: ${INDEXES_LENGTH}"
        
        # echo "KEY: $KEY | VAL: $VAL | INDEX: $INDEX"
        
        local prep="${this}"'_KEYS['"${INDEX}"']='"${KEY}"
        # echo "$prep"
        eval $prep
        
        prep="${this}"'_VALUES['"${INDEX}"']='"${VAL}"
        # echo "$prep"
        eval $prep
        
        prep="${this}"'_KEY_'"${KEY}"'='"${INDEX}"
        # echo "$prep"
        eval $prep
    done
}

Hashmap_get() {
    # echo "${FUNCNAME[0]} invoked"
    # echo "args: $@"
    local this=$1
    local KEY=$2
    local prep='local var="${'"${this}"'_KEY_'"${KEY}"'}"'
    # echo $prep
    eval "$prep"
    # echo "var: ${var}"
    [[ -z  ${var} ]] && {
        echo "${FUNCNAME[0]}: Unable to get $this hashmap value. Unknown key: $KEY"
        exit 1
    }
    local prep='local INDEX=${'"${this}_KEY_${KEY}"'}'
    # echo $prep
    eval $prep
    # echo "INDEX: ${INDEX}"
    prep='local VAL=${'"${this}"'_VALUES['"${INDEX}"']}'
    # echo $prep
    eval $prep
    # echo "$KEY: $VAL"
    echo "${VAL}"
}

Hashmap_delete() {
    echo "${FUNCNAME[0]} invoked"
    echo "args: $@"
}

other_func() {
    # echo ${FUNCNAME[0]} invoked
    echo "one two three"
}

create_hashmap hmOne

echo
echo "adding age and name to hmOne"
hmOne::add age=48
hmOne::add name=djthadius

echo
echo "get..."
echo "assign to age"
age=$(hmOne::get age)
echo "age: $age"
echo "assign to name"
name=$(hmOne::get name)
echo "name: $name"
arr=($(other_func))
echo "arr length: ${#arr[@]}"
echo "arr: ${arr[@]}"
echo
hmOne::delete "key"
echo
echo
echo "hashmap two ..."
create_hashmap hmTwo name=Ted age=old
echo
hmTwo::get age
hmTwo::get name
echo
age=$(hmTwo::get age)
echo "age: $age"
name=$(hmTwo::get name)
echo "name: $name"

echo
echo "function list:"
compgen -A function
echo
echo "hmOne variable list:"
compgen -A variable hmOne_
echo
echo "hmTwo variable list:"
compgen -A variable hmTwo_
