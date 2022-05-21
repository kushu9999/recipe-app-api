# here we took python image from docker hub
FROM python:3.9-alpine3.13
# here we declare name of maintainer others can know who the maintainer is
LABEL maintainer="kushaldulani"

# output from python can direcly to the console which prevents any delay, so can see logs immediatly to the screen
ENV PYTHONUNBUFFERED 1 

# copy requirments to docker app in temp variable
COPY ./requirements.txt /tmp/requirements.txt
# copy dev requirments to docker app in temp variable
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# copy app folder into docker conatainer
COPY ./app /app
# setting work directory
WORKDIR /app
# setting port number 
EXPOSE 8000

# here we've created virtual env named py, then upgrade pip module,
# then install all the requirments file which we copied from the local and next line we removed temp for lightweight dockerfile
# after that we created user named django-user , here we are not using root user because,
# if our site is getting hacked, that can use functionaly that any normal user can do,
# we disabledpassword and home for making lightweight of our app 

# here we declare arg file by default is false, if we use this dockerfile using
# dockercompose yml file so it'll override arg to true.

# here we installed postgresql client package
# next line create virtual dependency packages then after install i'll remove that using below code


ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \ 
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# here we update the path of environment variable
# path is created by default in linux environment
# we don't have to write al path thats why we specified path here
ENV PATH="/py/bin:$PATH"

# this should be last line of our docker, declaring user, 
# so that it can switch root user to the django-user
USER django-user