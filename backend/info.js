const cheerio = require("cheerio");
const { domain, fetchOptions } = require("./common");
const fetch = require("node-fetch");

fetch(domain + "/profile.php", fetchOptions).then(res => res.text()).then(html => {
    const $ = cheerio.load(html, { _useHtmlParser2: true });
    const rows = $(".counter-value");
    if (!rows.length) return;
    process.stdout.write(JSON.stringify({
        today_download: $(rows[0]).text().replace(/\s/g, ""),
        total_download: $(rows[1]).text().replace(/\s/g, ""),
        corrections: $(rows[2]).text().replace(/\s/g, ""),
        donation: $(rows[3]).text().replace(/\s/g, "")
    }));
})
.catch(err => {
    process.stdout.write("ERR: " + err)
})