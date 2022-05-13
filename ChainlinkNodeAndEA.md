# Local Chainlink Node and External Adapter Setup
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