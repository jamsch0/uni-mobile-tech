const httpStatus = require("http-status");
const mongoose = require("mongoose");

const APIError = require("../apiError");

const Schema = mongoose.Schema;
const ObjectId = Schema.Types.ObjectId;

const TestSchema = new Schema({
    user: {
        type: ObjectId,
        ref: "User",
        required: true
    },
    langTo: {
        type: String,
        ref: "Language",
        required: true
    },
    langFrom: {
        type: String,
        ref: "Language",
        required: true
    },
    questions: {
        type: [{
            word: {
                type: String,
                ref: "Word",
                required: true
            },
            response: String    // filled out when test is submitted
        }],
        required: true
    },
    completed: Date,    // filled out when test is submitted
    created: {
        type: Date,
        default: Date.now
    }
});

TestSchema.statics.get = function(id) {
    return this.findById(id)
        .exec()
        .then(test => test || Promise.reject(new APIError("test not found", httpStatus.NOT_FOUND, true)));
};

module.exports = mongoose.model("Test", TestSchema);
