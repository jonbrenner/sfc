# sfc - Annotate and write commands from history in markdown code blocks

function _sfc_out {
    local comment="$1"
    local snippet="$2"
    local date=$(date +"%Y-%m-%d %H:%M:%S")
    local hostname=$(hostname)
    local output=""
    local comment_first_line="$(echo "$comment" | head -n 1)"
    local comment_rest="$(echo "$comment" | tail -n +2)"
    output+="**${comment_first_line}**\n"
    [[ -n "$comment_rest" ]] && output+="${comment_rest}\n"
    output+='```\n'
    output+="$snippet"$'\n'
    output+='```\n'
    output+="*${date} - ${hostname}*\n\n"
    echo "$output"
}

function _sfc_get_history {
    # for each item in the array, check if valid, and add each element to the list of commands to fetch
    # a value is valid if:
    # * it is all digits, optionally preceded by a hyphen
    # * it is a series of digits separated by a single hyphen
    local arr="$1"
    local fc_out=()
    for e in "${arr[@]}"; do
        if [[ $e =~ ^-?[0-9]+$ ]]; then
            fc_out+="$(fc -ln "$e" "$e")"
        elif [[ $e =~ ^[0-9]+-[0-9]+$ ]]; then
            fc_out+="$(fc -ln "${e%*-}" "${e#*-}")"
        else
            echo "Error - Invalid index: $e" >&2
            echo "Valid syntax: i,-i,i-j,j-i" >&2
            return 2
        fi
    done
    echo "$fc_out"
}

function sfc {

    # Change negative numbers using a token to prevent getopts from choking.
    # The negative values should be restored after getopts is used. 
    for arg; do
        shift
        arg=$(echo "$arg" | sed -E "s/-([0-9])/%neg%\1/g")    
        set -- "$@" "$arg"
    done

    local fflag=
    local cflag=
    local dflag=
    while getopts 'f:c:d' OPTION
    do
        case "$OPTION" in
            f)  fflag=1
                fval="$OPTARG"
                ;;
            c)  cflag=1
                cval="$OPTARG"
                ;;
            d)  dflag=1
                ;;
            ?)  printf "Usage: %s: [-f FILE] [-c COMMENT] [n]" "${0##*/}" >&2
                return 2
                ;;
        esac
    done
    shift $((OPTIND - 1))

    # Restore negative numbers in positional params
    for arg; do
        shift
        arg=$(echo "$arg" | sed -E "s/%neg%([0-9])/-\1/g")    
        set -- "$@" "$arg"
    done

    # Set the output destination
    local outfile=
    if [[ "$fflag" ]]; then
        outfile="$fval"
    elif [[ -n "${SFC_FILE}" ]]; then
        outfile="${SFC_FILE}"
    else
        outfile=""
    fi
    [[ "$dflag" ]] && printf "Output set to %s\n" "${outfile}" >&2

    # if n is not passed as a positional parameter, set it to be the last command in the history
    if [[ -z "$1" ]]; then
        set -- "-1"
    fi

    # Split the comma-separated string into an array and fetch the commands from history
    local arr=(${(s:,:)1})
    local fc_out="$(_sfc_get_history "$arr")"

    local comment=""
    if [[ "$cflag" ]]; then
        comment="$cval\n"
    else
        echo "Enter snippet description (Ctrl-D to end):"
        comment=""
        while read line; do
            comment+="$line"$'\n'
        done
    fi

    local output="$(_sfc_out "$comment" "$fc_out")"$'\n\n'
    if [[ "$outfile" ]]; then
        touch "$outfile"
        echo -n "$output" >>"$outfile"
    else
        echo -n "$output"
    fi

}
