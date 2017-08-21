const jwt = require("jsonwebtoken");
const httpStatus = require("http-status")

const config = require("../../config");
const APIError = require("../apiError");
const Lang = require("../models/lang");
const User = require("../models/user");

module.exports.create = (request, response, next) => {
    Promise.all([
        Lang.getByIsoCode(request.body.to),
        Lang.getByIsoCode(request.body.from)
    ])
    .then (([to, from]) => 
        User.create({
                name: request.body.name,
                password: request.body.password,
                langTo: to,
                langFrom: from
            })
            .then(user => response.status(httpStatus.CREATED).json(user))
    )
    .catch(err => {
        if (err.code === 11000 || err.code === 11001) {
            err = new APIError("name already in use", httpStatus.CONFLICT, true);
        }

        next(err);
    });
};

module.exports.login = (request, response, next) => {
    User.getByName(request.body.name)
        .then(user => user.comparePassword(request.body.password)
            .then(() => user.populate("langTo langFrom").execPopulate()
                .then(() => {
                    user = user.toObject();
                    user.token = jwt.sign({ id: user._id.toString() }, config.secret, { expiresIn: "1h" });
                    response.json(user);
                })
            )
        )
        .catch(err => next(err));
};

module.exports.authenticate = (request, response, next) => {
    if (request.user.name !== request.params.user_name) {
        response.status(httpStatus.FORBIDDEN).send();
    } else {
        next();
    }
};

module.exports.get = (request, response) => {
    response.json(request.user);
};

module.exports.update = (request, response, next) => {
    request.user.update(request.body)
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};

module.exports.remove = (request, response, next) => {
    request.user.remove()
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};
