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

Create the MySQL database and user permissions inside Docker:

    docker-compose up db
    docker-compose exec db mysql --password
    create database db_example;
    create user 'springuser'@'%' identified by 'ThePassword';
    grant all on db_example.* to 'springuser'@'%';


## Usage

Run backend and database together using:

    docker-compose up

View the backend at:

    http://localhost:5000/


# Testing the API

Add some data and check that it was saved using curl:

    curl localhost:5000/demo/add -d name=Terry -d email=terry@email.com
    curl localhost:5000/demo/all

View the API in your browser at:

    http://localhost:5000/demo/all

View the database in the Adminer user interface at:

    http://localhost:8080


## Directory structure

    /src                                  --> Source files
    /target                               --> Compiled application


## Contact

For more information please contact kmturley
