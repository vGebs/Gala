const storyRoutes = require("../routes/storyRoutes")
const userCoreRoutes = require("../routes/userCoreRoutes");
const altRoutes = require('../routes/altRoutes')

module.exports = function (app) {
    app.use(storyRoutes);
    app.use(userCoreRoutes);
    app.use(altRoutes);
}