const fs = require("fs");

const html = fs.readFileSync("files/index.html").toString();

var jsdom = require('jsdom').JSDOM;
var dom = new jsdom(html, {});
var $ = require('jquery')(dom.window);

$("meta[property='og:title']").attr("content", "something")

console.log($("html")[0].outerHTML);
