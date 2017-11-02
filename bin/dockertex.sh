#!/bin/bash
#############################################################
## Title: docketex
## Abstact: Ececutes a command in a latex docker container
##          within the current working directory.
## Author:  Fabian Raab <fabian@raab.link>
## Dependencies: docker
## Creation Date: 2017-10-28
## Last Edit: 2017-10-28
##############################################################


SCRIPTNAME=$(basename $0)
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_ERROR=2
EXIT_BUG=10

LATEX_IMAGE_NAME="mylatex"
TEXSTUDIO_IMAGE_NAME="mytexstudio"

image_tag="${DOCKERTEX_DEFAULT_TAG}"

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
echo -e "Usage: ${Yel}$SCRIPTNAME${RCol} [${Blu}-t|--tag ${UGre}tagname${RCol}] ${UGre}command${RCol}
       ${Yel}$SCRIPTNAME${RCol} [${Blu}-h|--help${RCol}]

    Launches the $TEXSTUDIO_IMAGE_NAME, or if not available the $LATEX_IMAGE_NAME
    docker-container and adds the current working directory as a
    volume. Then ${UGre}command${RCol} is executed in the container
    in the current working directory. Afterwards, the container is
    removed.

${BRed}OPTIONS:${RCol}
    ${Blu}-h, --help${RCol}
        Print this help and exit.

    ${Blu}-t, --tag ${UGre}tagname${RCol}
        The latex docker container with tag ${UGre}tagname${RCol} will be used.
        If this option is omitted, ${UGre}tagname${RCol} defaults to the 
        environment variable ${Yel}DOCKERTEX_DEFAULT_TAG${RCol}.

${BRed}EXAMPLES:${RCol}
    ${Yel}$SCRIPTNAME${RCol} ${Blu}--tag ${Gre}texlive2016${RCol} ${Gre}make all${RCol}
    ${Yel}$SCRIPTNAME${RCol} ${Gre}pdftex document.tex${RCol}
    
${BRed}EXIT STATUS:${RCol}
    If everything is successfull the script will exit with $EXIT_SUCCESS.
    Failure exit statuses of the script itself are $EXIT_FAILURE, $EXIT_ERROR, and $EXIT_BUG.
    When ${Blu}docker run${RCol} is executed it returns whatever this command
    returns. See docker run manpage for further information.
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
                tag)
                    image_tag="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
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
        t)
            image_tag=$OPTARG
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

# Testing if there are enough arguments
if (( $# < 1 )) ; then
 echo -e "${Red}At least one argument is required.${RCol}" >&2
 usage $EXIT_ERROR
fi


####### Commands ######

if [ "$image_tag" == "" ]; then
 echo -e "${Red}${Blu}-t, --tag${Red} was omitted and ${Yel}DOCKERTEX_DEFAULT_TAG${Red} is empty. Please specify a ${UGre}tagname${Red}.${RCol}" >&2
 exit $EXIT_ERROR
fi


if docker inspect --type=image $TEXSTUDIO_IMAGE_NAME:$image_tag > /dev/null 2>&1; then
    image_name=$TEXSTUDIO_IMAGE_NAME
else
    if docker inspect --type=image $LATEX_IMAGE_NAME:$image_tag > /dev/null 2>&1; then
        image_name=$LATEX_IMAGE_NAME
    else
        echo -e "${Red}Docker image ${Gre}$LATEX_IMAGE_NAME:$image_tag${Red} is locally not available. Please 
use the following command to obtain it:
        ${Blu}docker pull ${Gre}$LATEX_IMAGE_NAME:$image_tag${RCol}" >&2
        exit $EXIT_FAILURE
    fi
fi


docker run --rm --interactive \
    --user="$(id --user):$(id --group)" \
    --name="latex" --net=none \
    --volume="$PWD":/home/workdir \
    --workdir="/home/workdir" \
    -e HOME="/home" \
    $image_name:$image_tag "$@" || exit $?


exit $EXIT_SUCCESS
