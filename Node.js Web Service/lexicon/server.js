const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const express = require("express");
const httpStatus = require("http-status");
const logger = require("morgan");
const mongoose = require("mongoose");
const passport = require("passport");
const passportJwt = require("passport-jwt");
const serveIndex = require("serve-index");

const ExtractJwt = passportJwt.ExtractJwt;
const JwtStrategy = passportJwt.Strategy;

const config = require("./config");
const APIError = require("./app/apiError");
const User = require("./app/models/user");
const router = require("./app/routes");

const app = express();

// Log all requests
app.use(logger("common"));

// Use passport and JSON Web Tokens for authentication
app.use(passport.initialize());

const fromCookie = function(request) {
    if (request && request.cookies) {
        return request.cookies["jwt"];
    }
    return null;
};

const jwtOptions = {
    jwtFromRequest: ExtractJwt.fromExtractors([
        ExtractJwt.fromAuthHeader(),
        fromCookie
    ]),
    secretOrKey: config.secret
};

passport.use(new JwtStrategy(jwtOptions, (payload, done) => {
    User.get(payload.id)
        .then(user => done(null, user || false))
        .catch(err => { console.log(err); done(err, false) });
}));

// Parse request body parameters and attach them to request.body
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Parse request cookies and attach them to request.cookies
app.use(cookieParser());

app.set("view engine", "ejs");
app.set("views", "./app/views");

app.use("/", router);
app.use("/", express.static("public"));
app.use("/images", serveIndex("public/images", { icons: true }));

// Error handler
app.use((err, request, response, next) => {
    // Convert all errors to type APIError
    err = APIError.from(err);

    response.status(err.status).json({
        message: err.isPublic ? err.message : httpStatus[err.status],
        messages: err.isPublic ? err.messages : undefined
    });

    if (err.status == httpStatus.INTERNAL_SERVER_ERROR) {
        console.log(err);
    }
});

mongoose.connect(config.dbUrl);
app.listen(config.port, () => console.log(`starting on port ${config.port}`));
