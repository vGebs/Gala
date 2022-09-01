const express = require("express")
const router = express.Router()

router.get('*', (req, res) => {
    const payload = {
        error: "Page does not exist"
    };

    res.status(404).send(payload);
})

module.exports = router