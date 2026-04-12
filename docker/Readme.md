# Docker

## Overview of docker concepts and docker compose.

Docker is a containerisation platform, used to containerise the application/services. It is used to pack the application and it's dependicies, liabriies into a **single portable unit called Container.**
Docker brings Same environment everywhere. So, the problem like 'it works on my system' is deleted with the use of this concept.

Docker Lifecycle
It Consistes of 3 steps:
- Docker file creation
- Docker Image creation using `docker build`
- Docker container creation using `docker run`

Will be Writing the docker file for the 3 Microservices to understand the structure of dockerfile and understand how applications built using different languages are packaged.

## Docker file for _Product Catalog_ service  - 

Product catalog is based on Go lang.

- Get into the directory `ultimate-devops—project—demo/src/product-catalog` where the sorce code of product catalog is available and create the docker file, run `vim Dokerfile`.
- The Docker file is written on the bases of documentation provided by developer.
- We will be doing milti stage builds. Multi stage docker builds.

**Advantages of multi stage docker builds**
Significantly Smaller Image Size: Final images are much lighter because they exclude compilers, build-time dependencies, and source code.
Enhanced Security: By removing unnecessary tools (like shells, package managers, or build utilities), you minimize the attack surface of your production container.
etc

```
# ---------- Build stage ----------
FROM golang:1.22—a1pine AS builder                       #Uses an official Go image
WORKDIR /usr/src/app/                                    #Creates /usr/src/app inside the container and Moves into it
COPY go.mod go.sum ./                                    #Copies only dependency files first
RUN go mod download                                      #Downloads Go dependencies
COPY . .                                                 #Copies the entire application source code into the container.
RUN go build —o product—catalog                          #go build compiles the app and Output is a binary named product-catalog

#Now we have a single executable file.

# ---------- Runtime stage ----------
FROM alpine:latest                                       #Starts a brand new image,no complier, no go
WORKDIR /usr/src/app/                                    #Directory where the app will live and run
COPY ——from=builder /usr/src/app/product—catalog/        #Copies the compiled binary, From the builder stage into Runtime stage. This is the bridge between stages.
COPY . / products/ . / products/                         #Copies static data files required by the service.
ENV PRODUCT_CATALOG_PORT=8088                            #This sets an environment variable inside the container.
ENTRYPOINT ["./product—catalog" ]                        #This is the command that runs when the container starts. 
```
____

## Docker file for _Ad_ service -
A Java based Micro Service 

```
# ------------------------------------------- Build stage -------------------------------------------
FROM eclipse-temurin:21-jdk AS builder                    #Uses the full jdk image, cause we need java+gradle to build this application  
WORKDIR /usr/src/app                                      #Creates /usr/src/app inside the container and Moves into it

COPY gradlew* settings.gradle* build.gradle .             #Copy Gradle wrapper and build configuration files first
COPY ./gradle ./gradle                                    #Copy Gradle wrapper support files. Gradle uses these files to download and manage dependencies

RUN chmod +x ./gradlew                                    #Make the Gradle wrapper executable, linux containers needs executable permissions to run scripts.
RUN ./gradlew downloadRepos                               #Download all project dependencies ahead of time.

COPY . .                                                  #Copy the full application source code into the container, includes Java source files and resources.
COPY ./pb ./proto                                         #Copy protobuf definitions into a folder called proto. These files are used to generate gRPC code during build

RUN ./gradlew installDist -PprotoSourceDir=./proto        #Build the application and generate a distributable package
                                                          #installDist creates a runnable folder with binaries and libraries
                                                          # -PprotoSourceDir tells Gradle where the proto files exist

# ------------------------------------------ Runtime stage ------------------------------------------
FROM eclipse-temurin:21-jre                               #Use a smaller JRE image for runtime only. This reduces image size and improves security (no compiler tools inside)
WORKDIR /usr/src/app                                      #Set the working directory for  runtime container

COPY --from=builder /usr/src/app ./                       #Copy only the built application from the builder stage. Avoiding build tools and source code in runtime image

ENV AD_PORT=9099                                                   #This Sets the ENV variable inside the container.
ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]        #This defines startUp command for the container, launcher the Ad serivce binary. 
```
___
## Docker file for _Recommendation_ service -
A Python based Mico Service 

```
FROM python:3.12-slim-bookworm AS base                     #Use official Python base image
WORKDIR /usr/src/app                                       #Create /usr/src/app inside the container and move into it

COPY requirements.txt ./                                   #Copy Requriments.txt file into the container.

RUN pip install --upgrade pip                              #Upgrade pip, and install all the dependencies listed in requriments.txt file.
RUN pip install -r requirements.txt

COPY . .                                                   #Copy Entire application

ENTRYPOINT ["python", "recommendation_server.py"]          #Define the default command to run when container starts. 
```
___

## Docker init 
`docker init` is a command in Docker that helps you quickly set up a project to run inside a container.
Docker Init is used to write docker files quickly, For a service with any coded language.

____
## DockerHub 
A container Registry/Artifact platform where the containers are stored in a centralized location.

Using the command `docker push`, the container can be pussed to these centralized locations.

- Login to the Container registry, in our case dockerhub, run `docker login docker.io`
- A URL will be provided and the activation **Token** on the terminal, o/p --> 'Press ENTER to open your browser or submit your device code here: https://loqin.docker.com/activate'
- Get the URL and go to browser and enter the token. o/p --> 'Login Successful'
- `docker push docker.io/UserName/ReponameInDockerHub:tag`, the image with the same name should be built first to push it to the dockerhub.
____
## Docker Compose

A tool used to run multiple docker files at once. 

Specifically used when multiple services of a application have to be run at once, in out case there about 20 micro services that have to be run, so we use **Docker Compose**. By running a single command we can pull multiple images and run. 

## How Docker Compose work?

In docker compose we write a `.yaml` file let's say like `CompleteDocker.yaml` or `FullDocker.yaml`, which will be run. 
We can say. **Docker Compose is a tool used to run multiple containers together using a single YAML file.**

**Writing a Docker compose file i.e. `.yaml` file for docker compose.**

- We need to write 3 main/primary objects : **Services, Network and Volumes**.
- **Service**: The services object defines all the containers in an application. Each service represents a container with its own configuration like image, ports, environment variables, and volumes.
- **Network**: Networks defines how containers (services) communicate with each other, if not definerd, Docker Compose: Creates a default network and Connects all services to it. We define custom networks for isolation and better control.
- **Vloumes**: volumes are used to persist data outside the container. By default Containers are ephemeral (temporary), If container is deleted the data is gone. Volumes fix this issue, Data stays even if container is removed.


**`Docker-Compose.yaml` file is added to `/docker` directory.**
There is a parent object for networks(bridge type of network), a Section for each service is defined. Service dependency are defined where needed.

- Get into the directory, run `docker compose down` to remove any containers.
- **Run `docker compose up -d`.**
- Access the project frontend, using **localhost**. 
