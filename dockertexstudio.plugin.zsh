#!/bin/zsh

0=${(%):-%N}
DOCKERTEX_HOME="${0:A:h}"

dockertexlatex()
{
    "${DOCKERTEX_HOME}"/bin/dockertexlatex.sh ${@}
}    

