#!/bin/bash
set -e
WINDSURF_PATH="~/.config/Windsurf"
LOGS_PATH=$WINDSURF_PATH/logs
RESOURCES_PATH=/home/ubuntu

WORKSPACE_PATH=/home/ubuntu/workspace
WORKSPACE_WINDSURF_PATH=$WORKSPACE_PATH/.windsurf
WORKSPACE_WORKFLOWS_PATH=$WORKSPACE_WINDSURF_PATH/workflows
INSTRUCTIONS_FILE=$WORKSPACE_PATH/windsurf-instructions.txt
OUTPUT_FILE=$WORKSPACE_PATH/windsurf-output.txt

FINALIZATION_MARKER="WORK-COMPLETED"

SCREENSHOTS_PATH=/home/ubuntu/screenshots

export DISPLAY=":1"

## Util functions
n=0
function captureStep() {
    n=$((n+1))
    mkdir -p $SCREENSHOTS_PATH
    xwd -display :1 -root -silent | convert xwd:- png:/$SCREENSHOTS_PATH/screenshot-$n.png
}

function log() {
    local message="$1"
    echo "ENTRYPOINT $(date +'%Y-%m-%d %H:%M:%S') - $message"
}

function pause() {
    pause_seconds=5
    sleep $pause_seconds
}

function guiTypeLine () {
    local line="$1"
    xdotool type "$line"
    xdotool key "Return"
}

function guiRunEditorCommand() {
    local command="$1"
    log "Running editor command: $command"
    xdotool key "ctrl+shift+p"
    sleep 2
    xdotool type "$command"
    xdotool key "Return"
}

## Steps definitions
function checkTokenIsPresent() {
    # If the environment variable WINDSURF_TOKEN is not set or empty
    if [ -z "$WINDSURF_TOKEN" ]; then
        log "WINDSURF_TOKEN needs to be passed as an environment variable."
        exit 1
    fi
}

function windsurfLogin() {
    log "Logging in to Windsurf with token"

    guiRunEditorCommand "token"
    sleep 2
    xdotool type $WINDSURF_TOKEN
    sleep 2
    xdotool key "Return"
    sleep 2
    #guiTypeLine "" # TODO: Check if this is really needed
    xdotool key "Escape" # To close potential vault confirmation dialog
}

function startWindowManager() {
    log "Starting Xvfb"
    Xvfb $DISPLAY & #-screen 0 2028x1536x24 &
    disown
    i3 2>/dev/null 1>/dev/null &
    disown
    log "Xvfb is ready!"
}

function startWindsurf() {
    cd $WORKSPACE_PATH
    # Make sure the workflow is present in the workspace
    mkdir -p $WORKSPACE_WORKFLOWS_PATH
    cp /home/ubuntu/entry-workflow.md $WORKSPACE_WORKFLOWS_PATH
    log "Starting Windsurf editor at DISPLAY=$DISPLAY"
    #windsurf --no-sandbox --user-data-dir /home/ubuntu &
    windsurf --disable-workspace-trust --disable-gpu --no-sandbox --verbose . 2>&1 > ~/windsurf-ui.log &
    disown
}

function waitUnitFinished() {
    touch $OUTPUT_FILE # Ensure the output file exists
    tail -f $OUTPUT_FILE | grep -q "$FINALIZATION_MARKER"
    log "Workflow completed successfully!"
}

function guiStartWorkflow() {
    xdotool key "ctrl+l"
    pause
    guiTypeLine "/entry-workflow"
    xdotool key "Return"
}

# TODO: This function is not currently used because it needs to be reviewed.
#       As an idea, it is a more robust alternative to pauses
#function waitUntilWindsurfIsReady() {
#    local readyMsg="LS lspClient started successfully"
#
#    logs_dir=$LOGS_PATH/$(ls -t1 $LOGS_PATH | head -n 1)
#    log "Waiting for Windsurf to be ready..."
#    
#    windsurf_log_file="$logs_dir/window1/exthost/codeium.windsurf/Windsurf.log"
#
#    tail -f $windsurf_log_file | grep -q 'LS lspClient started successfully'
#    log "Windsurf is ready!"
#}

## Steps execution

checkTokenIsPresent

startWindowManager
pause
startWindsurf
pause
captureStep
#waitUntilWindsurfIsReady
pause
windsurfLogin
captureStep
pause
guiStartWorkflow
captureStep
waitUnitFinished
captureStep