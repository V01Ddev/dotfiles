FROM python:3

ADD {file_name} .

COPY requirements.txt requirements.txt

RUN pip3 install -r requirments.txt

CMD ["python3", "{file_name}"]
