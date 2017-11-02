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

icon_prefix="$HOME/.local/share/icons"
applications_prefix="$HOME/.local/share/applications"

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
echo -e "Usage: ${Yel}$SCRIPTNAME${RCol} [${Blu}--icon-prefix ${UGre}icons dir${RCol}] [${Blu}--app-prefix ${UGre}applications dir${RCol}] 
       ${Yel}$SCRIPTNAME${RCol} [${Blu}-h|--help${RCol}]

    Installs texstudio menu entry in user home or in the specifed directories.

${BRed}OPTIONS:${RCol}
    ${Blu}-h, --help${RCol}
        Print this help and exit.

    ${Blu}--icon-prefix ${UGre}icons dir${RCol}
        The script copies the texstudio icon to ${UGre}icons dir${RCol}.
        Defaults to $icon_prefix/.

    ${Blu}--app-prefix ${UGre}applications dir${RCol}
        The script copies the texstudio menu entry (.desktop) to 
        ${UGre}applications dir${RCol}. Defaults to $applications_prefix/.
    
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
                icon-prefix)
                    icon_prefix="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    ;;
                app-prefix)
                    applications_prefix="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
		:) 	echo -e "${Red}Option \"-$OPTARG\" needs an argument.${RCol}" >&2
			usage $EXIT_ERROR
			;;
		*) 	echo -e "${Red}ERROR: This should not happen.${RCol}" >&2
			usage $EXIT_BUG
			;;
	esac
done

# jump over consumed arguments
shift $(( OPTIND - 1 ))

####### Commands ######

cp --recursive --no-target-directory \
    "$SCRIPTPATH/misc/icons/" \
    "$icon_prefix" || exit $EXIT_ERROR

cp "$SCRIPTPATH/misc/dockertexstudio.desktop" \
    "$applications_prefix/dockertexstudio.desktop" || exit $EXIT_ERROR

echo "Exec=$SCRIPTPATH/bin/dockertexstudio.sh %F" >> "$applications_prefix/dockertexstudio.desktop" || exit $EXIT_ERROR

echo "Icon=texstudio" >> "$applications_prefix/dockertexstudio.desktop" || exit $EXIT_ERROR

exit $EXIT_SUCCESS
