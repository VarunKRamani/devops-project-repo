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

A GitHub Actions workflow is just a YAML file with hierarchy:

Workflow -> Jobs -> Steps.
Steps run sequentially inside a job.


