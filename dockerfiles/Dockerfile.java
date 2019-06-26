FROM gradle:4.5.1-jdk8-alpine

USER root

ENV APP_HOME=/app \
    GRADLE_CONFIG=/home/gradle/.gradle

RUN apk upgrade --no-cache \
    && apk add --no-cache bash curl git sudo vim wget

RUN echo 'gradle ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p $APP_HOME \
    && chown -R gradle:gradle $APP_HOME \
    && chmod 755 $APP_HOME

WORKDIR $APP_HOME
USER gradle
