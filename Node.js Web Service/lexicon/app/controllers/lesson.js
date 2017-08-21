const httpStatus = require("http-status");

const Lesson = require("../models/lesson");
const Word = require("../models/word");

module.exports.create = (request, response, next) => {
    Lesson.create(request.body)
        .then(lesson => response.status(httpStatus.CREATED).json(lesson))
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

    Lesson.find(conditions)
        .exec()
        .then(lessons => {
            if (request.query.lang) {
                lessons.forEach(lesson => {
                    lesson.name.filterTranslations(request.query.lang);
                    lesson.words.forEach(word => word.filterTranslations(request.query.lang));
                });
            }

            response.json(lessons);
        })
        .catch(err => next(err));
};

module.exports.load = (request, response, next, slug) => {
    Word.getBySlug(slug)
        .then(word => {
            Lesson.getByName(word)
                .then(lesson => {
                    request.lesson = lesson;
                    next();
                });
        })
        .catch(err => next(err));
};

module.exports.get = (request, response) => {
    response.json(request.lesson);
};

module.exports.update = (request, response, next) => {
    request.lesson.update(request.body)
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};

module.exports.remove = (request, response, next) => {
    request.lesson.remove()
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};
