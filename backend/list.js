
const cheerio = require("cheerio");
const { domain, fetchOptions } = require("./common");
const fetch = require("node-fetch");

module.exports = function (args, socket) {
    let [isExact, fromYear, toYear, lang, ext, order, query] = args;

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
        console.error("Not enough parameter");
        return;
    }

    listURL = listURL.join("&");

    fetch(listURL, fetchOptions).then(res => res.text()).then(html => {
        const $ = cheerio.load(html, { _useHtmlParser2: true });
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
            if (imageUrl[0] === ("/")) imageUrl = "";

            return {
                url: $(ele).find('h3 a').attr('href'),
                img: imageUrl,
                name: $(ele).find('h3').text().trim(),
                author: $(ele).find('div.authors').text().trim(),
            }
        });
        socket.write(JSON.stringify(books));
    })
        .catch((err) => {
            socket.write("ERR: " + err + "\n");
        });
}