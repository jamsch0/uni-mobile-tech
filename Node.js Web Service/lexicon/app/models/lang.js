const httpStatus = require("http-status");
const mongoose = require("mongoose");

const APIError = require("../apiError");

const LangSchema = new mongoose.Schema({
    _id: {
        type: String,
        unique: true,
        lowercase: true,
        required: true,
        minlength: 2,
        maxlength: 2
    },
    name: {
        type: String,
        ref: "Word",
        required: true
    }
});

LangSchema.statics.getByIsoCode = function(isoCode) {
    return this.findById(isoCode)
        .exec()
        .then(lang => lang || Promise.reject(new APIError("language not found", httpStatus.NOT_FOUND, true)));
};

module.exports = mongoose.model("Language", LangSchema);
