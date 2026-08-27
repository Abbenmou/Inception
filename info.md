# Docker Build Time and Runtime

Build time is when you run `docker build .`. During this phase, Docker reads the `Dockerfile` from top to bottom and constructs an image. An image is a frozen, reusable snapshot of a filesystem and the software installed in it, similar to a template for creating containers.

Runtime is when you run `docker run <image>` or start a service with `docker compose up`. Docker creates a live container from the image. The container runs as an actual process on the host, with its own process ID, and continues running until it exits or is stopped.

The `RUN` instruction is executed during build time. For example, when Docker encounters `RUN apt-get install ...`, it temporarily creates a throwaway container, executes the command, saves the resulting filesystem changes as a new image layer, and then removes the temporary container. The installed files become part of the final image, but the `RUN` command itself does not execute again when a container is started.

The `ENTRYPOINT` and `CMD` instructions are not executed during the image build. Instead, they are stored in the image metadata and define what should run when a container starts. When a container is started with `docker run` or by Docker Compose, the configured entrypoint is launched in a new live process. This happens each time the container starts or restarts. `ENTRYPOINT` defines the main startup process, while `CMD` provides default arguments or a default command.