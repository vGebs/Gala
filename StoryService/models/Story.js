const mongoose = require("mongoose");

const story = new mongoose.Schema({
    uid: String,
    pid: Date,
    title: String,
    caption: String,
    textBoxHeight: Number,
    yCoordinate: Number
}); 

const Story = new mongoose.model("Story", story)

module.exports = Story