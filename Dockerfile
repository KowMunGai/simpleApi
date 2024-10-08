FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install flask robotframework robotframework-requests
RUN pip install robotframework
RUN pip install flask
CMD ["python", "app.py"]