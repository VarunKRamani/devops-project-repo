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

[Product catalog is based on Go lang.]

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
ENV PRODUCT_CATALOG_PORT=8088                            #Setting the environment variable or mapping a service to port 8088
ENTRYPOINT ["./product—catalog" ]                        #This is the command that runs when the container starts. 
```

___
## Docker Compose

A platform used to run multiple docker files at once. 
