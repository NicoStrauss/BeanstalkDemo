# spring-boot-elastic-beanstalk

Example Java Spring Boot project using:

* Java 1.8
* Maven 3.6.x
* Spring 2.3.0
* AWS Client 2.0.x
* Docker 19.03.x


## Installation

Install dependencies using:

    docker-compose build


## Usage

Run backend and database together using:

    docker-compose up

View the backend at:

    http://localhost:5000/


## Testing the API

Add some data and check that it was saved using curl:

    curl localhost:5000/demo/add -d name=Terry -d email=terry@email.com
    curl localhost:5000/demo/all

View the API in your browser at:

    http://localhost:5000/demo/all

View the database in the Adminer user interface at:

    http://localhost:8080


# Debugging

The pom.xml is already configured for remote debugging:

    <plugin>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-maven-plugin</artifactId>
      <version>2.0.3.RELEASE</version>
      <configuration>
        <jvmArguments>
          -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005
        </jvmArguments>
      </configuration>
    </plugin>

This exposes the debugger at http://localhost:5005
With VSCode you can attach to a remote debugger using a .vscode/launch.json file:

    {
      "version": "0.2.0",
      "configurations": [
        {
          "type": "java",
          "name": "Debug (Attach) - Remote",
          "request": "attach",
          "hostName": "localhost",
          "port": 5005
        }
      ]
    }

## Creating AWS resources

Ensure you have the development tools installed:

    brew cask install java
    brew install maven
    brew tap pivotal/tap
    brew install springboot
    brew install awscli

Set up an Elastic Beanstalk application environment:

    aws elasticbeanstalk create-application --application-name project-name
    aws elasticbeanstalk create-environment --application-name project-name --cname-prefix project-name --environment-name development --solution-stack-name "64bit Amazon Linux 2018.03 v2.10.7 running Java 8"

Create an S3 bucket for storing application versions:

    aws s3 mb s3://project-name-files

Create an RDS database:

    aws rds create-db-instance \
      --db-name exampledb \
      --db-instance-identifier project-name \
      --db-instance-class db.t2.micro \
      --allocated-storage 20 \
      --engine mysql \
      --master-username exampleuser \
      --master-user-password examplepass

Update Elastic Beanstalk environment variables with database connection settings:

    aws elasticbeanstalk update-environment --environment-name development --option-settings Namespace=aws:elasticbeanstalk:application:environment,OptionName=MYSQL_HOST,Value=project-name.c36h2vjbn47h.us-west-2.rds.amazonaws.com


## Deployment

Build a compiled .jar version of the app using the maven package command:

    docker-compose up db
    mvn clean package spring-boot:repackage

This will create a compiled .jar file at:

    ./target/springelastic-0.0.1-SNAPSHOT.jar

IF you want you can test your compiled version using:

    java -jar ./target/springelastic-0.0.1-SNAPSHOT.jar

Upload the compiled .jar file to your s3 bucket:

    aws s3 cp target/springelastic-0.0.1-SNAPSHOT.jar s3://project-name-files/springelastic-0.0.1-SNAPSHOT.jar

Create a new application version and update the environment with the version:

    aws elasticbeanstalk create-application-version --application-name project-name --version-label "0.0.1" --source-bundle S3Bucket="project-name-files",S3Key="springelastic-0.0.1-SNAPSHOT.jar"
    aws elasticbeanstalk update-environment --environment-name development --version-label "0.0.1"


## Using an AWS code repository (optional)

Ensure you have the development tools installed:

    brew install awscli
    pip install git-remote-codecommit

Create a git repository:

    aws codecommit create-repository --repository-name project-name --repository-description "Project description"

Clone the repo locally:

    git clone codecommit::us-west-2://project-name\

Add your application code and push your changes to CodeCommit:

    git commit
    git push


## Automating deployments

Follow steps from the previous section titled [Creating AWS resources](#creating-aws-resources) to set up the initial environments.

Then add a buildspec.yml to your codebase, containing the build/deploy steps:

    version: 0.2
    phases:
      pre_build:
        commands:
          - mvn install -Dmaven.test.skip=true 
      post_build:
        commands:
          - mvn package -Dmaven.test.skip=true 
    artifacts:
      files:
        - target/springelastic-0.0.1-SNAPSHOT.jar
      discard-paths: yes
    cache:
      paths:
        - '/root/.m2/**/*'

If you have existing build pipelines, you can download their configuration using:

    aws codebuild batch-get-projects --names project-name-build > ./aws/build.json
    aws codepipeline get-pipeline --name project-name-pipeline > ./aws/pipeline.json

Otherwise you can modify the example configuration files to match your needs, then create a new build pipeline using:

    aws codebuild create-project --cli-input-json file://aws/build.json
    aws codepipeline create-pipeline --cli-input-json file://aws/pipeline.json

If the commands are successful, you should be able to view the running pipeline at:

    https://us-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/project-name-pipeline/view?region=us-west-2


## Shutting down AWS resources

To clean up environment instances (and save billing costs), delete your buckets and resources using the commands:

    aws s3 rm s3://project-name-files --recursive
    aws rds delete-db-instance --db-instance-identifier project-name --final-db-snapshot-identifier project-name-snapshot
    aws elasticbeanstalk terminate-environment --environment-name development
    aws elasticbeanstalk delete-application --application-name project-name

If you created automated pipelines and builds, delete them using:

    aws codebuild delete-project --name project-name-build
    aws codepipeline delete-pipeline --name project-name-pipeline


## Directory structure

    /aws                                  --> AWS pipeline/build config examples
    /src                                  --> Source files
    /target                               --> Compiled application


## Contact

For more information please contact kmturley
