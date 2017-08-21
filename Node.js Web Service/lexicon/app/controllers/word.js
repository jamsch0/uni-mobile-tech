const httpStatus = require("http-status");

const Word = require("../models/word");

module.exports.create = (request, response, next) => {
    Word.create(request.body)
        .then(word => response.status(httpStatus.CREATED).json(word))
        .catch(err => next(err));
};

module.exports.list = (request, response, next) => {
    const conditions = {};

    if ((typeof request.query.q).toLowerCase() === "string") {
        request.query.q = [request.query.q];
    }

    if ((typeof request.query.lang).toLowerCase() === "string") {
        request.query.lang = [request.query.lang];
    }

    if (request.query.q) {
        conditions.slug = new RegExp(`^${request.query.q.join("|").replace(".", "\\.")}`, "i");
    }

    Word.find(conditions)
        .exec()
        .then(words => {
            if (request.query.lang) {
                words.forEach(word => word.filterTranslations(request.query.lang));
            }

            response.json(words);
        })
        .catch(err => next(err));
};

module.exports.load = (request, response, next, slug) => {
    Word.getBySlug(slug)
        .then(word => {
            request.word = word;
            next();
        })
        .catch(err => next(err));
};

module.exports.get = (request, response) => {
    response.json(request.word);
};

module.exports.update = (request, response, next) => {
    request.word.update(request.body)
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};

module.exports.remove = (request, response, next) => {
    request.word.remove()
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};
