const autopopulate = require("mongoose-autopopulate");
const httpStatus = require("http-status");
const mongoose = require("mongoose");

const APIError = require("../apiError");

const CategorySchema = new mongoose.Schema({
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

CategorySchema.plugin(autopopulate);

CategorySchema.statics.get = function(id) {
    return this.findById(id)
        .exec()
        .then(category => category || Promise.reject(new APIError("category not found", httpStatus.NOT_FOUND, true)));
};

CategorySchema.statics.getByName = function(name) {
    return this.findOne({ name: name || "" })
        .exec()
        .then(category => category || Promise.reject(new APIError("category not found", httpStatus.NOT_FOUND, true)));
};

module.exports = mongoose.model("Category", CategorySchema);
