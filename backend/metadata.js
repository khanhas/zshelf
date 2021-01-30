const cheerio = require("cheerio");
const { fetchOptions } = require("./common");
const fetch = require("node-fetch");

if (process.argv.length < 3) {
    console.error("No link");
    return;
}
fetch(process.argv[2], fetchOptions).then(a => a.text()).then(html => {
    const $ = cheerio.load(html, { _useHtmlParser2: true });

    const author = $(`[itemprop="author"]`)
        .toArray()
        .map(e => $(e).text().trim())
        .join(", ");

    let description = $("#bookDescriptionBox").html();

    let detail = $(".bookDetailsBox");
    if (detail) {
        detail = $(detail[0]).find(".bookProperty")
            .toArray()
            .map(e => `<b>${$(e).find(".property_label").text().trim()}</b> ${$(e).find(".property_value").text().trim()}`)
            .join(" | ");
    }

    if (description) {
        description = detail + "<hr>" + description.trim();
    } else {
        description = detail;
    }

    let downloadURL = $(".dlButton").attr("href");
    if (downloadURL === "#") {
        downloadURL = "";
    }

    process.stdout.write(JSON.stringify({
        name: $("h1").text().trim(),
        author,
        imgFile: $(".details-book-cover").attr("href"),
        description,
        downloadURL,
    }));
})
.catch(err => {
    process.stdout.write("ERR: " + err);
});
