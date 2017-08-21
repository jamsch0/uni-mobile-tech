const express = require("express");
const controller = require("../../controllers/lesson");

const router = express.Router();

router.route("/")
    .post(controller.create)
    .get(controller.list);

router.param("name_slug", controller.load);

router.route("/:name_slug")
    .get(controller.get)
    .put(controller.update)
    .delete(controller.remove);

module.exports = router;
