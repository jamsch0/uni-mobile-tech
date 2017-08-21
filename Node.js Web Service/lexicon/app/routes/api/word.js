const express = require("express");
const controller = require("../../controllers/word");

const router = express.Router();

router.route("/")
    .post(controller.create)
    .get(controller.list);

router.param("word_slug", controller.load);

router.route("/:word_slug")
    .get(controller.get)
    .put(controller.update)
    .delete(controller.remove);

module.exports = router;
