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

## Deployment

Ensure you have the development tools installed:

    brew cask install java
    brew install maven
    brew tap pivotal/tap
    brew install springboot
    brew install awscli

Set up an Elastic Beanstalk application environment:

    aws elasticbeanstalk create-application --application-name project-name
    aws elasticbeanstalk create-environment --application-name project-name --cname-prefix project-name --environment-name development --solution-stack-name "64bit Amazon Linux 2018.03 v2.10.7 running Java 8"

Build a compiled .jar version of the app using the maven package command:

    mvn clean package spring-boot:repackage

This will create a compiled .jar file at: 

    ./target/springelastic-0.0.1-SNAPSHOT.jar

Create an S3 bucket and upload the compiled .jar file:

    aws s3 mb s3://project-name
    aws s3 cp target/springelastic-0.0.1-SNAPSHOT.jar s3://project-name/springelastic-0.0.1-SNAPSHOT.jar

Create a new application version and update the environment with the version:

    aws elasticbeanstalk create-application-version --application-name project-name --version-label "0.0.1" --source-bundle S3Bucket="project-name-files",S3Key="springelastic-0.0.1-SNAPSHOT.jar"
    aws elasticbeanstalk update-environment --environment-name development --version-label "0.0.1"


## Directory structure

    /src                                  --> Source files
    /target                               --> Compiled application


## Contact

For more information please contact kmturley
