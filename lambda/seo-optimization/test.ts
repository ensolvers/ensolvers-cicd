import SEOOptimizer from "./lib/SEOOptimizer";

const fs = require("fs");

const html = fs.readFileSync("files/index.html").toString();

const optimizations = {
    "head": {
        "meta[property='og:title']": '<meta property="og:title" content="Title" />',
        "meta[property='og:description']": '<meta property="og:description" content="Description" />',

        "meta[name='description']": '<meta name="description" content="Description" />',

        "title": "Title"
    }
}

console.log(SEOOptimizer.optimize(html, optimizations));
