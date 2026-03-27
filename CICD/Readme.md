# CICD Overview 

CI operaets around build process and CD operates around deployment process. 

- Why CICD ? 

CI/CD ensures every code changes are tested and deployed automatically, safely, and consistently. It is used to automate building, testing, and deploying your application.

CI —> Continuous Integration, Developers push code → system automatically: Builds the app and Runs tests
Goal: Catch errors early.

CD — Continuous Delivery / Deployment
After CI passes: App is packaged (Docker image, etc.) and Deployed to server / Kubernetes
Goal: Release changes quickly and reliably.

**CI/CD is a DevOps practice that automates code integration, testing, and deployment, enabling faster and more reliable software delivery.**

## CI with GitHub Actions structure

GitHub Actions is a CI orchestrator that is provided by GitHub.
If the source code is in GitHub repo, We need to create file .github/workflows and place a yaml file (Ex: CI.yaml), which will instruct GitHub actions what to run. 

GitHub has provided with **Actions**, these actions are like plugins or the modules. 

A GitHub Actions workflow is just a YAML file with hierarchy:

Workflow -> Jobs -> Steps.
Steps run sequentially inside a job.

## Below is the CI for Product Catalog Service on GitHub Actions.
```
# CI for Product Catalog Service

name: product-catalog-ci

on: 
    pull_request:
        branches:
        - main
```
**Run this CI pipeline whenever someone creates or updates a pull request to the main branch**
- The file startes with `name: product-catalog-ci` which appears on github UI, helps to identify this pipeline. (No functional impact — just a label)
- `on:`This defines when the workflow should run.
- `pull_request:` Trigger the workflow when: A PR is created or when a PR is updated (new commits)
- `branches: - main` Only triggers if the PR is targeting or made on the main branch.

```
jobs:
    build:
        runs-on: ubuntu-latest

        steps:
        - name: checkout code
          uses: actions/checkout@v4

        - name: Setup Go 1.22
          uses: actions/setup-go@v2
          with:
            go-version: 1.22
        
        - name: Build
          run: |
            cd src/product-catalog
            go mod download
            go build -o product-catalog-service main.go

        - name: unit tests
          run: |
            cd src/product-catalog
            go test ./...
```
- A job are set of steps that run on a machine.
- `runs-on: ubuntu-latest` --> GitHub creates a fresh Ubuntu machine. New VM → run your steps → delete VM.
- `steps:` These are the tasks that run one after another.
- `name: checkout code` --> Name of the setp.
- `uses: actions/checkout@v4` --> We are using a pre-built action (module) created by GitHub. **Downloads the GitHub repository into the machine.**
- Setup Go, Installs Go (programming language) in the machine, as the app is written in Go.
- Build step, `cd src/product-catalog` --> Gets into the app folder, `go mod download` --> Download required dependencies and `go build -o product-catalog-service main.go`--> Compile the app into a binary file
-  `cd src/product-catalog` --> Run tests, Gets into project folder and `go tests ./...` --> runs all test files.

```
    code-quality:
        runs-on: ubuntu-latest

        steps:
        - name: checkout code
          uses: actions/checkout@v4
        
        - name: Setup Go 1.22
          uses: actions/setup-go@v2
          with:
           go-version: 1.22
        
        - name: Run golangci-lint
          uses: golangci/golangci-lint-action@v6
          with:
            version: v1.55.2
            run: golangci-lint run
            working-directory: src/product-catalog
```
- This defines a separate job called `code-quality`
- Runs independently from build. **Uses a fresh Ubuntu machine**. Check code quality (not build, not test logic — but **code standards**)
- Cause its running in new ubuntu machine, need to install go and set it up again, which `Setup Go 1.22`.
- `golangci/golangci-lint-action@v6` --> Uses a prebuilt action for linting Go code.
- Linting checks code quality, not functionality. It looks for Bad coding practices, Unused variables and Possible bugs.
- `run: golangci-lint run` --> Command to execute linting.
- `src/product-catalog` --> Run linting only in the project folder.

- **Code-quality job ensures your code follows best practices before moving forward**

```
    docker:
        runs-on: ubuntu-latest

        needs: build

        steps:
        - name: checkout code
          uses: actions/checkout@v4

        - name: Install Docker
          uses: docker/setup-buildx-action@v1
        
        - name: Login to Docker
          uses: docker/login-action@v3
          with:
            username: ${{ secrets.DOCKER_USERNAME }}
            password: ${{ secrets.DOCKER_TOKEN }}

        - name: Docker Push
          uses: docker/build-push-action@v6
          with:
            context: src/product-catalog
            file: src/product-catalog/Dockerfile
            push: true
            tags: ${{ secrets.DOCKER_USERNAME }}/product-catalog:${{github.run_id}}

```
- Builds the Docker image and pushes it to Docker Hub.
- New job named `docker`. Runs on a fresh Ubuntu machine.
- `needs: build` --> Means, Docker job runs only if `build` job succeeds. If build fails this job will NOT run.
- `docker/setup-buildx-action@v1` --> Sets up Docker Buildx, an Advanced Docker builder which allows Faster builds, Multi-platform builds (amd64, arm) and Better caching.
- `with:
  username:
  password:` --> Authenticates your pipeline with Docker Hub, because to Push image it requires authentication.
- `docker/build-push-action@v6` --> Build & Push Docker image.
- `src/product-catalog` --> Folder used for build, contains source code and Dockerfile.
- `push: true` --> Push image to Docker Hub after build.
- `tags:` --> Image naming.
- **Docker job converts your application into a versioned container image and stores it in Docker Hub**.

```    
    updatek8s:
        runs-on: ubuntu-latest

        needs: docker

        steps:
        - name: checkout code
          uses: actions/checkout@v4
          with:
            token: ${{ secrets.GITHUB_TOKEN }}

        - name: Update tag in kubernetes deployment manifest
          run: | 
               sed -i "s|image: .*|image: ${{ secrets.DOCKER_USERNAME }}/product-catalog:${{github.run_id}}|" kubernetes/productcatalog/deploy.yaml
        
        - name: Commit and push changes
          run: |
            git config --global user.email "abhishek@gmail.com"
            git config --global user.name "Abhishek Veeramalla"
            git add kubernetes/productcatalog/deploy.yaml
            git commit -m "[CI]: Update product catalog image tag"
            git push origin HEAD:main -f
            
```
Exp---

**The CI for product catalog service CI.yaml is been added to /CICD**

