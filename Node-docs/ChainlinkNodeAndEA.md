# Chainlink Node Build and Startup Commands - Goerli Testnet
### Building:
```
sudo docker run --name chainlink-goerli -p 6688:6688 -v ~/.chainlink-goerli:/chainlink -it --env-file=.env smartcontract/chainlink:tag-version local n
```
### Updating:
```
sudo docker kill chainlink-goerli
sudo docker rename chainlink-goerli chainlink-goerli-old
sudo docker run --name chainlink-goerli -p 6688:6688 -v ~/.chainlink-goerli:/chainlink -it --env-file=.env smartcontract/chainlink:tag-version local n
```
- replace "tag-version" with latest from [here](https://hub.docker.com/r/smartcontract/chainlink/tags)

- Edit .env and other text files with:
    ```
    nano .env
    ```

### Database Setup:
```
sudo docker run --name psql-goerli -e POSTGRES_PASSWORD=mysecretpassword -d -p 5432:5432 postgres
```
- Node's .env database entry:
    ```
    DATABASE_URL=postgresql://postgres:mysecretpassword@ip_address:5432/postgres
    ```