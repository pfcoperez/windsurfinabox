# Windsurf in a box

![logo](./logo/logo-gh.png)

Windsurf's Cascade agent within a Docker image, to be used in headless mode. With this image, you can use Windsurf Cascade agent without a Desktop environment which makes it possible to integrate in automatic processes such as code management pipelines. 

## Usage

- Build the image:
  ```bash
  docker build . -t windsurf
  ```
  
- Prepate your workspace directory with read and write permissions for user with `UID:GID=1000:1000`.
- Create a file named `windsurf-instructions.txt` and add it to the directory. It should contain your prompt for Windsurf.
- Get your Windsurf Auth token from a normal Windsurf editor:
  - `ctrl+shift+p`
  - Run the command Provide auth token:
![image](https://github.com/user-attachments/assets/02d383dd-30c8-4665-b3eb-ee083747cecb)
  
- Run the image generated with this project:

```bash
docker run --rm -it --name windsurf -e WINDSURF_TOKEN=$WINDSURF_TOKEN -v /home/pablo/.config/Windsurf:/home/ubuntu/.config/Windsurf -v /home/pablo/temp/workspace:/home/ubuntu/workspace windsurf
```

You might have noticed that the token is passed as the `WINDSURF_TOKEN` and the workspace mounted with `-v /home/pablo/temp/workspace:/home/ubuntu/workspace`.

🚧 Right now, `-v /home/pablo/.config/Windsurf:/home/ubuntu/.config/Windsurf` is required for the local configuration setting the editor to accept suggested actions automatically. This is just temporary and next commit to this repo will remove the need of passing a pre-set configuration.

## How does this work? 

This image leverages Xvfb to start a virtual X11 screen where the editor is launched, the Docker image entrypoint script uses `xdtool` to send commands as if it was the UI user. These commands include log-in with the provided token and the activation of a [preconfigured workflow](https://github.com/pfcoperez/windsurfinabox/blob/main/src/workflows/entry-workflow.md) with the following prompt:

> Follow the instructions described in the file windsurf-instructions.txt; Append a description of each step you follow in realtime and its outcome to the file windsurf-output.txt creating it if missing and including timestamps for each entry; Once finished, append a last line in windsurf-output.txt with the text "WORK-COMPLETED", also including a timestamp as with other entries (same format).
