#!/bin/bash
#############################################################
## Title: docketex posthook
## Abstact: installs texstudio menu entry in user home
## Author:  Fabian Raab <fabian@raab.link>
## Dependencies: docker
## Creation Date: 2017-11-02
## Last Edit: 2017-11-02
##############################################################


SCRIPTNAME=$(basename $0)
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10

home_icon_prefix="$HOME/.local/share/icons"
home_applications_prefix="$HOME/.local/share/applications"
home_bin_prefix="$HOME/.local/bin"

is_system=false
no_texstudio=false
system_icon_prefix="/usr/local/share/icons"
system_applications_prefix="/usr/local/share/applications"
system_bin_prefix="/usr/local/bin"

##### Colors #####
RCol='\e[0m'    # Text Reset

# Regular           Bold                Underline           High Intensity      BoldHigh Intens     Background          High Intensity Backgrounds
Bla='\e[0;30m';     BBla='\e[1;30m';    UBla='\e[4;30m';    IBla='\e[0;90m';    BIBla='\e[1;90m';   On_Bla='\e[40m';    On_IBla='\e[0;100m';
Red='\e[0;31m';     BRed='\e[1;31m';    URed='\e[4;31m';    IRed='\e[0;91m';    BIRed='\e[1;91m';   On_Red='\e[41m';    On_IRed='\e[0;101m';
Gre='\e[0;32m';     BGre='\e[1;32m';    UGre='\e[4;32m';    IGre='\e[0;92m';    BIGre='\e[1;92m';   On_Gre='\e[42m';    On_IGre='\e[0;102m';
Yel='\e[0;33m';     BYel='\e[1;33m';    UYel='\e[4;33m';    IYel='\e[0;93m';    BIYel='\e[1;93m';   On_Yel='\e[43m';    On_IYel='\e[0;103m';
Blu='\e[0;34m';     BBlu='\e[1;34m';    UBlu='\e[4;34m';    IBlu='\e[0;94m';    BIBlu='\e[1;94m';   On_Blu='\e[44m';    On_IBlu='\e[0;104m';
Pur='\e[0;35m';     BPur='\e[1;35m';    UPur='\e[4;35m';    IPur='\e[0;95m';    BIPur='\e[1;95m';   On_Pur='\e[45m';    On_IPur='\e[0;105m';
Cya='\e[0;36m';     BCya='\e[1;36m';    UCya='\e[4;36m';    ICya='\e[0;96m';    BICya='\e[1;96m';   On_Cya='\e[46m';    On_ICya='\e[0;106m';
Whi='\e[0;37m';     BWhi='\e[1;37m';    UWhi='\e[4;37m';    IWhi='\e[0;97m';    BIWhi='\e[1;97m';   On_Whi='\e[47m';    On_IWhi='\e[0;107m';


###### Functions ######

function usage #(exit_code: Optional) 
{
echo -e "Usage: ${Yel}$SCRIPTNAME${RCol} [${Blu}--system${RCol}] [[${Blu}--no-texstudio${RCol}]  ${Blu}--icon-prefix ${UGre}icons dir${RCol}] [${Blu}--app-prefix ${UGre}applications dir${RCol}] [${Blu}--bin-prefix ${UGre}bin dir${RCol}]
       ${Yel}$SCRIPTNAME${RCol} [${Blu}-h|--help${RCol}]

    Installs sctipts and texstudio menu entry in user home or in the specifed directories.

${BRed}OPTIONS:${RCol}
    ${Blu}-h, --help${RCol}
        Print this help and exit.

    ${Blu}--system${RCol}
        Install the scripts system wide for multi-user environments.

    ${Blu}--no-texstudio${RCol}
        Does not install texstudio entries.

    ${Blu}--icon-prefix ${UGre}icons dir${RCol}
        The script copies the texstudio icon to ${UGre}icons dir${RCol}.
        Defaults to $home_icon_prefix/ and $system_icon_prefix/ for ${Blu}--system${RCol}.

    ${Blu}--app-prefix ${UGre}applications dir${RCol}
        The script copies the texstudio menu entry (.desktop) to 
        ${UGre}applications dir${RCol}.
        Defaults to $home_applications_prefix/ and $system_applications_prefix/ for ${Blu}--system${RCol}.
    ${Blu}--bin-prefix ${UGre}bin dir${RCol}
        The script copies the scripts to ${UGre}bin dir${RCol}.
        Defaults to $home_bin_prefix/ and $system_bin_prefix/ for ${Blu}--system${RCol}.

    
${BRed}EXIT STATUS:${RCol}
    If everything is successfull the script will exit with $EXIT_SUCCESS.
    Failure exit statuses are $EXIT_FAILURE, $EXIT_ERROR, and $EXIT_BUG.
"
    [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}


###### Parse Options ######

# first ':' prevents getopts error messages
optspec=':t:h-:'

while getopts "$optspec" OPTION ; do
    case $OPTION in
        -)
            case "${OPTARG}" in
                help)
                    usage $EXIT_SUCCESS
                    ;;
                system)
                    is_system=true
                    ;;
                no-texstudio)
                    no_texstudio=true
                    ;;
                icon-prefix)
                    arg_icon_prefix="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                app-prefix)
                    arg_applications_prefix="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                bin-prefix)
                    arg_bin_prefix="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                *)
                if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                    echo -e "${Red}Unknown option \"-$OPTARG\".${RCol}" >&2
                fi
                ;;
            esac
            ;;
        h) 
            usage $EXIT_SUCCESS
            ;;
        \?) 
            echo -e "${Red}Unknown option \"-$OPTARG\".${RCol}" >&2
            usage $EXIT_ERROR
            ;;
        :)  echo -e "${Red}Option \"-$OPTARG\" needs an argument.${RCol}" >&2
            usage $EXIT_ERROR
            ;;
        *)  echo -e "${Red}ERROR: This should not happen.${RCol}" >&2
            usage $EXIT_BUG
            ;;
    esac
done

# jump over consumed arguments
shift $(( OPTIND - 1 ))

####### Commands ######

if [ "$is_system" = false ] && [ "$(whoami)" = "root" ]; then
    echo -e "${Red}You are trying to install the scripts for a single user
but as user 'root'. This is normally unintended and the
script is therefore aborted. Use ${Blu}--system${Red} to install
it for multi-user and as root.${RCol}"
    exit $EXIT_FAILURE
fi

# select system or single user default paths
if [ "$is_system" = true ]; then
    applications_prefix=${arg_applications_prefix:-$system_applications_prefix}
    icon_prefix=${arg_icon_prefix:-$system_icon_prefix}
    bin_prefix=${arg_bin_prefix:-$system_bin_prefix}
else
    applications_prefix=${arg_applications_prefix:-$home_applications_prefix}
    icon_prefix=${arg_icon_prefix:-$home_icon_prefix}
    bin_prefix=${arg_bin_prefix:-$home_bin_prefix}
fi

# copy sctipts
cp "$SCRIPTPATH/bin/dockertex.sh" \
    "$bin_prefix/dockertex" || exit $EXIT_ERROR

if [ "$no_texstudio" = false ]; then
    cp "$SCRIPTPATH/bin/dockertexstudio.sh" \
        "$bin_prefix/dockertexstudio" || exit $EXIT_ERROR

    # copy texstudio menu entry
    cp --recursive --no-target-directory \
        "$SCRIPTPATH/misc/icons/" \
        "$icon_prefix" || exit $EXIT_ERROR
    
    cp "$SCRIPTPATH/misc/dockertexstudio.desktop" \
        "$applications_prefix/dockertexstudio.desktop" || exit $EXIT_ERROR
    
    echo "Exec=$bin_prefix/dockertexstudio %F" >> "$applications_prefix/dockertexstudio.desktop" || exit $EXIT_ERROR
    echo "Icon=texstudio" >> "$applications_prefix/dockertexstudio.desktop" || exit $EXIT_ERROR
fi

# set correct permissions
if [ "$is_system" = true ]; then
    chmod +rx "$bin_prefix/dockertex" || exit $EXIT_ERROR
    if [ "$no_texstudio" = false ]; then
        chmod +rx "$bin_prefix/dockertexstudio" || exit $EXIT_ERROR
        chmod 644 "$applications_prefix/dockertexstudio.desktop" || exit $EXIT_ERROR 
        chmod --recursive u=rw,g=r,o=r,a+X $icon_prefix || exit $EXIT_ERROR 
    fi
else
    chmod u+rx "$bin_prefix/dockertex" || exit $EXIT_ERROR
    if [ "$no_texstudio" = false ]; then
        chmod u+rx "$bin_prefix/dockertexstudio" || exit $EXIT_ERROR
    fi
fi

exit $EXIT_SUCCESS
