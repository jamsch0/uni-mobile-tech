const express = require("express");
const passport = require("passport");
const controller = require("../../controllers/user");

const testRoutes = require("./test");

const router = express.Router();

router.post("/", controller.create);

router.use("/:user_name", passport.authenticate("jwt", { session: false }), controller.authenticate);

router.route("/:user_name")
    .get(controller.get)
    .put(controller.update)
    .delete(controller.remove);

router.use("/:user_name/tests", testRoutes);

module.exports = router;
