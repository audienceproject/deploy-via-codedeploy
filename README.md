# Deploy via CodeDeploy

A Wercker step for creating and deploying an artefact with the help of Amazon CodeDeploy.
The prerequisite [AWS Command Line Interface](https://aws.amazon.com/cli/) will be installed and configured by the step. 

The step takes the following arguments:
# For configuring AWS CLI
* **access-key**: The AWS access key for Werker to use
* **secret-access-key**: The AWS secret access key for Werker to use
* **region**: The AWS region to use

# Setup application
* **application-name**: The name of the application in CodeDeploy
# Setup deployment config
* **deployment-config-name**: The name of the deployment configuration in CodeDeploy
* **minimum-healthy-hosts**: (optional) The minimum number of healthy hosts during deployment

# Setup deployment group
* **deployment-group**: Name of the deployment group in CodeDeploy
* **service-role-arn**: The service role ARN to use
* **auto-scaling-groups**: (optional)  
* **ec2-tag-filters**: (optional)

# push application
* **s3-bucket**: The S3 bucket to use when pushing app to S3
* **s3-key**: The the key that identifies the location on S3
* **app-source-location**: the location of the app to bundle and push to S3
* **revision-description**: (optional) 

The location on S3 vil be `s3://$s3-bucket/$s3-key/<git revision>$application-name.$bundle-type`.

# Register application version    
* **bundle-type**: The bundle type, defaults to zip
# Created deployment
* **deployment-description**: (optional)



For more info, see [Amazon Command Line Interface](http://docs.aws.amazon.com/cli/latest/reference/deploy)

## Example

```
steps:
    - audienceproject/deploy-via-codedeploy:
        access-key: <AWS ACCESS KEY>
        secret-access-key: <AWS ACCESS KEY>
        application-name: DemoApp
        deployment-config-name: CodeDeployDefault.AllAtOnce
        deployment-group: DemoAppGroup
        service-role-arn: arn:aws:iam::80398EXAMPLE:role/CodeDeployDemoRole
        deployment-config-name: DemoAppConfig                         
        ec2-tag-filters: Key=Name,Value=DemoServer,Type=KEY_AND_VALUE 
        s3-bucket: my-apps-bucket
        s3-key: demoapp
        app-source-location: /tmp/myapp/
        bundle-type: zip
```
