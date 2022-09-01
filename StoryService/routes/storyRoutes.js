const express = require("express")
const router = express.Router()

const storyViewModel = require("../viewModels/StoryViewModel");

router.post("/story/postStory", storyViewModel.postStory);
router.post("/story/getStory", storyViewModel.getStory);
router.post("/story/getStories", storyViewModel.getStories);

module.exports = router