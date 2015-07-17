LIB_NAME := buildroot-runner
BUILD_DIR := images
CURRENT_DIR = $(shell pwd)

all: buildroot

buildroot:
	sudo cp ./.setup/Dockerfile-build ./Dockerfile
	sudo docker build -t $(LIB_NAME) --rm=true .
	sudo docker run -v $(CURRENT_DIR)/build:/opt/buildroot/output/build -v $(CURRENT_DIR)/ccache:/root/.buildroot-ccache -v $(CURRENT_DIR)/scripts:/opt/buildroot/scripts -it --name $(LIB_NAME)-run $(LIB_NAME) /bin/bash
	sudo rm -rf ./$(BUILD_DIR)
	sudo docker cp $(LIB_NAME)-run:/opt/buildroot/target/$(BUILD_DIR) .
	sudo docker stop $(LIB_NAME)-run
	sudo docker rm $(LIB_NAME)-run
	sudo rm ./Dockerfile

config:
	sudo cp ./.setup/Dockerfile-config ./Dockerfile
	sudo docker build -t $(LIB_NAME)-config --rm=true .
	sudo docker run -it --name $(LIB_NAME)-runconfig $(LIB_NAME)-config make nconfig
	sudo docker cp $(LIB_NAME)-runconfig:/opt/buildroot/.config .
	sudo docker stop $(LIB_NAME)-runconfig
	sudo docker rm $(LIB_NAME)-runconfig
	sudo rm ./Dockerfile

