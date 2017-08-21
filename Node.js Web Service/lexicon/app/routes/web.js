const express = require("express");
const passport = require("passport");

const Lang = require("../models/lang");
const Test = require("../models/test");
const Word = require("../models/word");

const router = express.Router();

router.get("/login", (request, response) => response.render("pages/login"));

router.use("/", passport.authenticate("jwt", { session: false, failureRedirect: "/web/login" }));

router.get("/", (request, response) => response.render("pages/index"));

router.get("/tests", (request, response, next) => {
    Test.find({ user: request.user._id })
        .exec()
        .then(tests => {
            tests.sort((a, b) => {
                if (a.completed > b.completed) {
                    return -1;
                } else if (a.completed < b.completed) {
                    return 1;
                } else {
                    return 0;
                }
            });

            response.render("pages/tests", { tests: tests });
        })
        .catch(err => next(err));
});

router.get("/words", (request, response, next) => {
    Promise.all([Word.find({}).exec(), Lang.find({}).exec()])
        .then(([words, langs]) => {
            langs.sort((a, b) => {
                if (a.isoCode > b.isoCode) {
                    return 1;
                } else if (a.isoCode < b.isoCode) {
                    return -1;
                } else {
                    return 0;
                }
            });

            response.render("pages/words", { words: words, langs: langs });
        })
        .catch(err => next(err));
});

module.exports = router;
