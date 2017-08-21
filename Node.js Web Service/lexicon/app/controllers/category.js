const httpStatus = require("http-status");

const Category = require("../models/category");
const Word = require("../models/word");

module.exports.create = (request, response, next) => {
    Category.create(request.body)
        .then(category => response.status(httpStatus.CREATED).json(category))
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
        conditions.name = {
            slug: new RegExp(`^${request.query.q.join("|").replace(".", "\\.")}`, "i")
        };
    }

    Category.find(conditions)
        .exec()
        .then(categories => {
            if (request.query.lang) {
                categories.forEach(category => {
                    category.name.filterTranslations(request.query.lang);
                    category.words.forEach(word => word.filterTranslations(request.query.lang));
                });
            }

            response.json(categories);
        })
        .catch(err => next(err));
};

module.exports.load = (request, response, next, slug) => {
    Word.getBySlug(slug)
        .then(word => {
            Category.getByName(word)
                .then(category => {
                   request.category = category;
                   next(); 
                });
        })
        .catch(err => next(err));
};

module.exports.get = (request, response) => {
    response.json(request.category);
};

module.exports.update = (request, response, next) => {
    request.category.update(request.body)
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};

module.exports.remove = (request, response, next) => {
    request.category.remove()
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};
