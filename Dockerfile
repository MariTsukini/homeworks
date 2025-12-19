FROM python:3.10-slim
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY generate_data.py .
COPY perform_joins.py .

RUN mkdir -p input output && chmod 777 output

CMD ["python", "perform_joins.py"]