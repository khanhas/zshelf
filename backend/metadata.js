const cheerio = require("cheerio");
const { domain, fetchOptions } = require("./common");
const fetch = require("node-fetch");

module.exports = function (args, socket) {
    if (args.length < 1) {
        console.log("ERR: No link");
        return;
    }

    fetch(domain + args[0], fetchOptions).then(a => a.text()).then(html => {
        const $ = cheerio.load(html);

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

        let dlUrl = $(".dlButton").attr("href");
        if (dlUrl === "#") {
            dlUrl = "";
        }

        const similars = $("#bMosaicBox .brick").get().map(a => ({
            url: $(a).find("a").attr("href"),
            img: $(a).find("img").attr("src"),
        }));

        socket.write(JSON.stringify({
            name: $("h1").text().trim(),
            author,
            img: $(".details-book-cover").attr("href"),
            description,
            dlUrl,
            similars,
        }));
        socket.end();
    })
        .catch(err => {
            socket.write("ERR: 1 " + err + "\n");
            socket.end();
        });
}
