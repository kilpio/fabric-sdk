ARG DOCKER_REGISTRY
ARG FABRIC_VERSION

ARG GRADLE_IMAGE
ARG JDK_IMAGE

FROM ${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-peer:${FABRIC_VERSION:-2.3} as fabricpeer


FROM ${GRADLE_IMAGE:-'gradle:7-jdk11-alpine'} as gradle
ARG JAR_FILE=build/libs/fabric2-rest-api-0.0.1-SNAPSHOT.jar

COPY . .
RUN gradle clean build -x test
RUN cp ${JAR_FILE} /fabric2-rest-api.jar

FROM ${JDK_IMAGE:-'adoptopenjdk/openjdk11:alpine-jre'}

ENV JAR_DIR=/fabric2-rest-api
WORKDIR ${JAR_DIR}

# copy fabic executables if changed
COPY --from=fabricpeer /etc/hyperledger/fabric/core.yaml ./
COPY --from=fabricpeer /usr/local/bin/peer /usr/local/bin

COPY --from=gradle /fabric2-rest-api.jar ./

EXPOSE 8080

ENTRYPOINT ["java","-jar","./fabric2-rest-api.jar"]
