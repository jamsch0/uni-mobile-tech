const httpStatus = require("http-status");

const Language = require("../models/lang");

module.exports.create = (request, response, next) => {
    Language.create(request.body)
        .then(lang => response.status(httpStatus.CREATED).json(lang))
        .catch(err => next(err));
};

module.exports.list = (request, response, next) => {
    Language.find({})
        .exec()
        .then(langs => response.json(langs))
        .catch(err => next(err));
};

module.exports.load = (request, response, next, isoCode) => {
    Language.getByIsoCode(isoCode)
        .then(lang => {
            request.lang = lang;
            next();
        })
        .catch(err => next(err));
};

module.exports.get = (request, response) => {
    response.json(request.lang);
};

module.exports.update = (request, response, next) => {
    request.lang.update(request.body)
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};

module.exports.remove = (request, response, next) => {
    request.lang.remove()
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};
