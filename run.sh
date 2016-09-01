#!/bin/sh

BOLD=$(tty -s && tput bold)
UNDERLINE=$(tty -s && tput sgr 0 1)
RESET=$(tty -s && tput sgr0)

RED=$(tty -s && tput setaf 1)
GREEN="$(tty -s && tput setaf 2)"
YELLOW="$(tty -s && tput setaf 3)"
BLUE="$(tty -s && tput setaf 4)"

function bold() { printf "${BOLD}%s${RESET}\n" "$@" ; }
function undeline() { printf "${UNDERLINE}%s${RESET}\n" "$@" ; }
function done() { printf "${GREEN}%s${RESET}\n" "$@" ; }
function info() { printf "${BLUE}%s${RESET}\n" "$@" ; }
function warn() { printf "${YELLOW}%s${RESET}\n" "$@" ; }
function error() { printf "${RED}%s${RESET}\n" "$@" ; exit 1 ; }

function usage() {
  if [ -n "$2" ]; then
    echo
    warn "Error$

    $2$"
  else
    echo
    undeline "Usage:"
  fi;
  echo
  bold "The following variables need to be set"
  echo "
    WERCKER_DEPLOY_VIA_CODEDEPLOY_ACCESS_KEY
    WERCKER_DEPLOY_VIA_CODEDEPLOY_SECRET_ACCESS_KEY
    WERCKER_DEPLOY_VIA_CODEDEPLOY_REGION
    WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME
    WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME
    WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_GROUP
    WERCKER_DEPLOY_VIA_CODEDEPLOY_SERVICE_ROLE_ARN
    WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_BUCKET
    WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_KEY
    WERCKER_DEPLOY_VIA_CODEDEPLOY_APP_SOURCE_LOCATION
    WERCKER_DEPLOY_VIA_CODEDEPLOY_BUNDLE_TYPE
    "
  bold "The following variables are optional "
  echo "
    WERCKER_DEPLOY_VIA_CODEDEPLOY_REVISION_DESCRIPTION
    WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_DESCRIPTION
    WERCKER_DEPLOY_VIA_CODEDEPLOY_AUTO_SCALING_GROUPS
    WERCKER_DEPLOY_VIA_CODEDEPLOY_EC2_TAG_FILTERS
    WERCKER_DEPLOY_VIA_CODEDEPLOY_MINIMUM_HEALTHY_HOSTS
    WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME
    "
  exit $1
}

while [ "$1" != "" ]; do
  case $1 in
    -h | --help)
      usage 0
  esac
  shift
done

[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_ACCESS_KEY} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_ACCESS_KEY"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_SECRET_ACCESS_KEY} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_SECRET_ACCESS_KEY"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_REGION} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_REGION"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_GROUP} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_GROUP"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_SERVICE_ROLE_ARN} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_SERVICE_ROLE_ARN"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_BUCKET} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_BUCKET"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_KEY} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_KEY"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APP_SOURCE_LOCATION} ]] || usage 1 "Please define APP_SOURCE_LOCATION"
[[ ${WERCKER_DEPLOY_VIA_CODEDEPLOY_BUNDLE_TYPE} ]] || usage 1 "Please define WERCKER_DEPLOY_VIA_CODEDEPLOY_BUNDLE_TYPE"

if [ -z ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME} ]; then
  WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME="CodeDeployDefault.OneAtATime"
fi

#Install awscli
if which aws > /dev/null; then
  info "aws cli already installed"
else
  warn "installing awscli"
  sudo pip install awscli || error "Could not intsall awscli. exiting."
fi
# ---------------------------------------------------------------------------
info "Configuring awscli"
aws configure set aws_access_key_id ${WERCKER_DEPLOY_VIA_CODEDEPLOY_ACCESS_KEY} || error "Could not configure aws cli"
aws configure set aws_secret_access_key ${WERCKER_DEPLOY_VIA_CODEDEPLOY_SECRET_ACCESS_KEY} || error "Could not configure aws cli"
aws configure set region ${WERCKER_DEPLOY_VIA_CODEDEPLOY_REGION} || error "Could not configure aws cli"

# ---------------------------------------------------------------------------
if aws deploy get-application --application-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME} >/dev/null 2>&1; then 
  info "Good. Application already created "
else 
  warn "Warning. Creating application"
  aws deploy create-application --application-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME} || error "create-application failed";
fi

# ---------------------------------------------------------------------------
if aws deploy get-deployment-config --deployment-config-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME} >/dev/null 2>&1; then
  info "Good. Configuration already exists"
else
  warn "Warning. Creating configuration"
  CREATE_CMD="aws deploy create-deployment-config --deployment-config-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME}"
  if [ -n "${WERCKER_DEPLOY_VIA_CODEDEPLOY_MINIMUM_HEALTHY_HOSTS}" ]; then CREATE_CMD="${CREATE_CMD} --minimum-healthy-hosts ${WERCKER_DEPLOY_VIA_CODEDEPLOY_MINIMUM_HEALTHY_HOSTS}"; fi
  ${CREATE_CMD} || error "create-deployment-gonfig failed"
fi

# ---------------------------------------------------------------------------
if aws deploy get-deployment-group --application-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME} --deployment-group-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_GROUP} > /dev/null 2>&1; then
  info "Good. Deployment group already exists"
else
  warn "Warning. Creating deployment group"
  DEPLOY_CMD="aws deploy create-deployment-group --application-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME} --deployment-group-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_GROUP} --service-role-arn ${WERCKER_DEPLOY_VIA_CODEDEPLOY_SERVICE_ROLE_ARN}"
  if [ -n "${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME}" ]; then DEPLOY_CMD="${DEPLOY_CMD} --deployment-config-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME}"; fi
  if [ -n "${WERCKER_DEPLOY_VIA_CODEDEPLOY_AUTO_SCALING_GROUPS}" ]; then DEPLOY_CMD="$DEPLOY_CMD --auto-scaling-groups ${WERCKER_DEPLOY_VIA_CODEDEPLOY_AUTO_SCALING_GROUPS}"; fi
  if [ -n "${WERCKER_DEPLOY_VIA_CODEDEPLOY_EC2_TAG_FILTERS}" ]; then DEPLOY_CMD="$DEPLOY_CMD --ec2-tag-filters ${WERCKER_DEPLOY_VIA_CODEDEPLOY_EC2_TAG_FILTERS}"; fi
  ${DEPLOY_CMD} || error "create-deployment-group failed"
fi

# ---------------------------------------------------------------------------
# Zips and uploads file to S3
S3_KEY="${WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_KEY}/$(git descibe)/${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME}.${WERCKER_DEPLOY_VIA_CODEDEPLOY_BUNDLE_TYPE}"
PUSH_CMD="aws deploy push --application-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME} --s3-location s3://${WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_BUCKET}/${S3_KEY} --source ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APP_SOURCE_LOCATION}"
if [ -n ${WERCKER_DEPLOY_VIA_CODEDEPLOY_REVISION_DESCRIPTION} ]; then PUSH_CMD="${PUSH_CMD} --description \"${WERCKER_DEPLOY_VIA_CODEDEPLOY_REVISION_DESCRIPTION}\""; fi
${PUSH_CMD} || error "Push failed."

# ---------------------------------------------------------------------------
S3_LOCATION="bucket=${WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_BUCKET},bundleType=${WERCKER_DEPLOY_VIA_CODEDEPLOY_BUNDLE_TYPE},key=${S3_KEY}"
aws deploy register-application-revision --application-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME} --s3-location ${S3_LOCATION} --description "${WERCKER_DEPLOY_VIA_CODEDEPLOY_REVISION_DESCRIPTION}" || error "register-application-revision failed"

# ---------------------------------------------------------------------------
DEPLOYMENT_ID=$(aws deploy create-deployment --application-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME} \
              --deployment-config-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_CONFIG_NAME} \
              --deployment-group-name ${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_GROUP} \
              --s3-location ${S3_LOCATION} \
              --description "${WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_DESCRIPTION}" \
              --output text --query deploymentId) \
              || error "Warning. Deployment not started"

FLAG="true"
while [ "$FLAG" == "true" ]
do
  RESPONSE=$(aws deploy get-deployment --output text --query deploymentInfo.status --deployment-id ${DEPLOYMENT_ID} )
  info "Deployment status: ${RESPONSE}"
  case "$RESPONSE" in
    "Created")
        ;;
    "Queued")
        ;;
    "InProgress")
        ;;
    "Succeeded")
        aws deploy get-deployment --output table --deployment-id ${DEPLOYMENT_ID}
        FLAG="false"
        ;;
    "Failed")
        aws deploy get-deployment --output table --deployment-id ${DEPLOYMENT_ID}
        exit 1
        ;;
    "Stopped")
        aws deploy get-deployment --output table --deployment-id ${DEPLOYMENT_ID}
        exit 2
        ;;
    *)
        error "Unknown response: $RESPONSE"
  esac
  sleep 5
done