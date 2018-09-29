FROM python:3.6-alpine AS build

RUN mkdir /code
WORKDIR /code
ADD . /code/
RUN cd /code
RUN apk add --no-cache gcc musl-dev
RUN apk add python3-dev

RUN pip3 install -r requirements.txt

EXPOSE 9090
CMD ["python", "/code/app.py"]

