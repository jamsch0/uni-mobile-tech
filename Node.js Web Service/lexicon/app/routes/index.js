const express = require("express");

const apiRoutes = require("./api");
const webRoutes = require("./web");

const router = express.Router();

router.get("/", (request, response) => response.redirect("/web/"));

router.use("/web", webRoutes);
router.use("/api", apiRoutes);

module.exports = router;
