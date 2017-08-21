const express = require("express");

const authRoutes = require("./auth");
const categoryRoutes = require("./category");
const langRoutes = require("./lang");
const lessonRoutes = require("./lesson");
const userRoutes = require("./user");
const wordRoutes = require("./word");

const router = express.Router();

router.use("/categories", categoryRoutes);
router.use("/languages", langRoutes);
router.use("/lessons", lessonRoutes);
router.use("/login", authRoutes);
router.use("/users", userRoutes);
router.use("/words", wordRoutes);

module.exports = router;
