const autopopulate = require("mongoose-autopopulate");
const httpStatus = require("http-status");
const mongoose = require("mongoose");

const APIError = require("../apiError");

const LessonSchema = new mongoose.Schema({
    name: {
        type: String,
        ref: "Word",
        required: true,
        autopopulate: true
    },
    words: {
        type: [{
            type: String,
            ref: "Word",
            autopopulate: true
        }],
        required: true
    }
});

LessonSchema.plugin(autopopulate);

LessonSchema.statics.get = function(id) {
    return this.findById(id)
        .exec()
        .then(lesson => lesson || Promise.reject(new APIError("lesson not found", httpStatus.NOT_FOUND, true)));
};

LessonSchema.statics.getByName = function(name) {
    return this.findOne({ name: name || "" })
        .exec()
        .then(lesson => lesson || Promise.reject(new APIError("lesson not found", httpStatus.NOT_FOUND, true)));
};

module.exports = mongoose.model("Lesson", LessonSchema);
