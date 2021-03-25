# ROS-Jetson-Docker
Create a Docker image for Jetson with ROS melodic-desktop-full. Also, make it possible to start catkin_make and ROS nodes on the container.

## Installation
```bash
#!/bin/bash
git clone https://github.com/shikishima-TasakiLab/ros-jetson-docker.git ROS-Jetson
```

## How to use

### Creating a Docker image

Build the Docker image with the following command.
```bash
#!/bin/bash
./ROS-Jetson/docker/build-docker.sh
```

### Start Docker container

1. Start the Docker container with the following command.
    ```bash
    #!/bin/bash
    ./ROS-Jetson/docker/run-docker.sh
    ```
    |option       |Parameters|Description                                      |Default      |Example                                           |
    |-----------------|----------|------------------------------------------|------------|---------------------------------------------|
    |`-h`, `--help`   |None      |Show help                              |None        |`-h`                                         |
    |`-n`, `--name`   |NAME      |Specify the name of the container                      |`ros-master`|`-n ros-talker`                              |
    |`-e`, `--env`    |ENV=VALUE |Specify the environment variable of the container (multiple can be specified)|None        |`-e ROS_MASTER_URI=http://192.168.2.10:11311`|
    |`-c`, `--command`|CMD       |Specify the command to be executed when the container starts    |None        |`-c roscore` , `-c "rosrun rviz rviz"`       |

2. When using multiple ROS packages in the Docker container of ROS-Bridge, execute the following command in another terminal.

    ```bash
    #!/bin/bash
    ./ROS-Jetson/docker/exec-docker.sh
    ```
    |option    |Parameters|Description                |Default|Example               |
    |--------------|----------|--------------------|------|-----------------|
    |`-h`, `--help`|None      |Show help        |None  |`-h`             |
    |`-i`, `--id`  |ID        |Specify the container ID  |None  |`-i 4f8eb7aeded7`|
    |`-n`, `--name`|NAME      |Specify the name of the container|None  |`-n ros-talker`  |

### Create / build / execute ROS package

1. Start the container with `./ROS-Jetson/docker/run-docker.sh`

2. Create a package in `~/catkin_ws/src/`

    ```bash
    #!/bin/bash
    cd ~/catkin_ws/src

    # Create a package
    # catkin_create_pkg ...
    #
    # Edit the source code

    # Download from GitHub
    # git clone ...
    ```

3. Go to `~/catkin_ws`and run`catkin_make`

    ```bash
    #!/bin/bash
    cd ~/catkin_ws
    catkin_make
    ```

4. The built ROS package can be used by executing the following command．

    ```bash
    #!/bin/bash
    source ~/catkin_ws/devel/setup.bash

    # Start of ROS node
    # rosrun ... ...
    # roslaunch ... ...
    ```
