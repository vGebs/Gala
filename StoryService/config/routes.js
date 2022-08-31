const storyRoutes = require("../routes/storyRoutes")
const altRoutes = require('../routes/altRoutes')

module.exports = function (app) {
    app.use(storyRoutes);
    app.use(altRoutes);
}