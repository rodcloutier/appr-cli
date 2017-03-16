#!/bin/bash

function update_cnr {
    echo "wip: install/update cnr-cli"
    if [ -e ./cnr ] ; then
        chmod +x ./cnr
    fi

}

function pull {
    #echo "pull $@"
    release=`./cnr pull --media-type helm --tarball ${@} |tail -n1`
    echo $release
}

function install {
    pull $@ --dest=/tmp
    sleep 1
    helm install $release
}

function cnr_helm {
    ./cnr $@ --media-type=helm
}


case "$1" in
    init-plugin)
        update_cnr
        ;;
    install)
        install "${@:2}"
        ;;
    pull)
        pull "${@:2}"
        ;;
    push)
        cnr_helm "$@"
        ;;
    list)
        cnr_helm "$@"
        ;;
    show)
        cnr_helm "$@"
        ;;
    delete-package)
        cnr_helm "$@"
        ;;
    inspect)
        cnr_helm "$@"
        ;;
    *)
        ./cnr $@
        ;;

esac
