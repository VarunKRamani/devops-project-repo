CICD Overview 

CI operaets around build process and CD operates around deployment process. 

- Why CICD ? 

CI/CD ensures every code changes are tested and deployed automatically, safely, and consistently. It is used to automate building, testing, and deploying your application.

CI —> Continuous Integration, Developers push code → system automatically: Builds the app and Runs tests
Goal: Catch errors early.

CD — Continuous Delivery / Deployment
After CI passes: App is packaged (Docker image, etc.) and Deployed to server / Kubernetes
Goal: Release changes quickly and reliably.

**CI/CD is a DevOps practice that automates code integration, testing, and deployment, enabling faster and more reliable software delivery.**

## GitHub Actions structure

GitHub Actions is a CI orchestrator that is provided by GitHub.
If the source code is in GitHub repo, We need to create file .github/workflows and place a yaml file (Ex: CI.yaml), which will instruct GitHub actions what to run. 

GitHub has provided with **Actions**, these actions are like plugins or the modules. 

A GitHub Actions workflow is just a YAML file with hierarchy:

Workflow -> Jobs -> Steps.
Steps run sequentially inside a job.

Example for Structure of .yaml file for GitHub Actions :
```
name: CI Pipeline

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      # 1. Checkout code
      - name: Checkout code
        uses: actions/checkout@v3

      # 2. Set up Node.js (example runtime)
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      # 3. Install dependencies
      - name: Install dependencies
        run: npm install

      # 4. Run tests
      - name: Run tests
        run: npm test

      # 5. Build application
      - name: Build app
        run: npm run build
```
