
const cheerio = require("cheerio");
const { domain, fetchOptions } = require("./common");
const fetch = require("node-fetch");

module.exports.getList = function (args, socket) {
    let [isExact, fromYear, toYear, lang, ext, order, query, page] = args;

    let listURL = [domain + "/s/?"];
    if (isExact && isExact === "1") listURL.push("e=1");
    if (fromYear && fromYear !== "Any") listURL.push("yearFrom=" + fromYear);
    if (toYear && toYear !== "Any") listURL.push("yearTo=" + toYear);
    if (lang && lang !== "Any") listURL.push("language=" + lang);
    if (ext && ext !== "Any") listURL.push("extensiont=" + ext);

    if (order) {
        order = ({
            "Best Match": "bestmatch",
            "By Title (A-Z)": "titleA",
            "By Title (Z-A)": "title",
            "By Year": "year",
            "File Size Asc.": "filesizeA",
            "File Size Des.": "filesize",
            "Most Popular": "popular",
            "Recently added": "date",
        })[order];

        if (!order) order = "popular";
        listURL.push("order=" + order);
    }

    if (query) listURL.push("q=" + encodeURI(query));

    if (listURL.length < 2) {
        // socket.write("[]");
        socket.write("ERR: Not enough query parameter\n");
        return;
    }

    if (page) listURL.push("page=" + page);

    listURL = listURL.join("&");
    fetchList(listURL, socket);
}

module.exports.getSaved = function(_, socket) {
    fetchList(domain + "/users/saved_books.php", socket);
}

function fetchList(listURL, socket) {
    fetch(listURL, fetchOptions).then(res => {
        const fileLength = parseInt(res.headers.get('content-length'));

        let raw = "";

        res.body.on("data", (chunk) => {
            raw += chunk;
            socket.write("PROG:" + Math.round(res.body.bytesWritten / fileLength * 100).toString() + "\n");
        });

        res.body.on('end', () => {
            socket.write("PROG:100\n");
            sendResult(raw);
        });

        res.body.on("error", (err) => {
            socket.write("ERR: 2 " + err + "\n");
            socket.end();
        });
    })
        .catch(err => {
            socket.write("ERR: 1 " + err +  "\n");
            socket.end();
        });

    function sendResult(html) {
        const $ = cheerio.load(html);

        let totalItems = $(".totalCounter")
        if (totalItems) {
            totalItems = parseInt(totalItems.text().replace(/[()+]/g, "")); 
            socket.write("TOTAL:" + totalItems.toString() + "\n");
        }

        const books = $(".resItemBoxBooks").get().map(ele => {
            const image = $(ele).find('img');
            let imageUrl;
            let imgSources = image.attr('data-srcset');
            if (imgSources) {
                imgSources = imgSources.split(", ");
                imageUrl = imgSources[imgSources.length - 1]
                    .split(" ")[0];
            } else {
                imageUrl = image.attr('data-src');
            }
            if (!imageUrl || imageUrl[0] === "/") imageUrl = "";

            return {
                url: $(ele).find('h3 a').attr('href'),
                img: imageUrl,
                name: $(ele).find('h3').text().trim(),
                author: $(ele).find('div.authors').text().trim(),
            }
        });
        socket.write(JSON.stringify(books));
        socket.end();
    }
}