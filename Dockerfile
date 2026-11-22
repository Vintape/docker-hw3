FROM python:3.13-slim
WORKDIR /app
COPY app/requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt
COPY app/app.py .
CMD ["python", "app.py"]
