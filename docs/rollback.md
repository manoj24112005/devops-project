# Rollback
1. Deploy v1: run Job 2 with `IMAGE_TAG=v1-xxxx`. Check `/health` shows that version.
2. Deploy v2 (new build). If `/health` fails or is wrong, the deploy script exits with an error.
3. Rollback: run Job 2 again with `IMAGE_TAG=v1-xxxx`. The script pulls the old image, removes the `app` container, starts the old one.
4. Verify: `curl http://<ec2-ip>:5000/health` shows the v1 version.

To simulate a bad release: add `return "x", 500` to `/health`, push, let Job 1 build it, then roll back.
Status: NOT yet tested against real AWS. You must run these steps once and take screenshots.
