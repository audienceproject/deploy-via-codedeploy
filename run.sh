#!/bin/bash
R='^s3:\/\/([^\/\S]+?)\/(.+)$'
if [[ $WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_ARTEFACT =~ $R ]]
then
    BUCKET=${BASH_REMATCH[1]}
    KEY=${BASH_REMATCH[2]}
else
    echo "$WERCKER_DEPLOY_VIA_CODEDEPLOY_S3_ARTEFACT is not a valid S3 path"
    exit 4;
fi
ID=$(aws deploy create-deployment --application-name $WERCKER_DEPLOY_VIA_CODEDEPLOY_APPLICATION_NAME --s3-location bucket=$BUCKET,key=$KEY,bundleType=$WERCKER_DEPLOY_VIA_CODEDEPLOY_BUNDLE_TYPE --deployment-group-name $WERCKER_DEPLOY_VIA_CODEDEPLOY_DEPLOYMENT_GROUP_NAME | jq --raw-output ."deploymentId")
FLAG="true"

while [ "$FLAG" == "true" ]
do
  RESPONSE=$(aws deploy get-deployment --output json --deployment-id $ID | jq --raw-output ."deploymentInfo.status")
  echo $RESPONSE
  case "$RESPONSE" in
    "Created")
        ;;
    "Queued")
        ;;
    "InProgress")
        ;;
    "Succeeded")
        aws deploy get-deployment --output table --deployment-id $ID
        FLAG="false"
        ;;
    "Failed")
        aws deploy get-deployment --output table --deployment-id $ID
        exit 1
        ;;
    "Stopped")
        aws deploy get-deployment --output table --deployment-id $ID
        exit 2
        ;;
    *)
        echo "Unknown response: $RESPONSE"
        exit 3;
  esac
  sleep 5
done
