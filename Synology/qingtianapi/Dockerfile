
FROM python:3.11.2


RUN apt-get update && \
    apt-get install -y redis-server build-essential libopencc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /app


COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# 安装 OpenCC
RUN pip install --no-cache-dir opencc-python-reimplemented


EXPOSE 6379


CMD ["sh", "-c", "redis-server --appendonly yes & python app.py"]