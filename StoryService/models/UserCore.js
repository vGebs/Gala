const mongoose = require("mongoose");

const GeoSchema = new mongoose.Schema({
    type: {
        type: String,
        default: "Point"
    },
    coordinates: {
        type: [Number],
        index: "2dsphere"
    },
    _id: false
});

const AgeRangePreferenceSchema = new mongoose.Schema({
    maxAge: {
        type: Number,
        default: 99
    },
    minAge: {
        type: Number,
        default: 18
    },
    _id: false
});

const UserBasicSchema = new mongoose.Schema({
    uid: {
        type: String,
        required: true,
        unique: true
    },
    name: {
        type: String,
        required: true,
        unique: false
    },
    birthdate: {
        type: Date,
        required: true,
        unique: false
    },
    gender: {
        type: String,
        required: true,
        unique: false
    },
    sexuality: {
        type: String,
        required: true,
        unique: false
    },
    dateJoined: Date,
    _id: false
});

const UserCoreSchema = new mongoose.Schema({
    searchRadiusComponents: {
        location: GeoSchema,
        willingToTravel: {
           type: Number,
           default: 50
        }
    },
    ageRangePreference: AgeRangePreferenceSchema,
    userBasic: UserBasicSchema
}); 

const UserCore = new mongoose.model("UserCore", UserCoreSchema)

module.exports = UserCore;