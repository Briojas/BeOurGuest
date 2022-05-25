# Local Chainlink Node and External Adapter Startup
1. SSH to server housing docker containers for Node and EA.
2. Ensure the node's database is running.
    - for local databases, start docker container and detach:
        ```
        docker start kovan
        ```
    - for remote databases, check hosting service is up and active
3. Start the node itself:
    ```
    docker start -i chainlink-kovan
    ```
4. Login to the node, and then detach (Ctrl-P, Ctrl-Q).
5. Start the external adapter:
    ```
    docker start cl-ea-mqtt-client
    ```

Update the node with:
```
docker container create --name chainlink-kovan -p 6688:6688 -v ~/.chainlink-kovan:/chainlink -it --env-file=.env smartcontract/chainlink:tag-version local n 
```
- replace "tag-version" with latest from [here](https://hub.docker.com/r/smartcontract/chainlink/tags)