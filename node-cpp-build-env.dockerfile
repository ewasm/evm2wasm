# to build this, place in new directory as Dockerfile
# run `docker build -t cdetrio/nodejs-cpp-build-env .`
# then push to dockerhub `docker push cdetrio/nodejs-cpp-build-env`

# stage for nodejs
FROM node:8 AS nodebuild

RUN apt-get update
RUN apt-get install sudo

RUN node --version
RUN npm --version

# stage for cpp-ethereum
FROM ethereum/cpp-build-env

# WORKDIR is /home/builder

# python is needed for node-gyp
RUN sudo apt-get update && sudo apt-get install -y python 

# copy node binary
COPY --from=nodebuild /usr/local/bin/node /usr/local/bin/node
COPY --from=nodebuild /usr/local/lib/node_modules /usr/local/lib/node_modules

# create npm symlink
RUN sudo ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
# not sure what npx is for
# RUN ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN npm --version
