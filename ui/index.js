var express = require("express");
var app = express();

app.use(express.static("dist/angular-cloud-run-poc"));
app.get("/", function (req, res) {
    res.redirect("/");
});

app.listen(4200);