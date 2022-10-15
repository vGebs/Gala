const mongoose = require("mongoose");

const view = new mongoose.Schema({
    viewerUID: {
        type: String,
        required: true
    },
    viewedUID: {
        type: String,
        required: true
    },
    pid: {
        type: Date,
        required: true
    }
});

const StoryView = new mongoose.model("StoryView", view);

module.exports = StoryView