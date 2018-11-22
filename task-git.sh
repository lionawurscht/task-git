#!/bin/bash

LOGFILE=/dev/null

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

# Exit if we don't have a tasks data directory
if [ ! -e "$DATA_DIR" ]; then
    echo "Could not load data directory $DATA_DIR."
    exit 1
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
PUSH_RC=$(task _show | grep git.push)
if [ -z $PUSH_RC ]; then
    PUSH=0
    $_DEBUG && echo "Couldn't find push option set in task configuration file using default: ${PUSH}. Set git.push to 1/0 to change this."
else
    PUSH_=(${PUSH_RC//=/ })
    PUSH=${PUSH_[1]}
    $_DEBUG && echo "Using option from task configuration file - push: ${PUSH}. Change git.push to 1/0 to change this."
fi

PULL_RC=$(task _show | grep git.pull)
if [ -z $PULL_RC ]; then
    PULL=1
    $_DEBUG && echo "Couldn't find pull option set in task configuration file using default: ${PULL}. Set git.pull to 1/0 to change this."
else
    PULL_=(${PULL_RC//=/ })
    PULL=${PULL_[1]}
    $_DEBUG && echo "Using option from task configuration file - pull: ${PULL}. Change git.pull to 1/0 to change this."
fi

# Check if --no-push is passed as an argument.
for i in $@
do
    if [ "$i" == "--no-push" ]; then
        # Set the PUSH flag, and remove this from the arguments list.
        $_DEBUG && echo "--no-push found in args, not pushing to git."
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



pushd $DATA_DIR > $LOGFILE
# Check if we have a place to push to
GIT_REMOTE=$(git remote -v | grep push | grep origin | awk '{print $2}')
if [ -z $GIT_REMOTE ]; then
    # No place to push to
    PUSH=0
fi


if [ "$PULL" == 1 ]; then
    echo "Fetching & Applying updates from $GIT_REMOTE"
    git fetch > $LOGFILE && git pull > $LOGFILE
fi

# Call task, commit files and push if flag is set.
/usr/bin/task $@

# Add to git
git add .  > $LOGFILE
git commit -m "$TASK_COMMAND" > $LOGFILE

# Push
if [ "$PUSH" == 1 ]; then
    echo "Pushing updates to $GIT_REMOTE"
    git push origin master > $LOGFILE
fi

popd > $LOGFILE

exit 0
