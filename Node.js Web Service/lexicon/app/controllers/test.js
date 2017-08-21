const httpStatus = require("http-status");

require("../shuffle");
const Category = require("../models/category");
const Lang = require("../models/lang");
const Test = require("../models/test");

module.exports.create = (request, response, next) => {
    Test.create(request.body)
        .then(test => response.status(httpStatus.CREATED).json(test))
        .catch(err => next(err));
};

module.exports.createNew = (request, response, next) => {
    Category.find({ name: new RegExp(`${request.body.categories.map(name => name.replace(".", "\\.")).join("|")}`, "i") })
        .exec()
        .then(categories => {
            let words = categories.map(category => category.words).reduce((a, b) => a.concat(b), []).map(word => word._id);

            Test.create({
                    user: request.user._id,
                    langTo: request.body.to,
                    langFrom: request.body.from,
                    questions: words.map(word => ({ word: word})).shuffle()
                })
                .then(test => response.status(httpStatus.CREATED).json(test))
        })
        .catch(err => next(err));

    // Word.getByCategories(request.body.categories)
    //     .then(words => Promise.all(
    //         words.map(word => {
    //             word.filterTranslations([request.body.to, request.body.from]);

    //             const match = word.translations[0].text.match(/\${(.*)}/i);

    //             if (!match || match.length < 2) {
    //                 return word;
    //             }

    //             return Word.getByCategories([match[1]])
    //                 .then(replacementWords => {
    //                     const replacementWord = replacementWords.pick();

    //                     word.translations.forEach(translation =>
    //                         translation.text = translation.text.replace(match[0],
    //                                                                     replacementWord.translations.find(replacement =>
    //                                 replacement.language.isoCode == translation.language.isoCode
    //                             ).text
    //                         )
    //                     );

    //                     return word;
    //                 });
    //         })
    //     ))
    //     .then(words =>
    //         Test.create({
    //                 user: request.user._id,
    //                 langTo: request.body.to,
    //                 langFrom: request.body.from,
    //                 questions: words.map(word => ({ word: word })).shuffle()
    //             })
    //             .then(test => response.status(httpStatus.CREATED).json(test))
    //     )
    //     .catch(err => next(err));
};

module.exports.list = (request, response, next) => {
    Test.find({ user: request.user._id })
        .exec()
        .then(tests => response.json(tests))
        .catch(err => next(err));
};

module.exports.load = (request, response, next, id) => {
    Test.get(id)
        .then(test => {
            request.test = test;
            next();
        })
        .catch(err => next(err));
};

module.exports.get = (request, response) => {
    response.json(request.test);
};

module.exports.update = (request, response, next) => {
    request.test.update(request.body)
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};

module.exports.remove = (request, response, next) => {
    request.test.remove()
        .then(() => response.status(httpStatus.NO_CONTENT).send())
        .catch(err => next(err));
};
