const mongoose = require("mongoose");

const view = new mongoose.Schema({
    viewerUID: {
        type: String,
        required: true
    },
    viewedUID: {
        type: String,
        required: true
    }
});

const RecentlyJoinedView = new mongoose.model("RecentlyJoinedView", view);

module.exports = RecentlyJoinedView