const config = JSON.parse(require("fs").readFileSync(__dirname + "/../config.json"));

module.exports.fetchOptions = {
    headers: {
        "Upgrade-Insecure-Requests": "1",
        "Sec-GPC": "1",
        "Cookie": config.cookie,
    },
    method: "GET",
    compress: true,
    redirect: "follow",
};

module.exports.domain = config.domain;
module.exports.listURL = config.listURL;
module.exports.additionalBookLocation = config.additionalBookLocation;
module.exports.parentFolderUUID = config.parentFolderUUID;
