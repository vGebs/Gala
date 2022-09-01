const express = require("express")
const router = express.Router()

const userCoreViewModel = require("../viewModels/UserCoreViewModel");

router.post("/userCore/createUserCore", userCoreViewModel.createUserCore);
router.post("/userCore/getUserCore", userCoreViewModel.getUserCore);
router.post("/userCore/updateUserCore", userCoreViewModel.updateUserCore);
router.post("/userCore/deleteUserCore", userCoreViewModel.deleteUserCore);

module.exports = router