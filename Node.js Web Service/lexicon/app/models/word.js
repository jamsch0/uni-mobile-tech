const httpStatus = require("http-status");
const integerValidator = require("mongoose-integer");
const mongoose = require("mongoose");

const APIError = require("../apiError");

const WordSchema = new mongoose.Schema({
    _id: {
        type: String,
        unique: true,
        required: true,
        lowercase: true
    },
    translations: [{
        text: {
            type: String,
            required: true
        },
        rating: {
            type: Number,
            integer: true,
            default: 1
        },
        language: {
            type: String,
            ref: "Language",
            required: true
        }
    }]
});

WordSchema.plugin(integerValidator);

WordSchema.methods.filterTranslations = function(languages) {
    this.translations = this.translations.filter(translation => languages.includes(translation.language));
};

WordSchema.statics.getBySlug = function(slug) {
    return this.findById(slug)
        .exec()
        .then(word => word || Promise.reject(new APIError("word not found", httpStatus.NOT_FOUND, true)));
};

// DEPRECATED
WordSchema.statics.getByCategories = function(categories) {
    return this.find({ _id: new RegExp(`^${categories.map(category =>
            category.concat(".").replace(".", "\\.")).join("|")}`, "i") })
        .exec()
};

module.exports = mongoose.model("Word", WordSchema);
