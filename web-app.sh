#!/bin/bash
set -euo pipefail

# prepare a clean build context
rm -rf tempdir
mkdir -p tempdir/templates tempdir/static tempdir/static/images

cp sample_app.py tempdir/.
cp requirements.txt tempdir/ || true
cp -r templates/. tempdir/templates/ || true
cp -r static/. tempdir/static/ || true
cp -r static/images/. tempdir/static/images/ || true

# create a small, reproducible Dockerfile
cat > tempdir/Dockerfile <<'DOCKERFILE'
FROM python:3.11-slim
WORKDIR /home/myapp
COPY requirements.txt /home/myapp/
RUN pip install --no-cache-dir -r requirements.txt || true
COPY ./static /home/myapp/static/
COPY ./templates /home/myapp/templates/
COPY sample_app.py /home/myapp/
EXPOSE 5000
CMD ["python", "sample_app.py"]
DOCKERFILE

cd tempdir

docker build -t sampleapp .

# remove any old container and run
docker rm -f samplerunning 2>/dev/null || true

docker run -d -p 5000:5000 --name samplerunning sampleapp

docker ps -a
