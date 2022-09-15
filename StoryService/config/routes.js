const storyRoutes = require("../routes/storyRoutes")
const userCoreRoutes = require("../routes/userCoreRoutes");
const recentlyJoinedRoutes = require("../routes/recentlyJoinedRoutes");
const altRoutes = require('../routes/altRoutes')

module.exports = function (app) {
    app.use(storyRoutes);
    app.use(userCoreRoutes);
    app.use(recentlyJoinedRoutes);
    app.use(altRoutes);
}