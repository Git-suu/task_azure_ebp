#!/bin/bash

apt update -y
apt install python3-pip -y

pip3 install fastapi uvicorn

cat <<EOF > /home/azureuser/app.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message":"Backend Running"}
EOF

nohup uvicorn app:app --host 0.0.0.0 --port 8000 &