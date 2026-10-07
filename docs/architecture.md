See the Mermaid diagram in README.md. Job 1 = test, build, push. Job 2 = Terraform + deploy. Job 1 calls Job 2 with the image tag so the deployed image is the one just built.
