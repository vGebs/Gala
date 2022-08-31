const Story = require("../models/Story");

const postStory = async (story) => {
    try {
        const newStory = new Story(story);
        
        await newStory.save();
        console.log("StoryService: Successfully posted story");
    } catch (e) {
        throw e
    }
}

const getStory = async (uid, pid) => {

}

const getStories = async (uid) => {

}

module.exports = {
    postStory,
    getStory,
    getStories
}