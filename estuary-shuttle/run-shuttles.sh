#/bin/bash
function printhelp {
    # $1 = Exit code.
    echo ""
    echo "Run Shuttle script parameters:"
    echo "-n|--num-of-shuttles      [Mandatory]: Number of Shuttles"
    echo "-a|--estuary-api-key      [Mandatory]:  The API key of Estuary"
    echo "-h|--estuary-host         [Mandatory]:  The hostname of Estuary"
    exit $1
}

# Initial checks.
if [ "$1" = "help" -o "$1" = "-help" -o "$1" = "--help" -o "$1" = "h" -o "$1" = "-h" -o "$1" = "--h" ]; then
    printhelp 0
fi
if [ $# -lt 1 ]; then
    echo "Error: Incorrect number of parameters."
    printhelp 1
fi

SHUTTLE_COUNT=3
ESTUARY_HOSTNAME=${ESTUARY_HOSTNAME:-localhost:3004}
ESTUARY_HOSTNAME_LOCAL=${ESTUARY_HOSTNAME_LOCAL:-localhost:3004}
ESTUARY_HOSTNAME_DOCKER=${ESTUARY_HOSTNAME_DOCKER:-estuary-main:3004}
API_KEY=${API_KEY:-""} ## get from main 
ORG_NAME=alvinpai # note (al): Should I update this?
TAG_NAME=estuary-shuttle:latest
PORT=3005
SHUTTLE_COUNT=3

# Process CLI parameters.
while test $# -gt 0; do
  case "$1" in
    -n|--num-of-shuttles)
      shift
      if test $# -gt 0; then
        export SHUTTLE_COUNT=$1
        shift
      else
        printhelp 1
      fi
      ;;
    -a|--estuary-api-key)
      shift
      if test $# -gt 0; then
        export API_KEY=$1
        shift
      else
        printhelp 1
      fi
      ;;
    -h|--estuary-host)
      shift
      if test $# -gt 0; then
        export ESTUARY_HOSTNAME=$1
        shift
      else
        printhelp 1
      fi
      ;;
  esac
done



## Environment Variables.
docker pull $ORG_NAME/$TAG_NAME

for ((n=0;n<$SHUTTLE_COUNT;n++))
do
    echo $i
    genKey=$(curl -H "Authorization: Bearer $API_KEY" -X POST $ESTUARY_HOSTNAME_LOCAL/admin/shuttle/init)
    handle=$(echo $genKey | jq '.handle')
    token=$(echo $genKey | jq '.token')

    ## Automatic Shuttle creation given an estuary host name
    ESTUARY_SHUTTLE_TOKEN=${ESTUARY_SHUTTLE_TOKEN:-$token}
    ESTUARY_SHUTTLE_HANDLE=${ESTUARY_SHUTTLE_HANDLE:-$handle}
    ## Assign Ports (+++)
    echo "============================================"
    echo "PORT: $PORT"
    echo "ESTUARY_SHUTTLE_TOKEN: $token"
    echo "ESTUARY_SHUTTLE_HANDLE: $handle"
    echo "============================================"
    docker run --net=estuary-local-net --env DEVENV=true --dns=8.8.8.8 --env ESTUARY_HOSTNAME=$ESTUARY_HOSTNAME --env ESTUARY_SHUTTLE_TOKEN=$ESTUARY_SHUTTLE_TOKEN --env ESTUARY_SHUTTLE_HANDLE=$ESTUARY_SHUTTLE_HANDLE -d -p $PORT:$PORT $ORG_NAME/$TAG_NAME
    PORT=$((PORT+1))
done
