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

- Get into the directory `ultimate-devops—project—demo/src/product-catalog` where the sorce code of product catalog is available and create the docker file, run `vim Dokerfile`.
- 

___
## Docker Compose

A platform used to run multiple docker files at once. 
