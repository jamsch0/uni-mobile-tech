const express = require("express");
const controller = require("../../controllers/lang");

const router = express.Router();

router.route("/")
    .post(controller.create)
    .get(controller.list);

router.param("lang_iso_code", controller.load);

router.route("/:lang_iso_code")
    .get(controller.get)
    .put(controller.update)
    .delete(controller.remove);

module.exports = router;
