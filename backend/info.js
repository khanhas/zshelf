const cheerio = require("cheerio");
const { domain, fetchOptions } = require("./common");
const fetch = require("node-fetch");

module.exports = function (args, socket) {
    const profile = fetch(domain + "/papi/user/dstats", fetchOptions).then(res => res.json()).then(json => {
        if (!json) return;

        return ({
            today_download: json.dailyDownloads + "/" + json.dailyDownloadsLimit
        });
    })
        .catch(err => {
            socket.write("ERR: 1 " + err + "\n");
            socket.end();
        });

    const history = fetch(domain + "/users/dstats.php?today", fetchOptions).then(res => res.text()).then(html => {
        const $ = cheerio.load(html);
        const rows = $(".dstats-row");
        if (!rows.length) return;

        return rows.get().map(row => {
            const a = $(row).find("a");
            if (!a) return undefined;

            let url = a.attr("href");
            let name = a.text().trim();
            if (!url || !name) return undefined;

            if (url[0] !== "/") url = "/" + url;

            return ({ url, name });
        })
            .filter(a => a);
    })
        .catch(err => {
            socket.write("ERR: 1 " + err + "\n");
            socket.end();
        });

    Promise.all([profile, history]).then(results => {
        if (!results || results.length < 2) return;

        const final = results[0];
        final.today_list = results[1];
        socket.write(JSON.stringify(final));
        socket.write("\n");
        socket.end();
    })
        .catch(err => {
            socket.write("ERR: 1 " + err + "\n");
            socket.end();
        })

}
