const { writeFileSync, copyFileSync, existsSync, mkdirSync, createWriteStream, constants } = require("fs");
const { join: pathJoin, extname, basename } = require("path");
const { v4 } = require("uuid");
const { domain, fetchOptions, additionalBookLocation, parentFolderUUID} = require("./common");
const fetch = require("node-fetch");

module.exports = function (args, socket) {
    if (args.length < 1) {
        socket.write("ERR: No download link\n");
        return;
    }

    const xochitlFolder = "/home/root/.local/share/remarkable/xochitl/";
    const downloadURL = domain + args[0];
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
                // Convert multi-byte chars to their true representation
                name = Buffer.from(name, "binary").toString("utf8");

                fileExt = extname(name);
                fileName = basename(name, fileExt);
                console.log(fileName, fileExt);
            }
        }

        if (!fileName || !fileExt) {
            socket.write("ERR: 2 No file\n");
            return;
        }

        const fileLength = parseInt(response.headers.get('content-length'));

        const uuid = v4();
        const tempFilePath = "/tmp/" + uuid;
        console.log(tempFilePath, fileLength);

        const fileStream = createWriteStream(tempFilePath);

        response.body.on("data", (chunk) => {
            fileStream.write(chunk, () => {
                socket.write("PROG:" + Math.floor(fileStream.bytesWritten / fileLength * 95).toString() + "\n");
                if (fileStream.bytesWritten == fileLength) {
                    fileStream.close();
                }
            });
        });

        response.body.on("error", (error) => {
            socket.write("ERR: 2 " + error + "\n");
            socket.end();
        });

        fileStream.on('close', () => {
            socket.write("DOWNLOAD DONE\n");

            if (fileExt == ".epub" || fileExt == ".pdf") {
                writeFileSync(xochitlFolder + uuid + ".metadata", JSON.stringify({
                    "deleted": false,
                    "lastModified": "1",
                    "lastOpenedPage": 0,
                    "metadatamodified": false,
                    "modified": false,
                    "parent": parentFolderUUID || "",
                    "pinned": false,
                    "synced": false,
                    "type": "DocumentType",
                    "version": 1,
                    "visibleName": fileName
                }));

                if (fileExt == ".epub") {
                    writeFileSync(xochitlFolder + uuid + ".content", JSON.stringify({ "fileType": "epub" }));
                } else if (fileExt == ".pdf") {
                    writeFileSync(xochitlFolder + uuid + ".content", JSON.stringify({ "fileType": "pdf" }));
                }

                copyFileSync(tempFilePath, pathJoin(xochitlFolder, uuid + fileExt), constants.COPYFILE_FICLONE);
                socket.write("COPIED XOCHITL\n");
            }

            if (additionalBookLocation) {
                if (!existsSync(additionalBookLocation)) {
                    mkdirSync(additionalBookLocation, { recursive: true });
                }
                copyFileSync(tempFilePath, pathJoin(additionalBookLocation, fileName + fileExt), constants.COPYFILE_FICLONE);
                socket.write("COPIED LOCAL\n");
            }
            socket.write("PROG:100\n");
            socket.end();
        });
    })
        .catch(err => {
            socket.write("ERR: 1 " + err + "\n");
            socket.end();
        });
}
