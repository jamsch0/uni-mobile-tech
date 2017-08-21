const express = require("express");
const controller = require("../../controllers/test");

const router = express.Router();

router.route("/")
    .post(controller.create)
    .get(controller.list);

router.param("test_id", controller.load);

router.route("/:test_id")
    .get(controller.get)
    .put(controller.update)
    .delete(controller.remove);

router.route("/new").post(controller.createNew);

module.exports = router;
