const express = require("express")
const router = express.Router()

const storyViewModel = require("../viewModels/StoryViewModel");

router.post("/postStory", storyViewModel.postStory);
router.post("/getStories", storyViewModel.getStories);

module.exports = router