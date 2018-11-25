#!/bin/bash

_LOGFILE=${LOGFILE:-/dev/null}

# Get task command
TASK_COMMAND="task ${@}"

# Debug option
_DEBUG="${DEBUG:-false}"

# Get data dir
DATA_RC=$(task _show | grep data.location)
DATA=(${DATA_RC//=/ })
DATA_DIR=${DATA[1]}


# Need to expand home dir ~
eval DATA_DIR=$DATA_DIR

log () {
  $_DEBUG && echo $* >&1
  echo $* > $_LOGFILE
}

error () {
  echo $* >&2
  exit 1
}

get_task_option () {
    option_=$(task _show | grep $2)
    if [ -z $option ]; then
        option=$3
        log "Couldn't find $2 option set in task configuration file using default: $3. Run 'task config $2 <value>' to change this."
    else
        option_=(${option_//=/ })
        option=${option_[1]}
        log "Using option $2 from task configuration file: ${option}. Run 'task config $2 <value>' to change this."
    fi
    log "Setting $1 to ${option}"
    eval "$1='${option}'"
}

log "Logging to ${_LOGFILE}."


# Exit if we don't have a tasks data directory
if [ ! -e "$DATA_DIR" ]; then
    error "Could not load data directory $DATA_DIR."
fi

# Check if git repo exists
if ! [ -d "$DATA_DIR/.git" ]; then
    echo "Initializing git repo"
    pushd $DATA_DIR
    git init
    git add *
    git commit -m "Initial Commit"
    popd
fi

# Push by default
get_task_option PUSH git.push 0
get_task_option PULL git.pull 1

# Check if --no-push is passed as an argument.
for i in $@
do
    if [ "$i" == "--no-push" ]; then
        # Set the PUSH flag, and remove this from the arguments list.
        echo "--no-push found in args, not pushing to git."
        PUSH=0
        shift
    fi
done

# Check if we are passing something that doesn't do any modifications
for i in $1
do
    case $i in
        add|append|completed|delete|done|due|duplicate|edit|end|modify|prepend|rm|start|stop)
            PUSH=1
            ;;
        push)
            ;;
        pull)

            PULL=1
            ;;
        *)
            PUSH=0
            ;;
    esac
done

# Check if we are passing a command for the second arg (filter for the first)
if [ $PUSH -eq 0 ]
then
    for i in $2
    do
        case $i in
            add|append|completed|delete|done|due|duplicate|edit|end|modify|prepend|rm|start|stop)
                PUSH=1

                ;;
            *)
                ;;
        esac
    done
fi



pushd $DATA_DIR > $_LOGFILE
# Check if we have a place to push to
GIT_REMOTE=$(git remote -v | grep push | grep origin | awk '{print $2}')
if [ -z $GIT_REMOTE ]; then
    # No place to push to
    PUSH=0
fi


if [ "$PULL" == 1 ]; then
    echo "Fetching & Applying updates from $GIT_REMOTE"
    git fetch > $_LOGFILE && git pull > $_LOGFILE
fi

# Call task, commit files and push if flag is set.
/usr/bin/task $@

# Add to git
git add .  > $_LOGFILE
git commit -m "$TASK_COMMAND" > $_LOGFILE

# Push
if [ "$PUSH" == 1 ]; then
    echo "Pushing updates to $GIT_REMOTE"
    git push origin master > $_LOGFILE
fi

popd > $_LOGFILE

exit 0
