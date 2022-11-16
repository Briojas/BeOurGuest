import AWS from "aws-sdk";

async function handler(req, res) {
  if (req.method === "POST") {
    const s3 = new AWS.S3({
      apiVersion: "2006-03-01",
      accessKeyId: process.env.apiKey,
      secretAccessKey: process.env.apiSecret,
      endpoint: process.env.endpoint,
      region: "us-east-1",
      s3ForcePathStyle: true,
    });

    const params = {
      ACL: "public-read",
      Bucket: "3d6e4700-df7d-4462-8bad-0e6d3c2b21f1-bucket",
      Key: "IPFS-Script.json",
      Body: req.body,
    };
    const request = s3.putObject(params);
    request
      .on("httpHeaders", (statusCode, headers) => {
        const ipfsHash = headers["x-fleek-ipfs-hash"];
        // Do stuff with ifps hash....
        const ipfsHashV0 = headers["x-fleek-ipfs-hash-v0"];
        // Do stuff with the short v0 ipfs hash... (appropriate for storing on blockchains)

        res.status(statusCode).json({
          ipfsHash: ipfsHash,
          ipfsHashV0: ipfsHashV0,
        });
      })
      .send();

    //kill s3?
  }
}

export default handler;
