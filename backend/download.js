const { writeFile, copyFile, existsSync, mkdirSync, createWriteStream } = require("fs");
const { join: pathJoin, extname, basename } = require("path");
const { v4 } = require("uuid");
const { domain, fetchOptions, additionalBookLocation } = require("./common");
const fetch = require("node-fetch");

if (process.argv.length < 3) {
    console.error("No download link");
    return;
}

const xochitlFolder = "/home/root/.local/share/remarkable/xochitl/";
const downloadURL = domain + process.argv[2];
console.log(downloadURL);

fetch(downloadURL, fetchOptions).then((response) => {
    console.log("Redirected to:", response.url);

    let fileName;
    let fileExt;

    const disposition = response.headers.get('content-disposition');
    if (disposition) {
        const nameMatch = disposition.match(/filename="(.+)"/);
        if (nameMatch) {
            let name = nameMatch[1].replace(" (z-lib.org)", "");

            fileExt = extname(name);
            fileName = basename(name, fileExt);
            console.log(fileName, fileExt);
        }
    }

    if (!fileName || !fileExt) {
        console.log("ERR: No file");
        process.exit(1);
    }

    const fileLength = parseInt(response.headers.get('content-length'));

    const uuid = v4();
    const tempFilePath = "/tmp/" + uuid;
    console.log(tempFilePath, fileLength);

    const fileStream = createWriteStream(tempFilePath);

    response.body.on("data", (chunk) => {
        fileStream.write(chunk);
        console.log("PROG:" + Math.floor(fileStream.bytesWritten / fileLength * 100));
    })

    response.body.on("error", (error) => {
        console.log("ERR: " + error);
        process.exit(1);
    })
    
    response.body.on('end', () => {
        console.log("PROG:100");
        console.log("DONE");

        if (fileExt == ".epub" || fileExt == ".pdf") {
            writeFile(xochitlFolder + uuid + ".metadata", JSON.stringify({
                "deleted": false,
                "lastModified": "1",
                "lastOpenedPage": 0,
                "metadatamodified": false,
                "modified": false,
                "parent": "",
                "pinned": false,
                "synced": false,
                "type": "DocumentType",
                "version": 1,
                "visibleName": fileName
            }), () => { });

            copyFile(tempFilePath, pathJoin(xochitlFolder, uuid + fileExt), () => { console.log("COPIED XOCHITL") });
        }

        if (additionalBookLocation) {
            if (!existsSync(additionalBookLocation)) {
                mkdirSync(additionalBookLocation, { recursive: true });
            }
            copyFile(tempFilePath, pathJoin(additionalBookLocation, fileName + fileExt), () => { console.log("COPIED LOCAL") });
        }
    });
})
.catch(err => {
    console.log("ERR: " + err);
    process.exit(1);
});
