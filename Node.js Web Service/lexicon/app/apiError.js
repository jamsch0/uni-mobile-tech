const bcrypt = require("bcrypt-as-promised");
const httpStatus = require("http-status");
const mongoose = require("mongoose");

class APIError extends Error {
    constructor(message, status = httpStatus.INTERNAL_SERVER_ERROR, isPublic = false) {
        super(message);

        this.status = status;
        this.isPublic = isPublic;
    }

    // Convert an Error into an APIError
    static from(err) {
        if (err instanceof APIError) {
            return err;
        } else if (err instanceof bcrypt.MISMATCH_ERROR) {
            return new APIError(err.message, httpStatus.UNAUTHORIZED);
        } else if (err instanceof mongoose.Error.ValidationError) {
            const newError = new APIError(err.message, httpStatus.BAD_REQUEST, true);
            newError.messages = [];

            for (const e of Object.values(err.errors)) {
                newError.messages.push(e.message);
            }

            return newError;
        } else {
            return new APIError(err.message);
        }
    }
}

module.exports = APIError;
