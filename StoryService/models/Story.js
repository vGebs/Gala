const mongoose = require("mongoose");

const story = new mongoose.Schema({
    uid: {
        type: String,
        required: true
    },
    pid: {
        type: Date,
        required: true,
        unique: true
    },
    title: String,
    caption: String,
    textBoxHeight: Number,
    yCoordinate: Number
}); 

const Story = new mongoose.model("Story", story)

module.exports = Story