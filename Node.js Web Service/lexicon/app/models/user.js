const bcrypt = require("bcrypt-as-promised");
const httpStatus = require("http-status");
const mongoose = require("mongoose");

const APIError = require("../apiError");

const UserSchema = new mongoose.Schema({
    name: {
        type: String,
        unique: true,
        required: true,
        minlength: 2,
        maxlength: 16,
        match: /^[a-z0-9_-]*$/
    },
    password: {
        type: String,
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
    created: {
        type: Date,
        default: Date.now
    }
});

UserSchema.pre("save", function(next) {
    if (this.isModified("password") || this.isNew) {
        bcrypt.genSalt(10)
            .then(salt => bcrypt.hash(this.password, salt)
                .then(hash => {
                    this.password = hash;
                    next();
                })
                .catch(err => next(err))
            .catch(err => next(err)));
    } else {
        next();
    }
});

UserSchema.methods.comparePassword = function(password) {
    return bcrypt.compare(password, this.password);
};

UserSchema.statics.get = function(id) {
    return this.findById(id)
        .exec()
        .then(user => user || Promise.reject(new APIError("user not found", httpStatus.NOT_FOUND, true)));
};

UserSchema.statics.getByName = function(name) {
    return this.findOne({ name: name || "" })
        .exec()
        .then(user => user || Promise.reject(new APIError("user not found", httpStatus.NOT_FOUND, true)));
}

module.exports = mongoose.model("User", UserSchema);
