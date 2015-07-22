LIB_NAME := buildroot-runner
BUILD_DIR := images
CURRENT_DIR = $(shell pwd)
EXIT_LIB = $(shell sudo docker ps -a | grep 'Exited' | grep '$(LIB_NAME)')
RUN_LIB = $(shell sudo docker ps -a | grep grep '$(LIB_NAME)')

all: buildroot

setup:
ifneq ($(EXIT_LIB),)
	sudo docker rm '$(LIB_NAME)-run'
endif
ifneq ($(RUN_LIB),)
	sudo docker rm -f '$(LIB_NAME)-run'
endif


buildroot: setup
	sudo cp ./.setup/Dockerfile-build ./Dockerfile
	sudo docker build -t $(LIB_NAME) --rm=true .
	sudo docker run -v $(CURRENT_DIR)/ccache:/root/.buildroot-ccache -v $(CURRENT_DIR)/scripts:/opt/buildroot/scripts -v $(CURRENT_DIR)/build:/opt/buildroot/output/build -it --name $(LIB_NAME)-run $(LIB_NAME)
	sudo rm -rf ./$(BUILD_DIR)
	sudo docker cp $(LIB_NAME)-run:/opt/buildroot/output/$(BUILD_DIR) .
	sudo docker stop $(LIB_NAME)-run
	sudo docker rm $(LIB_NAME)-run
	sudo rm ./Dockerfile

config: setup
	sudo cp ./.setup/Dockerfile-config ./Dockerfile
	sudo docker build -t $(LIB_NAME)-config --rm=true .
	sudo docker run -it --name $(LIB_NAME)-runconfig $(LIB_NAME)-config make nconfig
	sudo docker cp $(LIB_NAME)-runconfig:/opt/buildroot/.config .
	sudo docker stop $(LIB_NAME)-runconfig
	sudo docker rm $(LIB_NAME)-runconfig
	sudo rm ./Dockerfile

