var express = require("express");
var app = express();

app.use(express.static("dist/angular-cloud-run-poc"));
// Use * to catch all urls into index.html
app.get("*", function (req, res) {
    res.redirect("/");
});

app.listen(4200);