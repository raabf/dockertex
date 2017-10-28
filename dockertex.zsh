#!/bin/zsh

0=${(%):-%N}
DOCKERTEX_HOME="${0:A:h}"

dockertex()
{
    "${DOCKERTEX_HOME}"/dockertex.sh ${@}
}    

dockertexlatex()
{
    "${DOCKERTEX_HOME}"/dockertexlatex.sh ${@}
}    
